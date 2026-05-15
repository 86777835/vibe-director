#!/usr/bin/env bash
# scan <file> — 扫描文件，对比 wiki 已知实体
# 输出：已知实体出现统计 + [[]] 引用列表，供 agent 判断哪些是新实体

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

usage() {
  cat <<EOF
用法: vibe-director scan <file> [--json]

扫描一个 markdown 文件（通常是剧本），输出：
  - 已知 wiki 实体在该文件的出现次数
  - 文件中 [[xxx]] 引用的实体列表
  - 候选新实体（命名模式匹配 + 不在已知列表）

设计目标：机械式提供数据，由 agent 决策"哪些应该建 stub 卡"。

参数:
  <file>    要扫描的 .md 文件路径
  --json    JSON 输出

示例:
  vibe-director scan wiki/04_剧本/01_文学剧本/第21集.md
  vibe-director scan wiki/04_剧本/01_文学剧本/第21集.md --json
EOF
}

JSON=false
FILE=""
for arg in "$@"; do
  case "$arg" in
    --json) JSON=true ;;
    --help|-h) usage; exit 0 ;;
    *) FILE="$arg" ;;
  esac
done

if [[ -z "$FILE" ]]; then
  out_err "缺少 file 参数"
  usage
  exit 2
fi

if [[ ! -f "$FILE" ]]; then
  out_err "文件不存在: $FILE"
  exit 2
fi

WIKI_ROOT="$(find_wiki_root)" || { out_err "找不到 wiki 根"; exit 2; }

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 1: 收集 wiki 已知实体列表
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 已知角色/场景/道具（从文件名）
KNOWN_ASSETS=$(find "$WIKI_ROOT/01_资产" -name "*.md" -not -path "*/images/*" 2>/dev/null | \
  xargs -n1 basename 2>/dev/null | sed 's/\.md$//' | sort -u)

# 收集已知实体的别名（从 frontmatter aliases 字段）
# 用临时文件存储（bash 3.2 无 declare -A）
ALIASES_FILE=$(mktemp -t vibe-aliases.XXXXXX)
trap "rm -f $ALIASES_FILE" EXIT

while IFS= read -r asset; do
  [[ -z "$asset" ]] && continue
  local_name=$(basename "$asset" .md)
  aliases_line=$(get_field "$asset" "别名" 2>/dev/null || echo "")
  # 兼容：旧的 frontmatter 也可能用 aliases 字段
  [[ -z "$aliases_line" ]] && aliases_line=$(get_fm_field "$asset" "aliases" 2>/dev/null || echo "")
  if [[ -n "$aliases_line" ]]; then
    cleaned=$(echo "$aliases_line" | tr -d '[]' | tr ',' '\n')
    while IFS= read -r alias; do
      alias=$(echo "$alias" | sed 's/^ *//; s/ *$//')
      [[ -n "$alias" ]] && echo "$alias" >> "$ALIASES_FILE"
    done <<< "$cleaned"
  fi
done < <(find "$WIKI_ROOT/01_资产" -name "*.md" -not -path "*/images/*" 2>/dev/null)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 2: 统计文件中已知实体出现次数
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 输出: name|count|path
KNOWN_PRESENT=()
while IFS= read -r name; do
  [[ -z "$name" ]] && continue
  count=$(grep -oF "$name" "$FILE" 2>/dev/null | wc -l | tr -d ' ')
  if [[ $count -gt 0 ]]; then
    # 找到这个名字对应的文件路径
    path=$(find "$WIKI_ROOT/01_资产" -name "${name}.md" -not -path "*/images/*" 2>/dev/null | head -1 | sed "s|$WIKI_ROOT/||")
    KNOWN_PRESENT+=("$name|$count|$path")
  fi
done <<< "$KNOWN_ASSETS"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 3: 提取文件中的 [[xxx]] 引用
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EXISTING_REFS=$(grep -ohE '\[\[[^]|]+' "$FILE" 2>/dev/null | sed 's/^\[\[//; s/\\$//' | sort -u)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 4: 候选新实体（启发式：中文名字模式 X·Y）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 提取所有带 · 的词组（典型中文名字）
CANDIDATE_NAMES=$(grep -oE '[[:alnum:]·]+·[[:alnum:]·]+' "$FILE" 2>/dev/null | sort -u)

CANDIDATES_NEW=()
while IFS= read -r cand; do
  [[ -z "$cand" ]] && continue
  # 跳过已知
  if echo "$KNOWN_ASSETS" | grep -Fxq "$cand"; then
    continue
  fi
  # 跳过别名
  if grep -Fxq "$cand" "$ALIASES_FILE" 2>/dev/null; then
    continue
  fi
  # 统计出现次数
  count=$(grep -oF "$cand" "$FILE" | wc -l | tr -d ' ')
  CANDIDATES_NEW+=("$cand|$count")
done <<< "$CANDIDATE_NAMES"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 输出
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [[ "$JSON" == true ]]; then
  echo -n "{\"file\":\"$FILE\",\"wiki_root\":\"$WIKI_ROOT\",\"known_entities_present\":["
  first=true
  for entry in "${KNOWN_PRESENT[@]:-}"; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r name count path <<< "$entry"
    [[ "$first" == false ]] && echo -n ","
    echo -n "{\"name\":\"$name\",\"count\":$count,\"path\":\"$path\"}"
    first=false
  done
  echo -n "],\"existing_wikilinks\":["
  first=true
  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    [[ "$first" == false ]] && echo -n ","
    echo -n "\"$ref\""
    first=false
  done <<< "$EXISTING_REFS"
  echo -n "],\"candidate_new\":["
  first=true
  for entry in "${CANDIDATES_NEW[@]:-}"; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r name count <<< "$entry"
    [[ "$first" == false ]] && echo -n ","
    echo -n "{\"name\":\"$name\",\"count\":$count}"
    first=false
  done
  echo "]}"
else
  echo ""
  echo "📋 扫描: $FILE"
  echo "   Wiki: $WIKI_ROOT"
  echo ""
  echo "🟢 已知实体在文件中的出现:"
  if [[ ${#KNOWN_PRESENT[@]} -eq 0 ]]; then
    echo "   (无)"
  else
    # 按出现次数倒序
    for entry in "${KNOWN_PRESENT[@]}"; do
      IFS='|' read -r name count path <<< "$entry"
      printf "   %3d × %s (%s)\n" "$count" "$name" "$path"
    done | sort -rn
  fi
  echo ""
  echo "🔗 文件中的 [[wikilink]] 引用:"
  if [[ -z "$EXISTING_REFS" ]]; then
    echo "   (无)"
  else
    while IFS= read -r ref; do
      [[ -z "$ref" ]] && continue
      echo "   - [[$ref]]"
    done <<< "$EXISTING_REFS"
  fi
  echo ""
  echo "🟡 候选新实体 (X·Y 命名模式 + 不在 wiki):"
  if [[ ${#CANDIDATES_NEW[@]} -eq 0 ]]; then
    echo "   (无)"
  else
    for entry in "${CANDIDATES_NEW[@]}"; do
      IFS='|' read -r name count <<< "$entry"
      printf "   %3d × %s\n" "$count" "$name"
    done | sort -rn
  fi
  echo ""
  echo "💡 提示: 候选新实体由 agent 进一步判断（阈值: 出现 ≥ 2 次）"
  echo "    建 stub: vibe-director scan ... --json | agent 处理"
fi
