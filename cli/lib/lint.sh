#!/usr/bin/env bash
# lint — Wiki 健康检查（9 项确定性检查）
# 注：故意不用 set -e，因为单个检查失败不应中断全部

set -u
set -o pipefail || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

JSON=false
VERBOSE=false
for arg in "$@"; do
  case "$arg" in
    --json) JSON=true ;;
    --verbose|-v) VERBOSE=true ;;
    --help|-h) cat <<EOF
用法: vibe-director lint [--json] [--verbose]

机械式检查 wiki 一致性。9 项检查：
  1. SKILL 合规：5+1 分块结构存在
  2. Index 同步：index.md 路径都存在
  3. Manifest 完整：每集创作剧本目录有 manifest.md
  4. 引用完整性：[[xxx]] 指向的文件存在
  5. 孤儿检测：没人引用的资产
  6. Frozen 一致性：含 .frozen 的版本未被改动（mtime 对比）
  7. Needs-regen 队列：故事板需重生的列表
  8. 草案残留：_pending_changes.md 是否超过 24h
  9. Stub 卡片分组：按 status 分组统计

退出码:
  0    全部通过
  1    有警告项
  2    有错误项
EOF
      exit 0 ;;
  esac
done

WIKI_ROOT="$(find_wiki_root)" || { echo "错误: 找不到 wiki 根目录" >&2; exit 2; }

# 报告数组
REPORT=()
ERRORS=0
WARNINGS=0
PASSES=0

add_pass() { REPORT+=("pass|$1|$2"); PASSES=$((PASSES+1)); }
add_warn() { REPORT+=("warn|$1|$2"); WARNINGS=$((WARNINGS+1)); }
add_err()  { REPORT+=("err|$1|$2"); ERRORS=$((ERRORS+1)); }

