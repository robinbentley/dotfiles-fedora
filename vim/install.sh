#!/usr/bin/env bash
set -euo pipefail

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/0.14.0/plug.vim

mkdir -p ~/.vim/swap

vim +PlugInstall +qall
