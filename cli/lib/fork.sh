#!/usr/bin/env bash
# fork — 把当前 active wiki fork 到新版本
# CLI 只做机械操作（复制 + 冻结 + 更新 current 指针 + 写 patches 待应用列表）
# 实际 patch 应用由 agent 通过修改类草案流程在新 wiki 上跑

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

usage() {
  cat <<EOF
用法: vibe-director fork [选项]

把当前 active wiki 复制为新版本（fork）。

选项:
  --from <name>         源版本（默认: current）
  --to <name>           目标版本名（默认: v2.0-YYYYMMDD-HHMM）
  --patches <list>      要应用的 patches，逗号分隔（如 tone-darken,gender-swap）
                        CLI 只记录待应用列表到 _patches_applied.md，不实际修改文件
                        Patch 应用由 agent 通过修改类草案流程完成
  --dry-run             只输出计划，不实际操作
  --json                JSON 输出
  --help                显示帮助

行为:
  1. 找当前 active wiki
  2. 如果还是单 wiki/ 结构 → 自动迁移到 wikis/v1.0_<date>/
  3. 复制源到目标
  4. 源加 .frozen 文件
  5. 目标加 _patches_applied.md（待应用 patches 列表）
  6. 更新 wikis/current 指向目标

示例:
  vibe-director fork --to v2.0a-dark --patches tone-darken
  vibe-director fork --to v3.0-noir --from v1.0_2026-05-14 --patches tone-darken,setting-time-shift
  vibe-director fork --dry-run --to v2.0a-dark
EOF
}

# 参数解析
FROM=""
TO=""
PATCHES=""
DRY_RUN=false
JSON=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) FROM="$2"; shift 2 ;;
    --to) TO="$2"; shift 2 ;;
    --patches) PATCHES="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --json) JSON=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) out_err "未知参数: $1"; usage; exit 2 ;;
  esac
done

# 自动生成 TO 名称
if [[ -z "$TO" ]]; then
  TO="v2.0-$(date +%Y%m%d-%H%M)"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 1: 定位项目根（含 wiki/ 或 wikis/）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CWD="$(pwd)"
PROJECT_ROOT=""

if [[ -d "$CWD/wiki" && -f "$CWD/wiki/index.md" ]]; then
  PROJECT_ROOT="$CWD"
elif [[ -d "$CWD/wikis" ]]; then
  PROJECT_ROOT="$CWD"
else
  # 向上查找
  cur="$CWD"
  while [[ "$cur" != "/" ]]; do
    if [[ -d "$cur/wiki" || -d "$cur/wikis" ]]; then
      PROJECT_ROOT="$cur"
      break
    fi
    cur="$(dirname "$cur")"
  done
fi

if [[ -z "$PROJECT_ROOT" ]]; then
  out_err "找不到项目根（含 wiki/ 或 wikis/）"
  exit 2
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 2: 决定 fork 模式（首次升级 vs 多版本追加）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WIKIS_DIR="$PROJECT_ROOT/wikis"
NEEDS_MIGRATION=false

if [[ ! -d "$WIKIS_DIR" ]]; then
  # 单 wiki 模式，需要迁移
  if [[ -d "$PROJECT_ROOT/wiki" ]]; then
    NEEDS_MIGRATION=true
  else
    out_err "wiki/ 不存在"
    exit 2
  fi
fi

# 确定源 wiki 路径
SOURCE_PATH=""
if [[ "$NEEDS_MIGRATION" == true ]]; then
  # 迁移后源是 v1.0_<date>
  SOURCE_NAME="v1.0_$(date +%Y-%m-%d)"
  SOURCE_PATH="$WIKIS_DIR/$SOURCE_NAME"
else
  # 多版本模式：找指定 from 或 current
  if [[ -z "$FROM" || "$FROM" == "current" ]]; then
    if [[ -L "$WIKIS_DIR/current" ]]; then
      SOURCE_PATH="$(cd "$WIKIS_DIR/current" && pwd)"
      SOURCE_NAME="$(basename "$SOURCE_PATH")"
    elif [[ -f "$WIKIS_DIR/current" ]]; then
      SOURCE_NAME="$(cat "$WIKIS_DIR/current" | tr -d '[:space:]')"
      SOURCE_PATH="$WIKIS_DIR/$SOURCE_NAME"
    else
      out_err "wikis/current 不存在，请显式指定 --from"
      exit 2
    fi
  else
    SOURCE_NAME="$FROM"
    SOURCE_PATH="$WIKIS_DIR/$FROM"
  fi

  if [[ ! -d "$SOURCE_PATH" ]]; then
    out_err "源 wiki 不存在: $SOURCE_PATH"
    exit 2
  fi
fi

TARGET_PATH="$WIKIS_DIR/$TO"

if [[ -d "$TARGET_PATH" ]]; then
  out_err "目标 wiki 已存在: $TARGET_PATH"
  exit 2
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 3: 输出执行计划
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_plan() {
  echo ""
  echo "📋 Fork 计划"
  echo "   项目根: $PROJECT_ROOT"
  if [[ "$NEEDS_MIGRATION" == true ]]; then
    echo "   模式: 首次 fork（启动版本系统）"
    echo "   迁移: wiki/ → wikis/$SOURCE_NAME/"
  else
    echo "   模式: 追加 fork"
  fi
  echo "   源:   $SOURCE_NAME"
  echo "   目标: $TO"
  if [[ -n "$PATCHES" ]]; then
    echo "   待应用 patches: $PATCHES"
    echo "   (CLI 只记录，实际应用由 agent 走草案流程)"
  fi
  echo ""
}