# 安全的数组遍历（处理空数组）
iter_report() {
  local sev_filter="$1"
  if [[ ${#REPORT[@]} -eq 0 ]]; then return; fi
  local entry
  for entry in "${REPORT[@]}"; do
    IFS='|' read -r sev cat msg <<< "$entry"
    if [[ "$sev" == "$sev_filter" ]]; then
      case "$sev" in
        pass) out_ok "$cat: $msg" ;;
        warn) out_warn "$cat: $msg" ;;
        err)  out_err "$cat: $msg" ;;
      esac
    fi
  done
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. SKILL 合规
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_skill_compliance() {
  local missing=()
  for dir in 01_资产 02_故事 03_视角 04_剧本 05_视频; do
    [[ -d "$WIKI_ROOT/$dir" ]] || missing+=("$dir")
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    add_pass "SKILL合规" "5+1 分块结构完整"
  else
    add_err "SKILL合规" "缺少目录: ${missing[*]}"
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 2. Index 同步
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_index_sync() {
  local index="$WIKI_ROOT/index.md"
  if [[ ! -f "$index" ]]; then
    add_err "Index" "index.md 不存在"
    return
  fi

  local total=0 missing=0
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    total=$((total+1))
    if [[ ! -e "$WIKI_ROOT/$path" ]]; then
      add_warn "Index" "路径不存在: $path"
      missing=$((missing+1))
    fi
  done < <(grep -oE '`0[0-9]_[^`]+\.(md|png|jpg|mp3|mp4)`' "$index" 2>/dev/null | tr -d '`')

  if [[ $missing -eq 0 ]]; then
    add_pass "Index" "$total/$total 路径有效"
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 3. Manifest 完整性
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_manifest() {
  local creative_dir="$WIKI_ROOT/04_剧本/02_创作剧本"
  [[ -d "$creative_dir" ]] || return 0

  local total=0 missing=0
  local ep_dir
  for ep_dir in "$creative_dir"/*/; do
    [[ -d "$ep_dir" ]] || continue
    if [[ -d "$ep_dir/scenes" ]]; then
      total=$((total+1))
      if [[ ! -f "$ep_dir/manifest.md" ]]; then
        add_warn "Manifest" "缺少: $(basename "$ep_dir")/manifest.md"
        missing=$((missing+1))
      fi
    fi
  done

  if [[ $total -gt 0 && $missing -eq 0 ]]; then
    add_pass "Manifest" "$total/$total 集有 manifest.md"
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 4. 引用完整性
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_references() {
  # 收集所有 wiki 中的 .md 文件名（去后缀）
  local existing_files
  existing_files=$(find "$WIKI_ROOT" -name "*.md" -not -path "*/_versions/*" -not -path "*/_archive/*" -print0 2>/dev/null | \
    xargs -0 -n1 basename 2>/dev/null | sed 's/\.md$//' | sort -u)

  # 收集所有 [[xxx]] 引用（去除 | 后的显示文本，去除转义 \）
  local all_refs
  all_refs=$(grep -rohE '\[\[[^]|]+' "$WIKI_ROOT" --include="*.md" 2>/dev/null | \
    sed 's/^\[\[//; s/\\$//' | sort -u)

  local total=0 broken=0
  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    total=$((total+1))
    if ! echo "$existing_files" | grep -Fxq "$ref"; then
      add_warn "引用" "断链: [[$ref]]"
      broken=$((broken+1))
    fi
  done <<< "$all_refs"

  if [[ $total -gt 0 && $broken -eq 0 ]]; then
    add_pass "引用" "$total/$total 引用有效"
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 5. 孤儿检测
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_orphans() {
  local asset_dir="$WIKI_ROOT/01_资产"
  [[ -d "$asset_dir" ]] || return 0

  # 一次性收集所有引用
  local all_refs_text
  all_refs_text=$(grep -roh '\[\[[^]|]*' "$WIKI_ROOT" --include="*.md" 2>/dev/null | sed 's/^\[\[//; s/\\$//' | sort -u)

  local total=0 orphans=0
  while IFS= read -r asset; do
    [[ -z "$asset" ]] && continue
    local name=$(basename "$asset" .md)
    total=$((total+1))
    if ! echo "$all_refs_text" | grep -Fxq "$name"; then
      add_warn "孤儿" "无引用: $(echo "$asset" | sed "s|$WIKI_ROOT/||")"
      orphans=$((orphans+1))
    fi
  done < <(find "$asset_dir" -name "*.md" -not -path "*/images/*" 2>/dev/null)

  if [[ $total -gt 0 && $orphans -eq 0 ]]; then
    add_pass "孤儿" "$total/$total 资产被引用"
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 6. Frozen 一致性
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_frozen_versions() {
  local wikis_dir
  wikis_dir="$(dirname "$WIKI_ROOT")"
  [[ "$(basename "$wikis_dir")" == "wikis" ]] || return 0

  local ver
  for ver in "$wikis_dir"/*/; do
    [[ -d "$ver" ]] || continue
    if [[ -f "$ver/.frozen" ]]; then
      local newer
      newer=$(find "$ver" -newer "$ver/.frozen" -not -name ".frozen" 2>/dev/null | head -5)
      if [[ -n "$newer" ]]; then
        local count
        count=$(echo "$newer" | wc -l | tr -d ' ')
        add_err "Frozen" "$(basename "$ver") 冻结后 $count 文件被修改（违反硬规则）"
      fi
    fi
  done
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 7. Needs-regen 队列
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_needs_regen() {
  local count
  count=$(grep -rl "needs_regen: true" "$WIKI_ROOT/04_剧本/02_创作剧本" --include="manifest.md" 2>/dev/null | wc -l | tr -d ' ')
  if [[ $count -gt 0 ]]; then
    add_warn "需重生" "$count 集存在 needs_regen 标记的故事板"
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 8. 草案残留
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_pending_drafts() {
  local pending="$WIKI_ROOT/_pending_changes.md"
  [[ -f "$pending" ]] || return 0

  local mtime
  mtime=$(stat -f %m "$pending" 2>/dev/null || stat -c %Y "$pending" 2>/dev/null || echo 0)
  local now=$(date +%s)
  local hours=$(( (now - mtime) / 3600 ))

  if [[ $hours -gt 24 ]]; then
    add_warn "草案" "_pending_changes.md 已 ${hours}h 未执行"
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 9. Stub 卡片分组
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_stub_cards() {
  local stub=0 partial=0 complete=0 with_image=0 unclassified=0
  local card

  while IFS= read -r card; do
    [[ -z "$card" ]] && continue
    local status
    status=$(get_fm_field "$card" "status" 2>/dev/null || echo "")
    case "$status" in
      stub) stub=$((stub+1)) ;;
      partial) partial=$((partial+1)) ;;
      complete) complete=$((complete+1)) ;;
      with-image) with_image=$((with_image+1)) ;;
      *) unclassified=$((unclassified+1)) ;;
    esac
  done < <(find "$WIKI_ROOT/01_资产" -name "*.md" -not -path "*/images/*" 2>/dev/null)

  if [[ $stub -gt 0 ]]; then
    add_warn "Stub" "$stub 个卡片为 stub（建议补全）"
  fi

  if [[ $unclassified -gt 0 ]]; then
    add_pass "卡片状态" "stub=$stub, partial=$partial, complete=$complete, with-image=$with_image, 未标=$unclassified"
  else
    add_pass "卡片状态" "stub=$stub, partial=$partial, complete=$complete, with-image=$with_image"
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 跑所有检查（每个独立，失败不中断其他）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check_skill_compliance || add_err "Lint" "check_skill_compliance 失败"
check_index_sync || add_err "Lint" "check_index_sync 失败"
check_manifest || add_err "Lint" "check_manifest 失败"
check_references || add_err "Lint" "check_references 失败"
check_orphans || add_err "Lint" "check_orphans 失败"
check_frozen_versions || add_err "Lint" "check_frozen_versions 失败"
check_needs_regen || add_err "Lint" "check_needs_regen 失败"
check_pending_drafts || add_err "Lint" "check_pending_drafts 失败"
check_stub_cards || add_err "Lint" "check_stub_cards 失败"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 输出报告
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [[ "$JSON" == true ]]; then
  echo -n "{\"summary\":{\"errors\":$ERRORS,\"warnings\":$WARNINGS,\"passes\":$PASSES},\"items\":["
  first=true
  if [[ ${#REPORT[@]} -gt 0 ]]; then
    for entry in "${REPORT[@]}"; do
      IFS='|' read -r sev cat msg <<< "$entry"
      [[ "$first" == false ]] && echo -n ","
      msg_escaped=$(echo "$msg" | sed 's/"/\\"/g')
      echo -n "{\"severity\":\"$sev\",\"category\":\"$cat\",\"message\":\"$msg_escaped\"}"
      first=false
    done
  fi
  echo "]}"
else
  echo ""
  echo "📋 Wiki 健康检查 — $(date '+%Y-%m-%d %H:%M')"
  echo "   Wiki: $WIKI_ROOT"
  echo ""

  if [[ $PASSES -gt 0 ]]; then
    echo "通过项："
    iter_report "pass"
    echo ""
  fi

  if [[ $WARNINGS -gt 0 ]]; then
    echo "警告项："
    iter_report "warn"
    echo ""
  fi

  if [[ $ERRORS -gt 0 ]]; then
    echo "错误项："
    iter_report "err"
    echo ""
  fi

  echo "汇总: ${PASSES} 通过, ${WARNINGS} 警告, ${ERRORS} 错误"
fi

if [[ $ERRORS -gt 0 ]]; then
  exit 2
elif [[ $WARNINGS -gt 0 ]]; then
  exit 1
else
  exit 0
fi
