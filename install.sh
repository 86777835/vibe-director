#!/usr/bin/env bash
# vibe-director 一键安装脚本
# 用法: curl -fsSL https://raw.githubusercontent.com/86777835/vibe-director/main/install.sh | bash
#       或本地: bash install.sh

set -e

REPO_URL="https://github.com/86777835/vibe-director.git"
RAW_BASE="https://raw.githubusercontent.com/86777835/vibe-director/main"
TARBALL_URL="https://github.com/86777835/vibe-director/archive/refs/heads/main.tar.gz"
INSTALL_DIR="$HOME/.claude/skills/vibe-director"

# 颜色（TTY 时）
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GRN='\033[0;32m'; YEL='\033[1;33m'; BLU='\033[0;34m'; NC='\033[0m'
else
  RED=''; GRN=''; YEL=''; BLU=''; NC=''
fi

info() { echo -e "${BLU}→${NC} $*"; }
ok()   { echo -e "${GRN}✓${NC} $*"; }
warn() { echo -e "${YEL}⚠${NC} $*"; }
err()  { echo -e "${RED}✗${NC} $*" >&2; }

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Banner
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cat <<'EOF'

╔════════════════════════════════════════════════╗
║       vibe-director — 短剧 VibeDirector skill   ║
║       https://github.com/86777835/vibe-director ║
╚════════════════════════════════════════════════╝

EOF

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. 系统检查
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

info "检查环境..."

# OS
case "$(uname -s)" in
  Darwin) ok "macOS 检测通过" ;;
  Linux)  ok "Linux 检测通过" ;;
  *) warn "未测试的系统: $(uname -s)，可能有兼容性问题" ;;
esac

# Bash 版本
BASH_MAJOR="${BASH_VERSION%%.*}"
if [[ -z "$BASH_MAJOR" || "$BASH_MAJOR" -lt 3 ]]; then
  err "需要 bash 3.0+（当前: ${BASH_VERSION:-未知}）"
  exit 1
fi
ok "bash $BASH_VERSION"

# 下载工具
HAS_GIT=false
HAS_CURL=false
command -v git  >/dev/null 2>&1 && HAS_GIT=true
command -v curl >/dev/null 2>&1 && HAS_CURL=true

if ! $HAS_GIT && ! $HAS_CURL; then
  err "需要 git 或 curl 才能下载"
  exit 1
fi

if $HAS_GIT; then
  ok "git 可用（推荐）"
else
  ok "curl 可用"
fi

# Claude Code（可选）
if command -v claude >/dev/null 2>&1; then
  ok "Claude Code 已安装"
else
  warn "Claude Code 未检测到（skill 需要它才能用，但不影响本次安装）"
  echo "    安装: https://docs.claude.com/claude-code"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 2. 检查是否已安装（升级流程）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ACTION="install"

if [[ -d "$INSTALL_DIR" ]]; then
  warn "已存在: $INSTALL_DIR"

  # 非交互（管道）时默认升级
  if [[ ! -t 0 ]]; then
    info "(非交互模式) 自动升级"
    ACTION="upgrade"
  else
    echo ""
    echo "  [u] 升级（保留本地修改，git pull 或重新下载）"
    echo "  [r] 重装（备份现有到 .bak，然后干净安装）"
    echo "  [c] 取消"
    echo ""
    read -p "选择 [u/r/c]: " -n 1 -r choice
    echo ""
    case "$choice" in
      u|U) ACTION="upgrade" ;;
      r|R) ACTION="reinstall" ;;
      *) info "取消"; exit 0 ;;
    esac
  fi
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 3. 备份（如果重装）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [[ "$ACTION" == "reinstall" ]]; then
  BACKUP_DIR="$INSTALL_DIR.bak.$(date +%Y%m%d-%H%M%S)"
  info "备份现有到 $BACKUP_DIR"
  mv "$INSTALL_DIR" "$BACKUP_DIR"
  ok "备份完成"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 4. 下载/更新
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

mkdir -p "$(dirname "$INSTALL_DIR")"

if [[ "$ACTION" == "upgrade" && -d "$INSTALL_DIR/.git" ]]; then
  info "升级（git pull）..."
  (cd "$INSTALL_DIR" && git pull --ff-only 2>&1 | grep -v "^From " | head -5) || {
    warn "git pull 失败，可能有本地修改。手动 cd $INSTALL_DIR && git status 查看"
    exit 1
  }
  ok "升级完成"
elif $HAS_GIT && [[ "$ACTION" != "upgrade" ]]; then
  info "git clone $REPO_URL ..."
  git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" 2>&1 | tail -3
  ok "克隆完成"
else
  # curl + tarball 备选
  info "curl 下载 tarball..."
  TMPFILE=$(mktemp)
  trap "rm -f $TMPFILE" EXIT
  curl -fsSL "$TARBALL_URL" -o "$TMPFILE"
  info "解压..."
  TMPDIR=$(mktemp -d)
  tar -xzf "$TMPFILE" -C "$TMPDIR"
  if [[ -d "$INSTALL_DIR" ]]; then rm -rf "$INSTALL_DIR"; fi
  mv "$TMPDIR/vibe-director-main" "$INSTALL_DIR"
  rm -rf "$TMPDIR"
  ok "下载完成"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 5. 安装 CLI（软链到 ~/.local/bin）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

info "安装 CLI..."
if [[ -f "$INSTALL_DIR/cli/install.sh" ]]; then
  VIBE_INSTALLER_PARENT=1 bash "$INSTALL_DIR/cli/install.sh"
  ok "CLI 软链到 ~/.local/bin/vibe-director"
else
  warn "找不到 cli/install.sh，跳过 CLI 安装"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 6. PATH 检查（提示加 ~/.local/bin）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BIN_DIR="$HOME/.local/bin"
if ! echo "$PATH" | tr ':' '\n' | grep -Fxq "$BIN_DIR"; then
  warn "$BIN_DIR 不在 PATH 中"
  echo ""

  # 检测 shell rc 文件
  RC_FILE=""
  case "${SHELL:-}" in
    */zsh)  RC_FILE="$HOME/.zshrc" ;;
    */bash) RC_FILE="$HOME/.bashrc" ;;
    *) RC_FILE="$HOME/.profile" ;;
  esac

  echo "    建议加到 $RC_FILE:"
  echo "      export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
  echo "    或者用绝对路径调用:"
  echo "      ~/.claude/skills/vibe-director/cli/vibe-director version"
fi

echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 7. 成功提示
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cat <<EOF
${GRN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GRN}✓ vibe-director 安装完成${NC}
${GRN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

安装位置: $INSTALL_DIR
CLI 位置: ~/.local/bin/vibe-director（如不在 PATH 请加上）

${BLU}下一步:${NC}
  1. ${YEL}重启 Claude Code${NC}（让 skill 注册）
  2. 进项目目录: cd ~/Documents/your-drama
  3. 启动 claude，说"我想做一部短剧"
  4. 或先看 CLI 文档: vibe-director help

${BLU}文档:${NC}
  - 操作手册: cat $INSTALL_DIR/README.md
  - 完整 SKILL: cat $INSTALL_DIR/SKILL.md
  - GitHub:    https://github.com/86777835/vibe-director

EOF
