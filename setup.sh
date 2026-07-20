#!/usr/bin/env bash

set -e

if command -v nix >/dev/null 2>&1; then
  echo "nix already installed"
else
  # Install Nix
  sh <(curl -sSf -L https://install.lix.systems/lix | sh -s -- install)
  zsh
fi

if command -v home-manager >/dev/null 2>&1; then
  echo "home manager already installed"
else
  # Install home manager
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  nix-shell '<home-manager>' -A install
  zsh
fi

echo "updating home manager config"

HM_CFG_DIR=~/.config/home-manager
HM_FOLDERS=("aliases" "git_includes" "ssh_includes" "dot_files")

copy_cfg_item () {
  for FOLDER in "${HM_FOLDERS[@]}"; do
    mkdir -p "${HM_CFG_DIR}/${FOLDER}"

    if [ -d "${1}/${FOLDER}" ]; then
      echo "copy ${1}/${FOLDER}/ to ${HM_CFG_DIR}/${FOLDER}/"
      cp -r "${1}/${FOLDER}/" "${HM_CFG_DIR}"
    fi
  done
}

copy_cfg_item .

if [ -d "setup.d" ]; then
  for SETUPD in setup.d/*; do
    if [ -d "${SETUPD}" ]; then
      copy_cfg_item "./${SETUPD}"
    fi
  done
fi

cp ./home.nix ${HM_CFG_DIR}/home.nix

home-manager switch -b backup
zsh


