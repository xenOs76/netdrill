# netdrill

<p align="center">
    <img width="650" alt="NetDrill Logo" src="./assets/img/netdrill-container-logo.png"/><br />
    <i>To find a way. Any way.</i>
</p>

A Docker container for Kubernetes network troubleshooting.\
Better deployed with
[kubectl-netdrill](https://github.com/xenOs76/kubectl-netdrill).

## Verify Image Signature & SBOM

Resolve the tag to an immutable platform digest first, then verify and pull that
exact digest:

```bash
TAG="${TAG:-latest}"
ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
DIGEST=$(docker buildx imagetools inspect "ghcr.io/xenos76/netdrill:${TAG}" --raw \
  | jq -r --arg arch "$ARCH" '.manifests[] | select(.platform.os=="linux" and .platform.architecture==$arch) | .digest')
IMAGE_REF="ghcr.io/xenos76/netdrill@${DIGEST}"

cosign verify \
  --certificate-identity-regexp "^https://github\.com/xenOs76/netdrill/\.github/workflows/docker-build-and-push\.yml@refs/tags/.*$" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  "${IMAGE_REF}"

cosign verify-attestation \
  --type spdxjson \
  --certificate-identity-regexp "^https://github\.com/xenOs76/netdrill/\.github/workflows/docker-build-and-push\.yml@refs/tags/.*$" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  "${IMAGE_REF}"

docker pull "${IMAGE_REF}"
```

## Acknowledgments

`netdrill` is heavily inspired by
[netshoot](https://github.com/nicolaka/netshoot) and
[kubectl-netshoot](https://github.com/nilic/kubectl-netshoot).
