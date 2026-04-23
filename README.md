# Fedora Niri Atomic

Minimal Fedora image with:

- `niri`
- `noctalia-shell`

## Rebase

Rebase an existing Fedora Atomic/bootc system to this image:

```bash
sudo rpm-ostree rebase unsigned:docker://ghcr.io/vlados-it/fedora-laptop-niri:latest
sudo systemctl reboot
```

After rebasing to the signed version:

```bash
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/vlados-it/fedora-laptop-niri:latest
sudo systemctl reboot
```

## Update

```bash
rpm-ostree upgrade
```

## Build

Workflow file:

- [.github/workflows/build.yml](./.github/workflows/build.yml)

 GitHub secrets:

- `COSIGN_PRIVATE_KEY`

The public key used by clients is stored here:

- [config/certs/cosign.pub](./config/certs/cosign.pub)

## Regenerate keys

Generate a new key pair:

```bash
cosign generate-key-pair
```

Then update:

- `config/certs/cosign.pub`
- GitHub secret `COSIGN_PRIVATE_KEY`
- GitHub secret `COSIGN_PASSWORD`
