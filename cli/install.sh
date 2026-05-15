#!/usr/bin/env bash
# 安装脚本：把 vibe-director CLI 链接到 ~/.local/bin

set -e

CLI_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/vibe-director"
BIN_DIR="$HOME/.local/bin"
LINK_PATH="$BIN_DIR/vibe-director"

if [[ ! -f "$CLI_PATH" ]]; then
  echo "错误: 找不到 CLI 主脚本 $CLI_PATH"
  exit 1
fi

mkdir -p "$BIN_DIR"

if [[ -L "$LINK_PATH" ]]; then
  echo "已存在软链，覆盖..."
  rm "$LINK_PATH"
elif [[ -e "$LINK_PATH" ]]; then
  echo "错误: $LINK_PATH 已存在且不是软链。请手动处理。"
  exit 2
fi

ln -s "$CLI_PATH" "$LINK_PATH"
chmod +x "$CLI_PATH"
chmod +x "$(dirname "$CLI_PATH")/lib/"*.sh

# 静默成功（顶层 install.sh 负责终端提示）
# 若直接调用本脚本（非顶层），输出简短提示
if [[ -z "${VIBE_INSTALLER_PARENT:-}" ]]; then
  echo "✓ CLI 安装完成: $LINK_PATH"
  if ! echo "$PATH" | tr ':' '\n' | grep -Fxq "$BIN_DIR"; then
    echo "  ⚠ $BIN_DIR 不在 PATH。把这行加到 shell rc:"
    echo "      export PATH=\"\$HOME/.local/bin:\$PATH\""
  fi
fi
