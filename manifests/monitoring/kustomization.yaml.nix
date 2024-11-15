{
  kind = "Kustomization";
  apiVersion = "kustomize.config.k8s.io/v1beta1";
  resources = [
    "./namespace.yaml"
    "./grafana/ks.yaml"
    "./loki/ks.yaml"
    "./vector/ks.yaml"
  ];
}
