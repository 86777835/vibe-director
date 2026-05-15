#!/usr/bin/env bash
# 同步 vibe-director skill 的 README 和 SKILL 到飞书云文档
# 用法: bash sync-feishu.sh [readme|skill|all]

set -e

SKILL_DIR="$HOME/.claude/skills/vibe-director"

# 飞书文档 ID（你的）
README_DOC="HkDUdU04xoA1G1xBLS5caXyMnDe"
SKILL_DOC="Xjb7dWnVMoa34nxd95TcTRrAnuh"

if ! command -v lark-cli >/dev/null 2>&1; then
  echo "错误: lark-cli 未安装。npm install -g @larksuite/cli"
  exit 1
fi

TARGET="${1:-all}"

sync_doc() {
  local file="$1"
  local doc_id="$2"
  local label="$3"

  echo "→ 同步 $label..."
  cd "$SKILL_DIR" && lark-cli docs +update --api-version v2 \
    --doc "$doc_id" \
    --command overwrite \
    --content "@$file" \
    --doc-format markdown \
    --as user --jq '.ok'
}

case "$TARGET" in
  readme) sync_doc "README.md" "$README_DOC" "README" ;;
  skill)  sync_doc "SKILL.md"  "$SKILL_DOC"  "SKILL"  ;;
  all)
    sync_doc "README.md" "$README_DOC" "README"
    sync_doc "SKILL.md"  "$SKILL_DOC"  "SKILL"
    ;;
  *)
    echo "用法: bash sync-feishu.sh [readme|skill|all]"
    exit 2
    ;;
esac

echo "✓ 完成"
echo ""
echo "README: https://guiyi2023.feishu.cn/docx/$README_DOC"
echo "SKILL:  https://guiyi2023.feishu.cn/docx/$SKILL_DOC"
