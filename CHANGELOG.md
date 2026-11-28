# Netdrill

## Unreleased

### Refactor

- Defer `nmap`, `nmap-scripts`, `tcpdump`, `tcptraceroute`, and `neovim` to
  on-demand `apk add` aliases in `config/bashrc_local` and drop `alias vi="nvim"`
- Block `fzf-bash-plugin` (`!fzf-bash-plugin`) to avoid pulling in `perl`
- Prune `/usr/share/{doc,man,info}` and `/var/cache/apk/*` in `Dockerfile`
- Squash the final image via a `FROM scratch` stage in `Dockerfile`

## v0.2.1 (2026-11-23)

### Ci

- Re-tag `latest` after Cosign signing and attestation in
  `docker-build-and-push.yml`
- Drop short git SHA tag and keep only the long SHA tag (`sha-<40-char>`)
- Default `TAG` to `latest` in `README.md` Cosign verification snippet

## v0.2.0 (2026-11-22)

### Ci

- Pin all GitHub Actions by commit SHA
- Add Hadolint linting and Trivy config/image scanning (`HIGH,CRITICAL`) with
  GitHub Security tab SARIF upload
- Scan `linux/amd64` and `linux/arm64` image digests independently and generate
  per-platform SPDX JSON SBOMs
- Sign multi-platform index and platform manifests and attest per-platform SBOMs
  with keyless Cosign (OIDC)

### Chore

- Pin Alpine base image to `3.24.4` digest and add `HEALTHCHECK` in `Dockerfile`
- Add `.markdownlint.yaml` configuration
- Document immutable-digest Cosign verification and pull workflow in `README.md`
- Trigger rebuild to add https-wrench 0.17.1 and aws-probe 0.3.2

## v0.1.8 (2026-10-24)

### Chore

    Trigger rebuild to add dig and https-wrench 0.17.0

## v0.1.7 (2026-09-15)

### Chore

    Trigger rebuild to add https-wrench 0.15.4

## v0.1.6 (2026-09-15)

### Chore

    Trigger rebuild to add https-wrench 0.15.3

## v0.1.5 (2026-08-23)

### Chore

    Trigger rebuild to add https-wrench 0.14.3

## v0.1.4 (2026-08-22)

### Chore

    Trigger rebuild to add aws-probe 0.3.1  and https-wrench 0.14.2

## v0.1.3 (2026-07-22)

### Chore

    Trigger rebuild to add aws-probe 0.3.0  and https-wrench 0.14.1

## v0.1.2 (2026-05-29)

### Chore

    Load bash autocompletion for aws-probe in local bash config

## v0.1.1 (2026-05-28)

### Feat

    Add aws-probe 0.1.3 and https-wrench 0.14.0

## v0.1.0 (2026-05-17)

### Chore

- Migrated Python development environment setup to use uv package manager,
  replacing traditional virtual environment configuration
- Fixed configuration template file naming inconsistency
- Updated Docker build configuration with configurable Alpine base image version
  and added development tools for enhanced system capabilities
- add nmap-scripts package

## v0.0.1 (2026-03-31)

### Feat

- initial import
