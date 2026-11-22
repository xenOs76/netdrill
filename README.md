# netdrill

<p align="center">
    <img width="650" alt="NetDrill Logo" src="./assets/img/netdrill-container-logo.png"/><br />
    <i>To find a way. Any way.</i>
</p>

A Docker container for Kubernetes network troubleshooting.\
Better deployed with
[kubectl-netdrill](https://github.com/xenOs76/kubectl-netdrill).

## Verify Image Signature & SBOM

```bash
cosign verify \
  --certificate-identity-regexp "^https://github\.com/xenOs76/netdrill/\.github/workflows/docker-build-and-push\.yml@refs/tags/.*$" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  ghcr.io/xenos76/netdrill:<tag>

cosign verify-attestation \
  --type spdxjson \
  --certificate-identity-regexp "^https://github\.com/xenOs76/netdrill/\.github/workflows/docker-build-and-push\.yml@refs/tags/.*$" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  ghcr.io/xenos76/netdrill:<tag>
```

## Acknowledgments

`netdrill` is heavily inspired by
[netshoot](https://github.com/nicolaka/netshoot) and
[kubectl-netshoot](https://github.com/nilic/kubectl-netshoot).
