#!/bin/bash

set -e
set -o pipefail

INSTALLER_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
INSTALLER_NAME="Miniforge3-Linux-x86_64.sh"
INSTALL_DIR="$HOME/miniforge3"

# --- Miniforge インストーラの取得 ---
echo "★ Miniforge インストーラを取得します"
wget --quiet "$INSTALLER_URL" -O "$INSTALLER_NAME"
chmod +x "$INSTALLER_NAME"

# --- Miniforge のインストール ---
echo "★ Miniforge を $INSTALL_DIR にインストールします"
./"$INSTALLER_NAME" -b -p "$INSTALL_DIR"

# --- conda init の実行 ---
echo "★ conda init を実行して .bashrc に初期化を追加します"
"$INSTALL_DIR/bin/conda" init bash

# --- .bashrc の即時反映 ---
echo "★ .bashrc を即時反映します"
source ~/.bashrc

# --- conda のアップデートとクリーンアップ ---
echo "★ conda のアップデートとクリーン処理を実行します"
"$INSTALL_DIR/bin/conda" update -n base -c defaults conda -y
"$INSTALL_DIR/bin/conda" update --all -y
"$INSTALL_DIR/bin/conda" clean --all -y

# --- インストーラの削除 ---
echo "★ インストーラを削除します"
rm -f "$INSTALLER_NAME"

# --- /mnt/wslg/runtime-dir のパーミッション恒久化 ---
echo "★ /mnt/wslg/runtime-dir のパーミッションを恒久的に 0700 に設定します"
cat <<'EOF' | sudo tee /etc/wslg_fix_permission.sh
#!/bin/bash
if [ -d /mnt/wslg/runtime-dir ]; then
  chmod 700 /mnt/wslg/runtime-dir
fi
EOF
sudo chmod +x /etc/wslg_fix_permission.sh
grep -qxF "sudo /etc/wslg_fix_permission.sh" ~/.bashrc || echo "sudo /etc/wslg_fix_permission.sh" >> ~/.bashrc

# --- 完了メッセージ ---
echo -e "\n\033[1;32m✅ Miniforge のインストールと初期セットアップが完了しました。\nターミナルを再起動するか 'source ~/.bashrc' を実行してください。\033[0m"
