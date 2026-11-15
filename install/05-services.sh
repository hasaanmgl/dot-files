# shellcheck shell=bash

log "Enabling system services..."
sudo systemctl enable --now NetworkManager.service || true
sudo systemctl enable --now bluetooth.service || true
sudo systemctl enable --now cups.service || true

systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null \
  || systemctl --user enable --now pipewire pipewire-pulse wireplumber || true

mkdir -p "$HOME/Videos" "$HOME/Pictures/Wallpapers" "$HOME/Downloads"

if command -v flatpak &>/dev/null; then
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true

  FLATPAK_PACKAGES=()
  read_pkg_list "$INSTALL_DIR/packages/flatpak.txt" FLATPAK_PACKAGES

  if ((${#FLATPAK_PACKAGES[@]})); then
    log "Installing Flatpak apps (${#FLATPAK_PACKAGES[@]})..."
    if ! flatpak install -y --noninteractive flathub "${FLATPAK_PACKAGES[@]}"; then
      echo "   Flatpak batch had errors — retrying apps one by one..."
      for p in "${FLATPAK_PACKAGES[@]}"; do
        flatpak install -y --noninteractive flathub "$p" || echo "   SKIP (flatpak): $p"
      done
    fi
  fi
fi
