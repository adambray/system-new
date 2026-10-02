# Pin fly to the version of the work Concourse server (v8.1.1).
#
# fly refuses to sync/run against a server whose version differs too much, so
# keep this in step with the server rather than following nixpkgs.
#
# Bump or remove this file when the Concourse server is upgraded.
self: super: {
  fly = super.fly.overrideAttrs (finalAttrs: old: {
    version = "8.1.1";
    src = super.fetchFromGitHub {
      owner = "concourse";
      repo = "concourse";
      rev = "v${finalAttrs.version}";
      hash = "sha256-JWl3dUx3eQWD8I+be6APuQklUw1ZzW6xK6iypxbgxF0=";
    };
    vendorHash = "sha256-ZZfiRfOkAcF3ItB4tjp8BgurMThxUOoBMyt9PeJpus4=";
  });
}