if [[ "$DRY_RUN" == true ]]; then
  if [[ "$JSON" == true ]]; then
    echo "{\"dry_run\":true,\"project_root\":\"$PROJECT_ROOT\",\"needs_migration\":$NEEDS_MIGRATION,\"source\":\"$SOURCE_NAME\",\"source_path\":\"$SOURCE_PATH\",\"target\":\"$TO\",\"target_path\":\"$TARGET_PATH\",\"patches\":\"$PATCHES\"}"
  else
    print_plan
    out_info "[dry-run] 不实际执行"
  fi
  exit 0
fi

# 非 JSON 模式时显示计划
if [[ "$JSON" != true ]]; then
  print_plan
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 4: 执行
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

START_TS=$(date +%s)

# 4a. 首次迁移（如需要）
if [[ "$NEEDS_MIGRATION" == true ]]; then
  [[ "$JSON" != true ]] && out_info "迁移 wiki/ → wikis/$SOURCE_NAME/..."
  mkdir -p "$WIKIS_DIR"
  cp -R "$PROJECT_ROOT/wiki" "$SOURCE_PATH" || { out_err "迁移失败"; exit 3; }
fi

# 4b. 复制源到目标
[[ "$JSON" != true ]] && out_info "复制 $SOURCE_NAME → $TO..."
cp -R "$SOURCE_PATH" "$TARGET_PATH" || { out_err "复制失败"; exit 3; }

# 4c. 给源加 .frozen（如还没有）
if [[ ! -f "$SOURCE_PATH/.frozen" ]]; then
  [[ "$JSON" != true ]] && out_info "冻结 $SOURCE_NAME..."
  cat > "$SOURCE_PATH/.frozen" <<EOF
frozen_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)
frozen_by: vibe-director fork
forked_to: $TO
EOF
fi

# 4d. 给目标写 _patches_applied.md（patches 待应用列表）
[[ "$JSON" != true ]] && out_info "记录 patches 到 $TO/_patches_applied.md..."
cat > "$TARGET_PATH/_patches_applied.md" <<EOF
# Patches 应用记录 — $TO

> Fork 来源: \`$SOURCE_NAME\` (frozen)
> Fork 时间: $(date '+%Y-%m-%d %H:%M:%S')

## 待应用 Patches

EOF

if [[ -n "$PATCHES" ]]; then
  IFS=',' read -ra PATCH_LIST <<< "$PATCHES"
  for p in "${PATCH_LIST[@]}"; do
    p=$(echo "$p" | sed 's/^ *//; s/ *$//')
    echo "- [ ] \`$p\` — pending（agent 通过 §十三.2 草案流程应用）" >> "$TARGET_PATH/_patches_applied.md"
  done
else
  echo "- (无指定 patches，纯复制 fork)" >> "$TARGET_PATH/_patches_applied.md"
fi

cat >> "$TARGET_PATH/_patches_applied.md" <<EOF

---

## 状态

\`pending\` = 已记录但未应用
\`applied\` = agent 已完成草案应用

## 应用方式

Agent 读此文件，对每个 pending patch：
1. 读 \`~/.claude/skills/vibe-director/references/direction-dictionary.md\` 取该 patch 的影响范围
2. 走 §十三.2 修改类草案流程
3. 完成后把 \`[ ]\` 改为 \`[x]\` 并标 status: applied
EOF

# 4e. 更新 wikis/current 指针
[[ "$JSON" != true ]] && out_info "更新 current 指针到 $TO..."
if [[ -L "$WIKIS_DIR/current" ]]; then
  rm "$WIKIS_DIR/current"
fi
if [[ -f "$WIKIS_DIR/current" ]]; then
  rm "$WIKIS_DIR/current"
fi
ln -s "$TO" "$WIKIS_DIR/current" 2>/dev/null || echo "$TO" > "$WIKIS_DIR/current"

# 4f. 如是首次迁移，删除原 wiki/（已经在 wikis/v1.0_* 里）
if [[ "$NEEDS_MIGRATION" == true ]]; then
  [[ "$JSON" != true ]] && out_info "删除原 wiki/（已迁移到 wikis/$SOURCE_NAME/）..."
  rm -rf "$PROJECT_ROOT/wiki"
fi

END_TS=$(date +%s)
ELAPSED=$((END_TS - START_TS))

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 5: 输出结果
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [[ "$JSON" == true ]]; then
  patches_json=""
  if [[ -n "$PATCHES" ]]; then
    IFS=',' read -ra PATCH_LIST <<< "$PATCHES"
    first=true
    patches_json="["
    for p in "${PATCH_LIST[@]}"; do
      p=$(echo "$p" | sed 's/^ *//; s/ *$//')
      [[ "$first" == false ]] && patches_json+=","
      patches_json+="\"$p\""
      first=false
    done
    patches_json+="]"
  else
    patches_json="[]"
  fi

  cat <<EOF
{"status":"success","elapsed_sec":$ELAPSED,"migration":$NEEDS_MIGRATION,"source":"$SOURCE_NAME","source_path":"$SOURCE_PATH","target":"$TO","target_path":"$TARGET_PATH","patches_pending":$patches_json,"current":"$TO"}
EOF
else
  echo ""
  out_ok "Fork 完成（耗时 ${ELAPSED}s）"
  echo ""
  echo "   现状:"
  echo "   - wikis/$SOURCE_NAME/  (frozen, read-only)"
  echo "   - wikis/$TO/           (active)"
  echo "   - wikis/current → $TO"
  echo ""
  if [[ -n "$PATCHES" ]]; then
    echo "   下一步: agent 读 $TO/_patches_applied.md，走草案流程应用 patches"
  else
    echo "   下一步: 在 $TO 中开始工作（与 $SOURCE_NAME 完全相同的内容）"
  fi
fi
