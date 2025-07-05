#!/bin/bash

# --- パスワードなしsudo設定 ---
echo "★ パスワードなし sudo 設定を有効化します"
echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/99_nopasswd_ubuntu
sudo chmod 440 /etc/sudoers.d/99_nopasswd_ubuntu

# --- wsl.conf 設定 ---
echo "★ /etc/wsl.conf を設定します（デフォルトユーザー：ubuntu）"
cat <<EOF | sudo tee /etc/wsl.conf
[user]
default=ubuntu
EOF

# --- bashrc の末尾に cd ~ を追加 ---
echo "★ .bashrc に 'cd ~' を追加します"
echo "cd ~" >> ~/.bashrc

# --- パッケージアップデートとクリーンアップ ---
echo "★ パッケージのアップデートとクリーンアップを実行します"
sudo apt-get update && sudo apt-get -y full-upgrade
sudo apt-get -y autoremove
sudo apt-get -y autoclean

# --- 日本語ロケールとタイムゾーン設定 ---
echo "★ 日本語ロケールとタイムゾーンを設定します"
sudo apt-get -y install language-pack-ja
sudo localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
sudo timedatectl set-timezone Asia/Tokyo

# --- ibus-mozc のインストール ---
echo "★ ibus-mozc と関連パッケージをインストールします"
sudo apt-get -y install ibus-mozc im-config dbus-x11

# --- フォントのインストール ---
echo "★ 日本語フォントをインストールします"
sudo apt-get -y install fonts-noto-cjk fonts-ipafont fonts-takao

# --- Windows フォントの利用設定 ---
echo "★ Windows のフォントを使用できるように設定します"
cat << 'EOS' | sudo tee /etc/fonts/local.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <dir>/mnt/c/Windows/Fonts</dir>
</fontconfig>
EOS

# --- ibus 環境変数と自動起動の設定 ---
echo "★ ibus の環境変数と自動起動設定を ~/.profile に追加します"
grep -qxF 'export GTK_IM_MODULE=ibus' ~/.profile || echo 'export GTK_IM_MODULE=ibus' >> ~/.profile
grep -qxF 'export QT_IM_MODULE=ibus' ~/.profile || echo 'export QT_IM_MODULE=ibus' >> ~/.profile
grep -qxF 'export XMODIFIERS=@im=ibus' ~/.profile || echo 'export XMODIFIERS=@im=ibus' >> ~/.profile
grep -qxF 'ibus-daemon -drx &>/dev/null &' ~/.profile || echo 'ibus-daemon -drx &>/dev/null &' >> ~/.profile

# --- 日本語キーボード設定 ---
echo "★ 日本語キーボードレイアウト（jp106）を設定します"
wget https://mirrors.edge.kernel.org/pub/linux/utils/kbd/kbd-2.6.4.tar.xz
tar Jxvf kbd-2.6.4.tar.xz
sudo mkdir -p /usr/share/keymaps
sudo cp -Rp kbd-2.6.4/data/keymaps/* /usr/share/keymaps/
sudo localectl set-keymap jp106
sudo localectl set-x11-keymap jp jp106 OADG109A ""

# --- 現セッションに反映 ---
echo "★ 現在のセッションに ibus 設定を反映します"
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
pgrep -x ibus-daemon > /dev/null || ibus-daemon -drx &

# --- 完了メッセージ ---
echo -e "\n\033[1;33m✅ GUI および日本語入力環境のセットアップが完了しました。\nWSL を一度再起動してください。\033[0m"
