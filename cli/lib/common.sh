#!/usr/bin/env bash
# 公共函数库 — 供其他命令 source 使用

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Wiki 定位
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 查找 wiki 根目录
# 优先级：VIBE_WIKI_ROOT 环境变量 > 当前目录的 wiki/ > 当前目录的 wikis/current/ > 当前目录的 wikis/{第一个active} > 报错
find_wiki_root() {
  if [[ -n "${VIBE_WIKI_ROOT:-}" ]]; then
    echo "$VIBE_WIKI_ROOT"
    return 0
  fi

  local cwd
  cwd="$(pwd)"

  # 单 wiki 模式
  if [[ -d "$cwd/wiki" && -f "$cwd/wiki/index.md" ]]; then
    echo "$cwd/wiki"
    return 0
  fi

  # 多版本模式 — 找 current
  if [[ -d "$cwd/wikis" ]]; then
    # current 是软链
    if [[ -L "$cwd/wikis/current" ]]; then
      echo "$(cd "$cwd/wikis/current" && pwd)"
      return 0
    fi
    # current 是文件指针（内含目录名）
    if [[ -f "$cwd/wikis/current" ]]; then
      local target
      target="$(cat "$cwd/wikis/current" | tr -d '[:space:]')"
      if [[ -d "$cwd/wikis/$target" ]]; then
        echo "$cwd/wikis/$target"
        return 0
      fi
    fi
    # 找第一个未冻结的版本
    for dir in "$cwd/wikis"/*/; do
      if [[ -d "$dir" && ! -f "$dir/.frozen" ]]; then
        echo "$(cd "$dir" && pwd)"
        return 0
      fi
    done
  fi

  echo "错误: 找不到 wiki 根目录。请 cd 到项目根，或设置 VIBE_WIKI_ROOT。" >&2
  return 1
}

# 检查路径或其任意祖先是否含 .frozen 文件
# 返回 0 = 冻结，1 = 未冻结
is_frozen_ancestor() {
  local path="$1"
  local abs_path

  if [[ -e "$path" ]]; then
    abs_path="$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
  else
    # 路径不存在时使用 dirname
    local parent_dir="$(dirname "$path")"
    if [[ -d "$parent_dir" ]]; then
      abs_path="$(cd "$parent_dir" && pwd)/$(basename "$path")"
    else
      echo "错误: 路径不存在 $path" >&2
      return 2
    fi
  fi

  local current="$abs_path"
  while [[ "$current" != "/" && "$current" != "." && -n "$current" ]]; do
    if [[ -f "$current/.frozen" ]]; then
      echo "$current/.frozen"
      return 0
    fi
    current="$(dirname "$current")"
  done
  return 1
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Frontmatter 解析（简单 YAML）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 提取文件的 frontmatter（首个 --- ~ --- 之间）
# 用法: extract_frontmatter <file>
extract_frontmatter() {
  local file="$1"
  awk '
    /^---$/ { count++; if(count==1){in_fm=1; next} if(count==2){in_fm=0; exit} next }
    in_fm { print }
  ' "$file"
}

# 从 frontmatter 提取某字段值（顶层简单 key:value）
# 用法: get_fm_field <file> <field>
get_fm_field() {
  local file="$1"
  local field="$2"
  extract_frontmatter "$file" | awk -F': ' -v key="$field" '
    $1 == key { gsub(/^"|"$/, "", $2); print $2; exit }
  '
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 输出辅助
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 是否输出 JSON 格式
JSON_OUT=false
for arg in "$@"; do
  if [[ "$arg" == "--json" ]]; then
    JSON_OUT=true
    break
  fi
done

# 颜色（仅 TTY）
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  YEL='\033[0;33m'
  GRN='\033[0;32m'
  BLU='\033[0;34m'
  NC='\033[0m'
else
  RED=''; YEL=''; GRN=''; BLU=''; NC=''
fi

# 输出辅助
out_err() { echo -e "${RED}✗${NC} $*" >&2; }
out_warn() { echo -e "${YEL}⚠${NC} $*"; }
out_ok() { echo -e "${GRN}✓${NC} $*"; }
out_info() { echo -e "${BLU}ℹ${NC} $*"; }
