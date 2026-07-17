hs.ipc.cliInstall()

local hotkeyMods = { "ctrl" }
local hotkeyKey = "v"
local mouseButton = 4

local home = os.getenv("HOME")
local modelDir = home .. "/.local/share/whisper"
local modelPath = modelDir .. "/ggml-small.en.bin"
local modelDownloadPath = modelPath .. ".download"
local modelUrl = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin"
local runtimeDir = "/tmp/opencode-whisper"
local audioPath = runtimeDir .. "/input.wav"
local outputBase = runtimeDir .. "/transcript"
local outputPath = outputBase .. ".txt"

local ffmpeg = "/opt/homebrew/bin/ffmpeg"
local whisper = "/opt/homebrew/bin/whisper-cli"
local curl = "/usr/bin/curl"

local recorder = nil
local transcriber = nil
local modelDownloader = nil
local recordingStartedAt = nil
local stopping = false
local outputDevice = nil
local outputWasMuted = nil
local outputVolume = nil
local volumeFallback = false

local function muteOutput()
  outputDevice = hs.audiodevice.defaultOutputDevice()
  if outputDevice == nil then
    hs.printf("No default output audio device")
    return
  end

  outputWasMuted = outputDevice:outputMuted()
  if outputWasMuted == true then
    return
  end

  if outputWasMuted == false and outputDevice:setOutputMuted(true) then
    return
  end

  outputVolume = outputDevice:outputVolume()
  if outputVolume ~= nil then
    volumeFallback = outputDevice:setOutputVolume(0)
  end
  if not volumeFallback then
    hs.printf("Could not mute or lower output audio: %s", outputDevice:name())
  end
end

local function restoreOutput()
  if outputDevice ~= nil then
    if volumeFallback and outputVolume ~= nil then
      outputDevice:setOutputVolume(outputVolume)
    elseif outputWasMuted ~= nil then
      outputDevice:setOutputMuted(outputWasMuted)
    end
  end

  outputDevice = nil
  outputWasMuted = nil
  outputVolume = nil
  volumeFallback = false
end

local function notify(message)
  hs.alert.closeAll()
  hs.alert.show(message, 1.5)
end

local function showListening()
  hs.alert.closeAll()
  hs.alert.show("Listening...", 3600)
end

local function cleanTranscript(text)
  text = text:gsub("%[BLANK_AUDIO%]", "")
  text = text:gsub("%s+", " ")
  return text:gsub("^%s+", ""):gsub("%s+$", "")
end

local function paste(text)
  if text == "" then
    notify("No speech detected")
    return
  end

  local previousClipboard = hs.pasteboard.getContents()
  hs.pasteboard.setContents(text .. " ")
  local transcriptClipboard = hs.pasteboard.getContents()
  hs.eventtap.keyStroke({ "cmd" }, "v", 0)

  hs.timer.doAfter(0.75, function()
    if previousClipboard ~= nil and hs.pasteboard.getContents() == transcriptClipboard then
      hs.pasteboard.setContents(previousClipboard)
    end
  end)
end

local function readTranscript()
  local output = io.open(outputPath, "r")
  if output == nil then
    return ""
  end

  local text = output:read("*a")
  output:close()
  return cleanTranscript(text)
end

local function transcribe()
  notify("Transcribing...")
  os.remove(outputPath)

  transcriber = hs.task.new(whisper, function(exitCode, _, stderr)
    transcriber = nil
    if exitCode ~= 0 then
      hs.printf("Whisper transcription failed (%d): %s", exitCode, stderr)
      notify("Transcription failed")
      return
    end

    paste(readTranscript())
  end, {
    "-m", modelPath,
    "-f", audioPath,
    "-l", "en",
    "-sns",
    "-otxt",
    "-of", outputBase,
    "-np",
  })

  if not transcriber:start() then
    transcriber = nil
    notify("Could not start Whisper")
  end
end

local function ensureModel()
  if hs.fs.attributes(modelPath) then
    return true
  end
  if modelDownloader ~= nil then
    notify("Whisper model is downloading")
    return false
  end

  hs.execute("/bin/mkdir -p " .. string.format("%q", modelDir), true)
  notify("Downloading Whisper small.en model...")
  modelDownloader = hs.task.new(curl, function(exitCode, _, stderr)
    modelDownloader = nil
    if exitCode ~= 0 or not os.rename(modelDownloadPath, modelPath) then
      os.remove(modelDownloadPath)
      hs.printf("Whisper model download failed (%d): %s", exitCode, stderr)
      notify("Model download failed")
      return
    end
    notify("Whisper model ready")
  end, {
    "-L",
    "--fail",
    "--silent",
    "--show-error",
    "--output", modelDownloadPath,
    modelUrl,
  })
  if not modelDownloader:start() then
    modelDownloader = nil
    notify("Could not download model")
  end
  return false
end

local function startRecording()
  if recorder ~= nil or transcriber ~= nil or not ensureModel() then
    return
  end

  hs.execute("/bin/mkdir -p " .. string.format("%q", runtimeDir), true)
  os.remove(audioPath)
  recordingStartedAt = hs.timer.secondsSinceEpoch()
  stopping = false
  muteOutput()

  recorder = hs.task.new(ffmpeg, function(exitCode, _, stderr)
    recorder = nil
    restoreOutput()
    if not stopping then
      hs.printf("Audio recording failed (%d): %s", exitCode, stderr)
      notify("Recording failed")
      return
    end

    stopping = false
    if hs.timer.secondsSinceEpoch() - recordingStartedAt >= 0.3 then
      transcribe()
    end
  end, {
    "-hide_banner",
    "-loglevel", "error",
    "-f", "avfoundation",
    "-i", ":default",
    "-ac", "1",
    "-ar", "16000",
    "-c:a", "pcm_s16le",
    "-y", audioPath,
  })

  if recorder:start() then
    showListening()
  else
    recorder = nil
    restoreOutput()
    notify("Could not start recording")
  end
end

local function stopRecording()
  if recorder == nil or stopping then
    return
  end

  stopping = true
  hs.alert.closeAll()
  recorder:interrupt()
end

hs.hotkey.bind(hotkeyMods, hotkeyKey, startRecording, stopRecording)

whisperMouseTap = hs.eventtap.new({
  hs.eventtap.event.types.otherMouseDown,
  hs.eventtap.event.types.otherMouseUp,
}, function(event)
  local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
  if button ~= mouseButton then
    return false
  end

  if event:getType() == hs.eventtap.event.types.otherMouseDown then
    startRecording()
  else
    stopRecording()
  end
  return true
end):start()
