{pkgs, ...}: let
  inherit (pkgs.lib.generators) toYAML;

  cluster = import ../cluster;
  hosts = import ../cluster/hosts {inherit pkgs;};
  writeYAML = (pkgs.formats.yaml {}).generate;

  first = builtins.head hosts.control_plane;

  cp = map (node: node // {cp = true;}) hosts.control_plane;
  workers = map (node: node // {cp = false;}) hosts.workers;
in
  writeYAML "talconfig.yaml" {
    clusterName = cluster.name;
    talosVersion = "v1.8.1";
    kubernetesVersion = "v1.31.1";
    endpoint = "https://${first.ipv4}:6443";
    domain = cluster.domain;

    # Allow running jobs on control plane nodes.
    # Currently the control plane nodes don't do much anyway.
    allowSchedulingOnControlPlanes = true;

    nodes = map (node: {
      inherit (node) hostname;
      controlPlane = node.cp;

      ipAddress = node.ipv4;
      installDiskSelector.type = "ssd";
      networkInterfaces = [
        {
          deviceSelector.hardwareAddr = node.mac;
          addresses = [node.net4];
          routes = [
            {
              network = "0.0.0.0/0";
              gateway = cluster.network.uplink.gw4;
            }
            # IPv6 default route is auto-configured.
          ];
          dhcp = false;
        }
      ];
    }) (cp ++ workers);

    patches = [
      (toYAML {} {
        cluster = {
          network = with cluster.network; {
            podSubnets = with pod; [cidr4 cidr6];
            serviceSubnets = with service; [cidr4 cidr6];
            cni = {name = "none";}; # we use cilium
          };
        };
        machine.network.nameservers = [
          "1.1.1.1"
          "9.9.9.9"
          "2606:4700:4700::1111"
          "2620:fe::fe"
        ];
      })
    ];
  }
