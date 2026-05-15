# 资产卡片模板（三档：stub / partial / complete）

> **元数据放文件末尾**（`## 元数据` 表格），不放顶部 frontmatter。
> 这样 Obsidian 不会在文件顶部显示"笔记属性"面板，读者从标题开始读。
> 每张资产卡都有 status 字段标识完成度。

---

## 角色卡

### Stub 模板（自动建卡时用）

```markdown
# {角色名}

> 🌱 Stub 卡片（agent 自动创建）
> 首次出现：第 N 集 P0X / 提及次数：M

## 基本信息

| 字段 | 值 |
|------|-----|
| 角色名 | {名字} |
| 性别 | {从台词推断 / TODO} |
| 年龄 | TODO |
| 角色定位 | {推断} |
| 外貌 | TODO |
| 性格 | TODO |
| 公开身份 | {推断 / TODO} |
| 真实身份 | TODO |
| 入局动机 | TODO |
| 爽点功能 | TODO |

## 出场记录

- 第 N 集 P0X：{简述}
- 第 M 集 P0Y：{...}

## 关系网（推断）

- [[已知角色 X]]——{从台词推断的关系}
- TODO：补全其他关系

---

## 元数据

| 字段 | 值 |
|------|---|
| status | stub |
| 创建时间 | 2026-05-15 |
| 创建方式 | auto-detect |
| 首次出场 | 第 N 集 P0X |
| 提及次数 | M |
| 别名 | — |
```

### Partial 模板（用户填了部分字段）

与 stub 结构相同，但末尾 `## 元数据` 表的 `status` 改为 `partial`。
正文中 TODO 减少。每个已填字段不再写 TODO，未填的保留。

### Complete 模板（参考 character-dev.md）

完整角色信息表 + 弧线 + 关系图 + Mermaid 关系图。
末尾元数据：

```markdown
## 元数据

| 字段 | 值 |
|------|---|
| status | with-image |
| 首次出场 | 第 1 集 |
| 提及次数 | 47 |
| 别名 | Leah Scott |
| 参考图 | `images/leah.png` |
| 音频 | `audio/leah_voice.mp3` |
```

---

## 场景卡

### Stub 模板

```markdown
# {场景名}

> 🌱 Stub 卡片
> 首次出现：第 N 集 P0X / 关键性：{高/中/低}

## 描述（从剧本推断）

- 位置：{推断}
- 状态：{推断}
- 时段：{出场时段}
- 关键视觉元素：
  - {元素 1}
  - {元素 2}

## 故事板用途

- 第 N 集 P0X：{该场景在剧情中的作用}

## 待补全

- 完整外观描述：TODO
- 建筑风格：TODO
- 内部空间布局：TODO

---

## 元数据

| 字段 | 值 |
|------|---|
| status | stub |
| 首次出场 | 第 N 集 P0X |
| 提及次数 | M |
| 关键场景 | true |
| 参考图 | — |
```

### Complete 模板

参考现有场景卡（如"白木教堂"）的标准格式，含历史/建筑/视觉锚点/灯光/出场记录。元数据放末尾。

---

## 道具卡

### Stub 模板

```markdown
# {道具名}

> 🌱 Stub 卡片
> 首次出现：第 N 集 P0X / 情节关键：{是/否}

## 描述（从剧本推断）

- 外观：{简述}
- 用途/功能：{推断}
- 起源：TODO
- 与角色关系：TODO

## 出场记录

- 第 N 集 P0X：{这次的作用}

---

## 元数据

| 字段 | 值 |
|------|---|
| status | stub |
| 首次出场 | 第 N 集 P0X |
| 提及次数 | M |
| 情节关键 | true |
```

---

## 升级机制（stub → partial → complete → with-image）

用户运行 `/补卡 {资产名}` 或 agent 主动提议时，引导填字段。

填完后 agent 用 Edit 工具更新文件末尾 `## 元数据` 表中的 `status` 字段。

---

## status 切换规则

| 切换 | 触发 | 谁做 |
|------|------|------|
| `stub` → `partial` | 关键字段（外貌+性格+定位）填完 | agent 自动 |
| `partial` → `complete` | 所有 TODO 都填了 | agent 自动 |
| 任何 → `with-image` | `/配图` 生成参考图成功 | agent 自动 |
| `complete` → `stub`（降级）| 手动重置 | 用户显式触发 `/重置 {资产名}` |

---

## index.md 中的标识

stub 卡片在 index.md 中标 `(stub)`：

```diff
+ | `01_资产/01_角色/露西·陈.md` | (无图) | 副警长助理，第21集出现，stub |
```

---

## CLI 解析约定

CLI 用 `get_meta_field()` 函数读末尾 `## 元数据` 表：

```bash
get_meta_field "$file" "status"   # 返回 "with-image" 等
```

实现：awk 找到 `## 元数据` 后第一个匹配字段名的表格行，提取值。
不再支持顶部 frontmatter 解析（除 manifest/_patches_applied/api-config/.frozen 外）。

---

## lint 集成

`/lint` 报告按 status 分组：

```
📋 卡片状态分布
🌱 stub: 5 个（3 角色 + 1 场景 + 1 道具）
🌿 partial: 2 个
🌳 complete: 8 个
🎨 with-image: 8 个

🌱 Stub 列表（建议优先补全）：
- 露西·陈 — 已出现 4 次，外貌仍为 TODO
- 废弃图书馆 — 整集核心，无场景细节
```
