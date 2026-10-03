# fly pinned to each Concourse server it talks to.
#
# fly refuses to sync/run against a server whose version differs too much, so
# keep each package in step with its server rather than following nixpkgs.
# Both install a `fly` binary; a host installs the one for its server.
#
# Bump the matching entry when a Concourse server is upgraded.
self: super:
let
  # buildGoModule: newer servers can need a newer Go than nixpkgs' default.
  flyAt = { version, hash, vendorHash, buildGoModule ? super.buildGoModule }:
    (super.fly.override { inherit buildGoModule; }).overrideAttrs (old: {
    inherit version vendorHash;
    src = super.fetchFromGitHub {
      owner = "concourse";
      repo = "concourse";
      rev = "v${version}";
      inherit hash;
    };
  });
in
{
  # Work Concourse server. Installed on the work Mac.
  fly-work = flyAt {
    version = "8.1.1";
    hash = "sha256-JWl3dUx3eQWD8I+be6APuQklUw1ZzW6xK6iypxbgxF0=";
    vendorHash = "sha256-ZZfiRfOkAcF3ItB4tjp8BgurMThxUOoBMyt9PeJpus4=";
  };

  # Homelab Concourse (concourse.lab.bray.pizza); the server version comes from
  # the chart in homelab's kubernetes/apps/utilities/concourse/helmrelease.yaml.
  # Installed on debian-work-nix.
  fly-homelab = flyAt {
    version = "8.3.1";
    hash = "sha256-kX8xPxsP6PLAPHQhSPTmJ2LinhNyUfSxKfeogZjbXfE=";
    vendorHash = "sha256-OVZeQyJNiZcVR0H3lU3UeTt4sUXsd+1CtVh2gyGaKJ4=";
    buildGoModule = super.buildGo127Module;  # go.mod requires go >= 1.27.1
  };
}
