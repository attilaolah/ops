{self, ...}: {
  kind = "FluxInstance";
  apiVersion = "fluxcd.controlplane.io/v1";
  metadata = {
    name = "flux";
    namespace = "flux-system";
  };
  spec = {
    distribution = {
      version = "2.4.0";
      registry = "ghcr.io/fluxcd";
      artifact = "oci://ghcr.io/controlplaneio-fluxcd/flux-operator-manifests";
    };
    sync = {
      inherit (import ./source.nix) kind;
      url = with self.lib.cluster.github; "oci://${registry}/${owner}/${repository}";
      ref = "latest";
      path = ".";
      pullSecret = "ghcr-auth";
    };
    cluster = {
      type = "kubernetes";
      networkPolicy = true;
    };
  };
}
