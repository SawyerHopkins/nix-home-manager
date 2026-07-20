#!/usr/bin/env bash

set -e

HM_CFG_DIR=~/.config/home-manager
HM_FOLDERS=("aliases" "git_includes" "ssh_includes" "dot_files" "git_settings")

if command -v nix >/dev/null 2>&1; then
  echo "nix already installed"
else
  # Install Nix
  sh <(curl -sSf -L https://install.lix.systems/lix | sh -s -- install)
  zsh
fi

sed "s/__USER__/$(whoami)/g" flake.nix.template > flake.nix
mkdir -p ${HM_CFG_DIR}
cp ./flake.nix ${HM_CFG_DIR}/flake.nix

if command -v home-manager >/dev/null 2>&1; then
  echo "home manager already installed"
else
  # Install home manager
  nix run home-manager/release-26.05 -- init --switch
  zsh
fi

echo "updating home manager config"
copy_cfg_item () {
  for FOLDER in "${HM_FOLDERS[@]}"; do
    mkdir -p "${HM_CFG_DIR}/${FOLDER}"

    if [ -d "${1}/${FOLDER}" ]; then
      echo "copy ${1}/${FOLDER}/ to ${HM_CFG_DIR}/${FOLDER}/"
      cp -r "${1}/${FOLDER}/" "${HM_CFG_DIR}/${FOLDER}/"
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

sed "s/__USER__/$(whoami)/g" home.nix.template > home.nix
cp ./home.nix ${HM_CFG_DIR}/home.nix

cd ${HM_CFG_DIR}
nix flake update

home-manager switch -b backup
zsh


