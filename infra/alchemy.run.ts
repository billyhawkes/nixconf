import * as Alchemy from "alchemy";
import * as Cloudflare from "alchemy/Cloudflare";
import * as Kubernetes from "alchemy/Kubernetes";
import * as Output from "alchemy/Output";
import * as Config from "effect/Config";
import * as Effect from "effect/Effect";
import * as Layer from "effect/Layer";
import * as Redacted from "effect/Redacted";

const namespace = "media";
const nodeName = "desktop-02";
const zoneName = "billyhawkes.com";
const jellyfinHostname = `media.${zoneName}`;
const jellyseerrHostname = `requests.${zoneName}`;
const adminTools = [
  {
    id: "Prowlarr",
    hostname: `prowlarr.${zoneName}`,
    service: "http://prowlarr.media.svc.cluster.local:9696",
  },
  {
    id: "Radarr",
    hostname: `radarr.${zoneName}`,
    service: "http://radarr.media.svc.cluster.local:7878",
  },
  {
    id: "Sonarr",
    hostname: `sonarr.${zoneName}`,
    service: "http://sonarr.media.svc.cluster.local:8989",
  },
  {
    id: "Bazarr",
    hostname: `bazarr.${zoneName}`,
    service: "http://bazarr.media.svc.cluster.local:6767",
  },
  {
    id: "Qbittorrent",
    hostname: `qbittorrent.${zoneName}`,
    service: "http://qbittorrent.media.svc.cluster.local:8080",
  },
] as const;
const appChart = {
  chart: "app-template",
  repo: "https://bjw-s-labs.github.io/helm-charts/",
  version: "5.1.0",
} as const;

interface MediaAppProps {
  cluster: Alchemy.Input<Kubernetes.ClusterLike>;
  name: string;
  image: string;
  port: number;
  configPath?: string;
  nodePort?: number;
  dataReadOnly?: boolean;
  cache?: boolean;
  runtimeClassName?: string;
  resources?: Record<string, unknown>;
  env?: Record<string, string>;
}

const mediaApp = (id: string, props: MediaAppProps) =>
  Kubernetes.HelmChart(id, {
    ...appChart,
    cluster: props.cluster,
    releaseName: props.name,
    namespace,
    values: {
      defaultPodOptions: {
        automountServiceAccountToken: false,
        nodeSelector: { "kubernetes.io/hostname": nodeName },
        runtimeClassName: props.runtimeClassName,
        securityContext: {
          fsGroup: 100,
          fsGroupChangePolicy: "OnRootMismatch",
        },
      },
      controllers: {
        main: {
          strategy: "Recreate",
          containers: {
            main: {
              image: {
                repository: props.image,
                tag: "latest",
                pullPolicy: "Always",
              },
              env: {
                PUID: "1000",
                PGID: "100",
                TZ: "America/Toronto",
                ...props.env,
              },
              resources: props.resources,
            },
          },
        },
      },
      service: {
        main: {
          controller: "main",
          type: props.nodePort === undefined ? "ClusterIP" : "NodePort",
          ports: {
            http: {
              port: props.port,
              targetPort: props.port,
              protocol: "HTTP",
              ...(props.nodePort === undefined
                ? {}
                : { nodePort: props.nodePort }),
            },
          },
        },
      },
      persistence: {
        config: {
          existingClaim: "media-appdata",
          advancedMounts: {
            main: {
              main: [
                {
                  path: props.configPath ?? "/config",
                  subPath: props.name,
                },
              ],
            },
          },
        },
        data: {
          existingClaim: "media-data",
          globalMounts: [
            {
              path: "/data",
              readOnly: props.dataReadOnly ?? false,
            },
          ],
        },
        ...(props.cache
          ? {
              cache: {
                existingClaim: "media-cache",
                globalMounts: [{ path: "/cache", subPath: props.name }],
              },
            }
          : {}),
      },
    },
  });

