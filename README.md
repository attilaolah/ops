# Home K8s Cluster

> Home IPv6-friendly Flux-managed K8s cluster on Talos+Alpine.

## 📖 Overview

This repository contains Infrastructure as Code (IaC) and GitOps config files
for managing my hobby cluster in the basement. Inspired by popular repos like
[toboshii/home-ops], with a few addicional considerations:


- **🛠️ Unconventional hardware:** As much as I enjoy automating the software
  infrastructure, I also really like building custom hardware to power it all.
  I spend maybe half the time in front of the ⌨️ keyboard and half the time
  using 🪚🪛 power tools.
- **🌳 Low footprint:** All of the nodes are either old machines I am no longer
  using, or used machines I bought for very cheap. Many use passive cooling.
- **6️⃣ IPv6 networking:** The goal is to manage the entire cluster via IPv6, and
  maybe one day disable IPv4 networking entirely.

## 6️⃣ IPv6 networking

Currently the machines in the cluster are connected to to the router that
Swisscom provides us, through cheap 10 Gbps switches that only do L2
forwarding. This router advertises two IPv6 prefixes:

- A `scope global`, `dynamic` prefix that belongs to the `2000::/3` range.
- A ULA prefix in the `fd00::/8` range. This appears to be the prefix
  `fdaa:bbcc:ddee:0/64` on these modems, and it seems to be static. As a
  consequence, I can calculate IPv6 addresses in this range that the hosts will
  configure for themselves using SLAAC, just by knowing the MAC address of the
  interfaces.

For the current setup, I'm using these link-local addresses for managing the
hosts, and IPv6 pinholing to access the load balancers from the outside.
CloudFlare sits in front of the load balancers; they conveniently provide IPv4
reachability.

For the service and pod subnets, I'm using IPv6 only networks:

- `fd10:96::/108` in place of the usual `10.96.0.0/12` service subnet.
- `fd10:244::/64` in place of the usual `10.244.0.0/16` pod subnet.

Currently `pool.ntp.org` has no AAAA records, so I'm using
`time.cloudflare.com` for time servers.

For DNS I'm using the usual public servers:

- `2001:4860:4860::8844` / `8.8.4.4` (Google 1)
- `2001:4860:4860::8888` / `8.8.8.8` (Google 2)
- `2606:4700:4700::1001` / `1.0.0.1` (CloudFlare 1)
- `2606:4700:4700::1111` / `1.1.1.1` (CloudFlare 2)

Some container registries currently don't have AAAA records either. For the
moment I haven't bothered setting up a local mirror. There is a nice summary
[in this comment](https://github.com/docker/roadmap/issues/89#issuecomment-772644009).

## 🧑‍💻️ Dev/Ops

The easiest way to get the required dependencies is to have `nix` and `direnv`
configured. Entering the repo will execute the [`.envrc` file], which in turn
will `use flake` to pull in dependencies from the `flake.nix` file.

[`.envrc` file]: https://github.com/attilaolah/ops/blob/main/.envrc

Without `direnv`, one would need to manually run `nix develop` to enter the
development shell.

## 💡 Inspiration

Much of this was inspired by a number of similar repos:

- [Euvaz/GitOps-Home]
- [toboshii/home-ops]

[Euvaz/GitOps-Home]: https://github.com/Euvaz/GitOps-Home
[toboshii/home-ops]: https://github.com/toboshii/home-ops

## 🚧 Under Construction

There is an existing repository where I already have most of these configs,
however it contains various secrets that are not properly extracted out. This
is an attempt to migrate exsting configs and redact any secrets.
