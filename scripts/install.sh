#!/usr/bin/env bash

mkdir -p "$HOME/paper"
cp "$HOME/.config/thorn/paper/"* "$HOME/paper"

mkdir -p "$HOME/.cache/qs"

"$HOME/.config/quickshell/thorn/scripts/json.sh" "$HOME/paper" refresh

sudo cp "$HOME/.config/quickshell/thorn/scripts/colors-qs.json" \
    /usr/lib/python3.13/site-packages/pywal/templates/

echo "install ttf-material-symbols-variable-git"

echo -e "\nDownload wal-discord here:"
echo "https://github.com/guglicap/wal-discord.git"

echo -e "\nMake sure to install pywal and the haishoku backend"
echo "Arch: paru -S python-pywal python-haishoku"
echo -e "\nRegister globals"
echo -e "\nbind = \$mainMod CTRL, RETURN, global, shell:runner"
echo -e "bind = \$mainMod SHIFT, W, global, shell:nextimage"
