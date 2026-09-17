# TEMPORARY: pin talosctl to the Talos version running on the homelab cluster.
#
# Sidero recommends using a talosctl that matches the cluster's running Talos
# version. nixpkgs moved talosctl to 1.14 while the cluster stays on 1.13.x
# until Phase 9 of the homelab repo's notes/cluster-upgrade-plan.md.
#
# Remove this file once the cluster is upgraded to Talos 1.14.
self: super: {
  talosctl = super.talosctl.overrideAttrs (finalAttrs: old: {
    version = "1.13.10";
    src = super.fetchFromGitHub {
      owner = "siderolabs";
      repo = "talos";
      tag = "v${finalAttrs.version}";
      hash = "sha256-5vpkAlFe+iEi3jIpGmKarRnz/OOKap3dGjomSUhfc8c=";
    };
    vendorHash = "sha256-F2fefMJ/Ii/3sFoFt2PYzcF8SWCUxZqEJlD8JWC5C0c=";
  });
}