const cluster = Kubernetes.KubeConfig({ context: "desktop-02" });

export default Alchemy.Stack(
  "MediaServer",
  {
    providers: Layer.mergeAll(Cloudflare.providers(), Kubernetes.providers()),
    state: Cloudflare.state(),
  },
  Effect.gen(function* () {
    const mediaNamespace = yield* Kubernetes.Manifest("MediaNamespace", {
      cluster,
      manifest: {
        apiVersion: "v1",
        kind: "Namespace",
        metadata: { name: namespace },
      },
    });

    const mediaStorageClass = yield* Kubernetes.Manifest("MediaStorageClass", {
      cluster: mediaNamespace.connection,
      manifest: {
        apiVersion: "storage.k8s.io/v1",
        kind: "StorageClass",
        metadata: { name: "media-local" },
        provisioner: "kubernetes.io/no-provisioner",
        reclaimPolicy: "Retain",
        volumeBindingMode: "WaitForFirstConsumer",
      },
    });

    const volumes = [
      {
        id: "MediaData",
        name: "media-data",
        path: "/srv/data",
        capacity: "10Ti",
      },
      {
        id: "MediaCache",
        name: "media-cache",
        path: "/srv/cache",
        capacity: "900Gi",
      },
      {
        id: "MediaAppdata",
        name: "media-appdata",
        path: "/srv/appdata",
        capacity: "300Gi",
      },
    ] as const;

    let storageCluster: Alchemy.Input<Kubernetes.ClusterLike> =
      mediaStorageClass.connection;
    for (const volume of volumes) {
      const persistentVolume: Kubernetes.Manifest = yield* Kubernetes.Manifest(
        `${volume.id}Volume`,
        {
          cluster: storageCluster,
          manifest: {
            apiVersion: "v1",
            kind: "PersistentVolume",
            metadata: { name: volume.name },
            spec: {
              capacity: { storage: volume.capacity },
              accessModes: ["ReadWriteOnce"],
              persistentVolumeReclaimPolicy: "Retain",
              storageClassName: "media-local",
              local: { path: volume.path },
              nodeAffinity: {
                required: {
                  nodeSelectorTerms: [
                    {
                      matchExpressions: [
                        {
                          key: "kubernetes.io/hostname",
                          operator: "In",
                          values: [nodeName],
                        },
                      ],
                    },
                  ],
                },
              },
            },
          },
        },
      );

      const persistentVolumeClaim: Kubernetes.Manifest =
        yield* Kubernetes.Manifest(
          `${volume.id}Claim`,
          {
            cluster: persistentVolume.connection,
            manifest: {
              apiVersion: "v1",
              kind: "PersistentVolumeClaim",
              metadata: { name: volume.name, namespace },
              spec: {
                accessModes: ["ReadWriteOnce"],
                resources: { requests: { storage: volume.capacity } },
                storageClassName: "media-local",
                volumeName: volume.name,
              },
            },
          },
        );
      storageCluster = persistentVolumeClaim.connection;
    }

    const nvidiaRuntimeClass = yield* Kubernetes.Manifest(
      "NvidiaRuntimeClass",
      {
        cluster: storageCluster,
        manifest: {
          apiVersion: "node.k8s.io/v1",
          kind: "RuntimeClass",
          metadata: { name: "nvidia-cdi" },
          handler: "nvidia-cdi",
        },
      },
    );

    const nvidiaDevicePlugin = yield* Kubernetes.HelmChart(
      "NvidiaDevicePlugin",
      {
        cluster: nvidiaRuntimeClass.connection,
        chart: "nvidia-device-plugin",
        repo: "https://nvidia.github.io/k8s-device-plugin",
        version: "0.20.0",
        releaseName: "nvidia-device-plugin",
        namespace: "kube-system",
        values: {
          affinity: null,
          nodeSelector: { "kubernetes.io/hostname": nodeName },
          runtimeClassName: "nvidia-cdi",
          deviceListStrategy: "envvar",
        },
      },
    );

    const mediaAppCluster = nvidiaDevicePlugin.connection;

    yield* mediaApp("Jellyfin", {
      cluster: mediaAppCluster,
      name: "jellyfin",
      image: "docker.io/jellyfin/jellyfin",
      port: 8096,
      dataReadOnly: true,
      cache: true,
      runtimeClassName: "nvidia-cdi",
      env: {
        NVIDIA_DRIVER_CAPABILITIES: "compute,video,utility",
        NVIDIA_VISIBLE_DEVICES: "all",
      },
      resources: {
        requests: { cpu: "250m", memory: "512Mi" },
        limits: { memory: "8Gi", "nvidia.com/gpu": 1 },
      },
    });

    yield* mediaApp("Jellyseerr", {
      cluster: mediaAppCluster,
      name: "jellyseerr",
      image: "docker.io/fallenbagel/jellyseerr",
      port: 5055,
      configPath: "/app/config",
    });
    yield* mediaApp("Sonarr", {
      cluster: mediaAppCluster,
      name: "sonarr",
      image: "lscr.io/linuxserver/sonarr",
      port: 8989,
      nodePort: 30989,
    });
    yield* mediaApp("Radarr", {
      cluster: mediaAppCluster,
      name: "radarr",
      image: "lscr.io/linuxserver/radarr",
      port: 7878,
      nodePort: 30787,
    });
    yield* mediaApp("Prowlarr", {
      cluster: mediaAppCluster,
      name: "prowlarr",
      image: "lscr.io/linuxserver/prowlarr",
      port: 9696,
      nodePort: 30696,
    });
    yield* Kubernetes.HelmChart("FlareSolverr", {
      ...appChart,
      cluster: mediaAppCluster,
      releaseName: "flaresolverr",
      namespace,
      values: {
        defaultPodOptions: {
          automountServiceAccountToken: false,
          nodeSelector: { "kubernetes.io/hostname": nodeName },
        },
        controllers: {
          main: {
            containers: {
              main: {
                image: {
                  repository: "ghcr.io/flaresolverr/flaresolverr",
                  tag: "latest",
                  pullPolicy: "Always",
                },
                env: {
                  LOG_LEVEL: "info",
                  LOG_HTML: "false",
                  TZ: "America/Toronto",
                },
                resources: {
                  requests: { cpu: "100m", memory: "256Mi" },
                  limits: { memory: "2Gi" },
                },
              },
            },
          },
        },
        service: {
          main: {
            controller: "main",
            type: "ClusterIP",
            ports: {
              http: { port: 8191, targetPort: 8191, protocol: "HTTP" },
            },
          },
        },
      },
    });
    yield* mediaApp("Bazarr", {
      cluster: mediaAppCluster,
      name: "bazarr",
      image: "lscr.io/linuxserver/bazarr",
      port: 6767,
      nodePort: 30676,
    });

    const protonVpnSecret = yield* Kubernetes.Manifest("ProtonVpnSecret", {
      cluster: mediaNamespace.connection,
      manifest: {
        apiVersion: "v1",
        kind: "Secret",
        metadata: { name: "proton-vpn", namespace },
        stringData: {
          wireguardPrivateKey: Config.string(
            "PROTONVPN_WIREGUARD_PRIVATE_KEY",
          ),
        },
      },
    });

    yield* Kubernetes.HelmChart("Qbittorrent", {
      ...appChart,
      cluster: mediaAppCluster,
      releaseName: "qbittorrent",
      namespace,
      values: {
        defaultPodOptions: {
          automountServiceAccountToken: false,
          dnsConfig: { nameservers: ["127.0.0.1"] },
          dnsPolicy: "None",
          nodeSelector: { "kubernetes.io/hostname": nodeName },
          securityContext: {
            fsGroup: 100,
            fsGroupChangePolicy: "OnRootMismatch",
          },
        },
        controllers: {
          main: {
            strategy: "Recreate",
            containers: {
              gluetun: {
                image: {
                  repository: "docker.io/qmcgaw/gluetun",
                  tag: "latest",
                  pullPolicy: "Always",
                },
                env: {
                  VPN_SERVICE_PROVIDER: "protonvpn",
                  VPN_TYPE: "wireguard",
                  WIREGUARD_PRIVATE_KEY: {
                    valueFrom: {
                      secretKeyRef: {
                        name: protonVpnSecret.name,
                        key: "wireguardPrivateKey",
                      },
                    },
                  },
                  SERVER_COUNTRIES: "Canada",
                  PORT_FORWARD_ONLY: "on",
                  VPN_PORT_FORWARDING: "on",
                  VPN_PORT_FORWARDING_STATUS_FILE:
                    "/gluetun/forwarded_port",
                  VPN_PORT_FORWARDING_UP_COMMAND:
                    "/bin/sh -c 'wget -qO /dev/null --retry-connrefused --post-data \"json={\\\"listen_port\\\":$(cat /gluetun/forwarded_port),\\\"current_network_interface\\\":\\\"tun0\\\",\\\"random_port\\\":false,\\\"upnp\\\":false}\" http://127.0.0.1:8080/api/v2/app/setPreferences'",
                  VPN_PORT_FORWARDING_DOWN_COMMAND:
                    "/bin/sh -c 'wget -qO /dev/null --retry-connrefused --post-data \"json={\\\"listen_port\\\":0,\\\"current_network_interface\\\":\\\"lo\\\"}\" http://127.0.0.1:8080/api/v2/app/setPreferences'",
                  HEALTH_TARGET_ADDRESSES: "1.1.1.1:443",
                  FIREWALL_INPUT_PORTS: "8080",
                  TZ: "America/Toronto",
                },
                securityContext: {
                  allowPrivilegeEscalation: false,
                  capabilities: { add: ["NET_ADMIN"] },
                },
                resources: {
                  requests: { cpu: "25m", memory: "64Mi" },
                  limits: { memory: "256Mi" },
                },
              },
              qbittorrent: {
                image: {
                  repository: "lscr.io/linuxserver/qbittorrent",
                  tag: "latest",
                  pullPolicy: "Always",
                },
                env: {
                  PUID: "1000",
                  PGID: "100",
                  TZ: "America/Toronto",
                  WEBUI_PORT: "8080",
                },
                resources: {
                  requests: { cpu: "100m", memory: "256Mi" },
                  limits: { memory: "4Gi" },
                },
              },
            },
          },
        },
        service: {
          main: {
            controller: "main",
            type: "NodePort",
            ports: {
              http: {
                port: 8080,
                targetPort: 8080,
                protocol: "HTTP",
                nodePort: 30808,
              },
            },
          },
        },
        persistence: {
          config: {
            existingClaim: "media-appdata",
            advancedMounts: {
              main: {
                gluetun: [{ path: "/gluetun", subPath: "gluetun" }],
                qbittorrent: [
                  { path: "/config", subPath: "qbittorrent" },
                ],
              },
            },
          },
          data: {
            existingClaim: "media-data",
            advancedMounts: {
              main: {
                qbittorrent: [{ path: "/data" }],
              },
            },
          },
          tun: {
            type: "hostPath",
            hostPath: "/dev/net/tun",
            hostPathType: "CharDevice",
            advancedMounts: {
              main: {
                gluetun: [{ path: "/dev/net/tun" }],
              },
            },
          },
        },
      },
    });

    const tunnel = yield* Cloudflare.Tunnel.Tunnel("MediaTunnel", {
      name: "desktop-02-media",
    });
    const { accountId } = yield* yield* Cloudflare.CloudflareEnvironment;
    const zoneId = yield* Cloudflare.Zone.resolveZoneId({
      accountId,
      zone: zoneName,
      hostname: jellyfinHostname,
    }).pipe(Effect.orDie);

    const mediaAdminPolicy = yield* Cloudflare.Access.Policy(
      "MediaAdminPolicy",
      {
        name: "Allow Billy to administer media services",
        decision: "allow",
        include: [{ email: "billyhawkes02@gmail.com" }],
        sessionDuration: "24h",
      },
    );

    for (const tool of adminTools) {
      yield* Cloudflare.Access.Application(`${tool.id}Access`, {
        type: "self_hosted",
        name: `${tool.id} media admin`,
        domain: tool.hostname,
        sessionDuration: "24h",
        appLauncherVisible: true,
        policies: [mediaAdminPolicy],
      });
    }

    const tunnelToken = yield* Kubernetes.Manifest("TunnelToken", {
      cluster: mediaNamespace.connection,
      manifest: {
        apiVersion: "v1",
        kind: "Secret",
        metadata: { name: "cloudflared-token", namespace },
        stringData: {
          token: Output.map(tunnel.token, Redacted.value),
        },
      },
    });

    yield* Kubernetes.Manifest("Cloudflared", {
      cluster,
      manifest: {
        apiVersion: "apps/v1",
        kind: "Deployment",
        metadata: { name: "cloudflared", namespace },
        spec: {
          replicas: 2,
          selector: { matchLabels: { app: "cloudflared" } },
          template: {
            metadata: { labels: { app: "cloudflared" } },
            spec: {
              automountServiceAccountToken: false,
              containers: [
                {
                  name: "cloudflared",
                  image: "docker.io/cloudflare/cloudflared:latest",
                  imagePullPolicy: "Always",
                  args: ["tunnel", "--no-autoupdate", "run"],
                  env: [
                    {
                      name: "TUNNEL_TOKEN",
                      valueFrom: {
                        secretKeyRef: {
                          name: tunnelToken.name,
                          key: "token",
                        },
                      },
                    },
                  ],
                  resources: {
                    requests: { cpu: "25m", memory: "64Mi" },
                    limits: { memory: "256Mi" },
                  },
                },
              ],
            },
          },
        },
      },
    });

    yield* Cloudflare.Tunnel.Configuration("MediaTunnelIngress", {
      tunnelId: tunnel.tunnelId,
      ingress: [
        {
          hostname: jellyfinHostname,
          service: `http://jellyfin.${namespace}.svc.cluster.local:8096`,
        },
        {
          hostname: jellyseerrHostname,
          service: `http://jellyseerr.${namespace}.svc.cluster.local:5055`,
        },
        ...adminTools.map(({ hostname, service }) => ({ hostname, service })),
      ],
    });

    for (const [id, hostname] of [
      ["JellyfinDns", jellyfinHostname],
      ["JellyseerrDns", jellyseerrHostname],
    ] as const) {
      yield* Cloudflare.DNS.Record(id, {
        zoneId,
        name: hostname,
        type: "CNAME",
        content: Output.interpolate`${tunnel.tunnelId}.cfargotunnel.com`,
        proxied: true,
        comment: "Managed by Alchemy for desktop-02",
      });
    }

    for (const tool of adminTools) {
      yield* Cloudflare.DNS.Record(`${tool.id}Dns`, {
        zoneId,
        name: tool.hostname,
        type: "CNAME",
        content: Output.interpolate`${tunnel.tunnelId}.cfargotunnel.com`,
        proxied: true,
        comment: "Managed by Alchemy for desktop-02; protected by Access",
      });
    }

    return {
      jellyfinUrl: `https://${jellyfinHostname}`,
      jellyseerrUrl: `https://${jellyseerrHostname}`,
      adminUrls: Object.fromEntries(
        adminTools.map((tool) => [tool.id, `https://${tool.hostname}`]),
      ),
      tunnelId: tunnel.tunnelId,
    };
  }),
);
