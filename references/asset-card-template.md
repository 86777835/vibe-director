# 资产卡片模板（三档：stub / partial / complete）

> 每张资产卡都有 status 字段标识完成度。Agent 根据触发场景选择对应模板创建/升级。

---

## 角色卡

### Stub 模板（自动建卡时用）

```markdown
---
status: stub
created_at: 2026-05-15
created_by: auto-detect
first_appearance: 第N集 P0X
mention_count: 2
aliases: []
---

# {角色名}

> 🌱 Stub 卡片（agent 自动创建）
> 首次出现：第 N 集 P0X / 提及次数：M

## 基本信息
| 字段 | 值 |
|------|-----|
| 角色名 | {名字} |
| 性别 | {从台词推断 / TODO} |
| 年龄 | TODO |
| 角色定位 | {从剧本推断，如"副警长助理" / TODO} |
| 外貌 | TODO |
| 性格 | TODO |
| 公开身份 | {推断 / TODO} |
| 真实身份 | TODO |
| 入局动机 | TODO |
| 爽点功能 | TODO |

## 出场记录
- 第 N 集 P0X：{简述这次出场做了什么}
- 第 M 集 P0Y：{...}

## 关系网（推断）
- [[已知角色 X]]——{从台词推断的关系}
- TODO：补全其他关系

---
*此卡片为 stub。要补全请说"补全 {角色名}"。补全外貌后可用 /配图 {角色名} 生成参考图。*
```

### Partial 模板（用户填了部分字段）

与 stub 相同结构，但 status 改为 `partial`，TODO 减少。每个**已填**字段不再写 TODO，每个**未填**字段保留 TODO。

### Complete 模板（参考 character-dev.md）

参考 `references/character-dev.md` 的完整角色信息表 + 弧线 + 关系图。status 改为 `complete`。

如果还有参考图：
```yaml
---
status: with-image
---
```

---

## 场景卡

### Stub 模板

```markdown
---
status: stub
created_at: 2026-05-15
created_by: auto-detect
first_appearance: 第N集 P0X
mention_count: 1
key_scene: true|false  # 是否为剧本明确标的核心场景
---

# {场景名}

> 🌱 Stub 卡片
> 首次出现：第 N 集 P0X / 提及次数：M / 关键性：{高/中/低}

## 描述（从剧本推断）
- 位置：{从剧本推断}
- 状态：{推断}
- 时段：{出场时的时间，如"暴风雪夜"}
- 关键视觉元素（从剧本提取）：
  - {元素 1}
  - {元素 2}

## 故事板用途
- 第 N 集 P0X：{该场景在剧情中的作用}

## 待补全
- 完整外观描述：TODO
- 建筑风格：TODO
- 内部空间布局：TODO
- 历史/背景：TODO

---
*此卡片为 stub。补全后可用 /配图 {场景名} 生成参考图。*
```

### Complete 模板

参考现有场景卡（如"白木教堂"）的标准格式，含历史/建筑/视觉锚点/灯光/出场记录等完整字段。

---

## 道具卡

### Stub 模板

```markdown
---
status: stub
created_at: 2026-05-15
created_by: auto-detect
first_appearance: 第N集 P0X
mention_count: 1
plot_critical: true|false
---

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
*此卡片为 stub。要补全请说"补全 {道具名}"。*
```

---

## 升级机制（stub → partial → complete → with-image）

用户运行 `/补卡 {资产名}` 或 agent 主动提议时，引导填字段：

```
agent：露西·陈 现在是 stub，要补全。我按重要性顺序问：

1. 外貌：发色/眼色/肤色/体型？
2. 性格：3 个核心词？
3. 入局动机：她为什么参加银月审判（如果参加）？
4. 与凯文的关系（除了"助理"）？
5. 爽点功能：她在剧情中起什么戏剧作用？

你可以一次回答全部，或者一个一个来。也可以说"跳过 X"。
```

用户答完关键字段（外貌+性格+定位）→ status 升到 `partial`
全部字段答完 → status 升到 `complete`
跑 `/配图` 生成参考图后 → 加 `with-image` 标签

---

## status 切换规则

| 切换 | 触发 | 谁做 |
|------|------|------|
| `stub` → `partial` | 关键字段（外貌+性格+定位）填完 | agent 自动 |
| `partial` → `complete` | 所有 TODO 都填了 | agent 自动 |
| 任何 → `with-image` | `/配图` 生成参考图成功 | agent 自动 |
| `complete` → `stub`（降级）| 手动重置 | 用户显式触发 `/重置 {资产名}` |

降级用于：用户大改资产，旧字段全部作废，重新走 stub → partial → complete 流程。

---

## index.md 中的标识

stub 卡片在 index.md 中标 `(stub)`：

```diff
+ | `01_资产/01_角色/露西·陈.md` | (无图) | 副警长助理，第21集出现，stub |
```

agent 读 index 时立刻知道这是 stub，规划任务时考虑"先补全"或"用 stub 直接做"。

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
- 古老药剂瓶 — 情节关键，无外观描述
...
```
