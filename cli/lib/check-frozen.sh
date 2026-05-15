#!/usr/bin/env bash
# check-frozen <path>
# 检查路径或其任意祖先是否含 .frozen 文件
# 返回:
#   exit 0 + JSON {"frozen": false} 如果可写
#   exit 1 + JSON {"frozen": true, "marker": "..."} 如果冻结

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

usage() {
  cat <<EOF
用法: vibe-director check-frozen <path> [--json]

检查路径或其任意祖先目录是否含 .frozen 文件。
.frozen 文件标记 wiki 版本为只读，任何 Edit/Write 应被拒绝。

参数:
  <path>    要检查的文件或目录路径
  --json    输出 JSON 格式

退出码:
  0    路径可写（无 .frozen 祖先）
  1    路径冻结（有 .frozen 祖先）
  2    错误（路径不存在等）

示例:
  vibe-director check-frozen wiki/01_资产/01_角色/艾拉拉.md
  vibe-director check-frozen wikis/v1.0_2026-05-14/index.md  # 应该返回 frozen
EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 2
fi

TARGET=""
JSON=false
for arg in "$@"; do
  case "$arg" in
    --json) JSON=true ;;
    --help|-h) usage; exit 0 ;;
    *) TARGET="$arg" ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  out_err "缺少 path 参数"
  usage
  exit 2
fi

# 检查冻结（区分 0/1/2 三种状态）
set +e
marker=$(is_frozen_ancestor "$TARGET" 2>&1)
status=$?
set -e

case $status in
  0)
    if [[ "$JSON" == true ]]; then
      echo "{\"frozen\":true,\"path\":\"$TARGET\",\"marker\":\"$marker\"}"
    else
      out_err "FROZEN: $TARGET"
      echo "  原因: 发现 .frozen 标记于 $marker"
      echo "  建议: 切换到 active 版本，或 'vibe-director unfreeze' 显式解冻"
    fi
    exit 1
    ;;
  1)
    if [[ "$JSON" == true ]]; then
      echo "{\"frozen\":false,\"path\":\"$TARGET\"}"
    else
      out_ok "可写: $TARGET"
    fi
    exit 0
    ;;
  *)
    if [[ "$JSON" == true ]]; then
      echo "{\"error\":\"path not found\",\"path\":\"$TARGET\"}"
    else
      out_err "$marker"
    fi
    exit 2
    ;;
esac
