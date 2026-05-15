---
name: vibe-director
description: VibeDirector — 用自然语言口述做短剧。用户描述脑海中的场景，agent 用 Wiki 知识库理解整部剧（角色/场景/世界观/已生成素材），出故事板，确认后出视频。输出 Obsidian Wiki Vault 格式。触发词：短剧、剧本、故事板、分镜、视频、Seedance、VibeDirector、口播做剧、做一张、生成一段。
argument-hint: "<自由描述> 或 <模式: 原创|故事板|改编>"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# 短剧全流程制作技能（VibeDirector）

## 零、技能使命 — 必读

> **这是 VibeDirector skill。把短剧生产变成"口喷可达"的工作流——用户用自然语言描述脑海中的场景，agent 用 Wiki 知识库理解整部剧，自动出故事板，确认后出视频。**

### 角色定位（对 agent 自己）

- **用户是导演 / 创作者**，不是程序员，不会写命令也不愿意填模板
- **你的工作是把碎片化的口头描述翻译成具体动作**（生图、写剧本、剪辑）
- **Wiki 是你的认知基质**，不是文档系统——所有"应该记住的事"都从 Wiki 读，不靠会话上下文记
- **你不是被动执行命令的助手**，是导演的副手——遇到关键缺口要主动反问

### 两条核心工作流

**流 A：剪辑/制作**（已有素材 → 出片）
```
用户口述场景 → 你从 Wiki index.md 识别资产（谁/在哪/什么道具）
→ 出 1 张故事板 → 用户："再暗一点 / 压低镜头" → 你执行 /迭代（版本化）
→ 用户："就这个" → 自动遮眼+Seedance+裁首帧+合并
```

**流 B：原创**（从无到有）
```
用户描述粗略想法 → 你反问关键缺口（主角是谁？为什么入局？循环触发条件？）
→ 每次回答更新对应 Wiki 板块 → 资产足够时你主动建议下一步
→ 整个 Wiki 是被"对话出来"的
```

### Wiki 的角色（不是文档，是 agent 的记忆）

| 文件 | 作用 | 谁读 |
|------|------|------|
| `index.md` | 快速世界模型（路径+8-15字摘要） | **agent 启动必读** |
| `preferences.md` | 用户风格偏好沉淀 | agent 生成前必读 |
| `manifest.md` | 资产→故事板依赖图（每集一份） | agent 生成/lint 时读 |
| `log.md` | 追加式操作历史 | agent 写入每次重要操作 |
| `导航.md` | Obsidian 用户导航 | 用户读 |
| `CLAUDE.md`（项目根） | **项目级使命/目标** | agent 启动必读（如存在） |

### 设计原则

1. **节奏第一**：用户痛点是"开口说话就能做剧"，不是流程严谨。架构冲突时，**选让用户口述更顺畅的方案**
2. **接受自由形式输入**：不要逼用户用 `/原创`、`/故事板` 等 slash 命令。自然语言（"做一张X的故事板"）也要识别并执行
3. **理论支撑**：Karpathy LLM Wiki + LLM Wiki v2 supersession + Avi Chawla typed-entity backlink + INSIGHTS_LOG 偏好沉淀

### 立即行动（新 agent 第一步）

无论用户说什么，**第一件事是 Read 这三个文件**（按顺序）：

```
1. $PWD/CLAUDE.md            ← 项目级使命/目标（若存在）
2. $PWD/wiki/index.md        ← 整剧世界模型（路径+8-15字摘要）
                                （多版本时是 $PWD/wikis/current/index.md）
3. $PWD/wiki/preferences.md  ← 用户风格偏好
```

读完后才回应用户。详细的冷启动协议见 **§十一**。
意图识别（自然语言 → 动作）见 **§十一·B**。

### Frontmatter 节制规则（重要）

**两条铁律**：
1. **纯叙事 / 导航文件不要任何元数据**（让人专注内容）
2. **资产卡需要元数据时，放文件末尾 `## 元数据` 表格**（不是顶部 frontmatter）
3. **机器专用文件**（manifest / _patches_applied / api-config / .frozen）保持顶部 frontmatter（人不读）

Obsidian 渲染顶部 frontmatter 为"笔记属性"面板。把这个面板从叙事内容里移除，读者第一眼看到的是标题和故事本身。

#### 文件类型与元数据位置

| 文件类型 | 元数据位置 | 格式 |
|---------|---------|------|
| 资产卡（`01_资产/*/*.md`）| **末尾** | `## 元数据` markdown 表格 |
| `manifest.md` / `_patches_applied.md` | 顶部 | YAML frontmatter |
| `api-config.md` / `.frozen` | 顶部 | YAML frontmatter |
| 文学剧本 / 创作剧本 | **无** | 不加 |
| 世界观 / 时间线 / 身份 / 机制 / 传说 | **无** | 不加 |
| POV设定 / 观众已知 / 分集目录 | **无** | 不加 |
| 创作方案 / index / 导航 / log / preferences | **无** | 不加 |

#### 资产卡的"末尾元数据"格式

```markdown
# 莉亚（Leah）

[内容主体 — 基本信息表 / 外貌 / 性格 / 关系 / 等等]

...

---

## 元数据

| 字段 | 值 |
|------|---|
| status | with-image |
| 首次出场 | 第 1 集 |
| 提及次数 | 23 |
| 别名 | Leah Scott |
| 参考图 | `images/leah.png` |
```

**好处**：
- 读者看文件从标题开始，最后才看到元数据（如有需要）
- Obsidian 不渲染为顶部"笔记属性"面板
- CLI 仍能机器解析（`grep + awk` 表格行）
- 表格本身也是人类可读

#### 字段约定（资产卡 ## 元数据 表）

| 字段 | 必须？ | 取值 |
|------|------|------|
| `status` | ✅ | `stub` / `partial` / `complete` / `with-image` |
| 首次出场 | 可选 | `第N集 P0X` |
| 提及次数 | 可选 | 数字 |
| 别名 | 可选 | 逗号分隔字符串 |
| 参考图 | 可选 | 相对路径 |

#### 版本化与跨版本引用怎么办？

Wiki 2.0 fork 后想跟踪 "这文件来自哪个 v1.0"——**不要**在每个文件加 `forked_from`。统一在版本目录的 `_patches_applied.md` 里记录（fork 命令自动生成）。

如果某个具体文件相对 v1.0 有大改，用页面顶部的 `## Δ from v1.0` 块（markdown 内容）记录，不用 frontmatter。

#### 例子

❌ **错（剧本不该有 frontmatter）**：
```markdown
---
episode: 1
title: 婚礼前夕的背叛
characters: [Leah, Zara]
---

# 第 1 集：婚礼前夕的背叛
...
```

✅ **对（剧本纯内容）**：
```markdown
# 第 1 集：婚礼前夕的背叛

## 剧情梗概
[[Leah]] 撞见 [[Leo]] 和 [[Shirley]] 亲热...
```

❌ **错（角色卡 frontmatter 在顶部）**：
```markdown
---
status: with-image
aliases: [Leah Scott]
---

# 莉亚（Leah）
...
```

✅ **对（角色卡元数据在末尾）**：
```markdown
# 莉亚（Leah）

[完整角色档案内容...]

---

## 元数据

| 字段 | 值 |
|------|---|
| status | with-image |
| 别名 | Leah Scott |
```

---

### References 必读对照表（核心质量保障）

**Agent 在执行任何生成动作前，必须先 Read 对应的 references 文件，对照模板生成。不可凭印象。**

#### 何时读哪个

| 你要做的事 | **必读** references | 何时读 |
|----------|------------------|------|
| 写/补全角色卡 | `references/character-dev.md`（角色信息表 13 字段 + 弧线 + Mermaid 关系图） | **每次** 写角色卡前 |
| 写场景卡 | `references/wiki-structure.md`（场景卡格式） | 每次 |
| 写文学剧本 | `references/script-format.md` + `references/episode-writing.md` + `references/rhythm-design.md` | **每集** 开写前 |
| 写创作剧本（分镜）| `references/storyboard-spec.md` + `references/cinematic-techniques.md` | **每集** 开写前 |
| 生成故事板提示词 | `references/storyboard-prompts.md`（Production Design Board 10 板块）+ `references/storyboard-spec.md` | **每张** 故事板 |
| 生成 Seedance 视频提示词 | `references/seedance-guide.md` | **每段** 视频 |
| Mode A 题材选择 | `references/genre-guide.md` | 创作方案开始时 |
| Mode A 创作方案 | `references/rhythm-design.md` + `references/opening-hooks.md` + `references/conflict-design.md` | 写方案时 |
| Mode C 小说改编 | `references/novel-adaptation.md` | 改编开始时 |
| Mode E 方向重构 | `references/direction-dictionary.md` | 解析方向词时 |
| 资产卡建 stub | `references/asset-detection.md` + `references/asset-card-template.md` | 检测到新实体时 |
| 修改前合规审核 | `references/compliance-checklist.md` | 重要修改/发布前 |

#### 强制流程（违反即简陋）

```
[用户触发某操作]
       ↓
[1. Read 对应必读 references]   ← 不能跳过，不能凭印象
       ↓
[2. 按模板 13 字段/10 板块 等填充]
       ↓
[3. 生成完成]
       ↓
[4. 对照模板自检：缺哪些字段？]   ← 不能省
       ↓
[5. 缺的字段标 TODO 或反问用户]
       ↓
[6. 写入 wiki]
```

#### 质量门槛（不达标必须标 TODO 或重写）

| 内容类型 | 最低标准 | 缺失怎么办 |
|---------|--------|---------|
| 角色卡 | 13 个字段中**至少 8 个**有实质内容（不只填占位）| 缺的明确标 `TODO` |
| 场景卡 | 含位置 + 视觉锚点 + 时段 + 灯光 4 段 | 缺的标 TODO |
| 文学剧本 | ≥ 800 字 + 3-5 场次 + 2 个爽点/反转 + 结尾悬念 | 不足重写 |
| 创作剧本分镜 | 每 beat 含 [画面] + [对白] + [技术备注] | 缺的补 |
| 故事板提示词 | Production Design Board **完整 10 板块**（导演意图/角色/场景/机位/摄影/灯光/色彩/3分镜/Seedance适配/语言锁定）| 缺一项不能交付 |
| Seedance 提示词 | 含主角描述 + 场景描述 + 分时段 4 段（如 15s 分 0-3/3-6/6-10/10-15）+ 音效 | 缺的补 |

**真实案例**（不要重蹈覆辙）：
- ❌ Susan 角色卡 38 行，只有 3 个字段（基础信息表+性格+功能）→ 不合格
- ✅ 莉亚角色卡 50+ 行，含 13 字段表 + 弧线 + 关系网 → 合格

#### 自检命令

写完一批后跑：
```bash
~/.claude/skills/vibe-director/cli/vibe-director lint --json | jq '.items[] | select(.severity=="warn")'
```

会列出所有不达标的卡片。逐个修。

---

### 双向链接硬规则（重要）

**生成任何内容到 `01_资产/`、`02_故事/`、`03_视角/`、`04_剧本/` 时，提到已知实体的地方必须用 `[[实体名]]` 语法。**

#### 适用范围

任何 wiki 内容里**首次或重要提及**已知的：
- 角色（`01_资产/01_角色/{name}.md` 存在的）→ `[[{name}]]`
- 场景（`01_资产/02_场景/{name}.md` 存在的）→ `[[{name}]]`
- 道具（`01_资产/03_道具/{name}.md` 存在的）→ `[[{name}]]`
- 集（`04_剧本/01_文学剧本/第N集_{title}.md`）→ `[[第N集_{title}]]`
- 概念（`02_故事/02_机制/*` 或 `03_传说/*` 中的术语）→ `[[{术语}]]`

#### 强制流程

每次 Write/Edit 新内容前，agent 必须：

1. **读 `index.md`**（已在冷启动协议中要求）→ 知道哪些实体已存在
2. **写完内容**后扫描自己的输出 → 找出所有提到的已知实体
3. **包成 `[[]]`** → 替换为 wikilink（首次出现，或在每个新章节首次出现）
4. **保存**

#### 例子

❌ **错（agent 直接写）**：
```markdown
## 核心关系
- 扎拉·卡林顿 — 爱人
- 里奥 — 名义丈夫
```

✅ **对（含 wikilink）**：
```markdown
## 核心关系
- [[扎拉·卡林顿]] — 爱人
- [[里奥]] — 名义丈夫
```

#### 不要包成 `[[]]` 的情况

- frontmatter 内的字段值
- 代码块内
- 已经在 `[[]]` 里的（避免嵌套）
- 同一段落中重复提及（首次足够）
- 一次性的非实体词（"那个男人"、"医生"）

#### Lint 检查

`/lint` 应该有一项**"实体提及未链接"**检查：扫所有 wiki 文件，找"提到已知实体名但不在 `[[]]` 中"的位置，列出来。

详细规范见 §八 Wiki 集成规则。

---

### 用户交互硬规则（重要）

**任何需要用户从 2-4 个选项中选择的场景，必须用 `AskUserQuestion` 工具，禁止用文本菜单（"[A]...[B]..." 这种）。**

#### 用 AskUserQuestion 的场景

| 场景 | 不要这样写 | 要这样做 |
|------|----------|---------|
| 模式选择（A/B/C/D/E） | 文本列 5 个选项让用户输字母 | AskUserQuestion，options=5 个标签 |
| 制作范围（剧本/+故事板/+视频）| 文本列"输 1/2/3" | AskUserQuestion，options=3 |
| 草案确认（全部/部分/取消） | "[A] 全部 [B] 看 diff [C] 取消" | AskUserQuestion，4 options |
| 视频生成参数确认 | "12s/1080p/16:9 对吗？" | AskUserQuestion: "确认提交？" options=[确认 / 改时长 / 改分辨率 / 取消] |
| Stub 卡处理 | "[A] 先补 [B] LLM 即兴 [C] 直接出图" | AskUserQuestion，3 options |
| 模糊指代（哪张图、哪个角色）| 让用户输字符串 | AskUserQuestion 列出候选 |
| Version 切换/删除/解冻 | "输确认解冻 vX" | AskUserQuestion 二次确认 |

#### **不要**用 AskUserQuestion 的场景

| 场景 | 用什么 |
|------|------|
| 用户描述新场景/新剧情 | 自由文本输入 |
| 用户起名（角色名/集名）| 自由文本输入 |
| 单纯告知信息（不需要回复）| 普通文本输出 |
| 多选场景的开放回答（如"还有什么要加吗"）| 自由文本（用户说"没了"为止）|

#### AskUserQuestion 用法约定

```typescript
AskUserQuestion({
  questions: [{
    question: "你想做哪个范围的工作？",
    header: "制作范围",          // 4-12 字短标签
    options: [
      { label: "只写剧本", description: "纯文字创作，无需 API" },
      { label: "剧本 + 故事板", description: "需要图片生成 API" },
      { label: "剧本 + 故事板 + 视频", description: "需要全套 API" }
    ],
    multiSelect: false
  }]
})
```

约束：
- 单次最多 4 个问题（如必须问多个）
- 单个问题最多 4 个 options
- 推荐选项第一个标 "(推荐)"
- label 简短（1-5 词）
- description 解释选项含义/后果

#### 关于本 SKILL.md 后续示例的约定

后续章节中所有 `[A]...[B]...[C]...` 格式的对话示例都是**简写**，表示"这里有 N 个选项"。
**实际实现时必须用 AskUserQuestion 工具**，不要直接复制文本菜单给用户。

这样写是为了节省 SKILL.md 篇幅，但实际交互必须是按钮选择，不是字母输入。

#### 例子转换

❌ **错（旧式文本菜单）**：
```
我建好 stub 卡了。要现在补全详情吗？
[A] 补全（agent 引导填字段 → 出参考图）
[B] 先放着（status 保持 stub）
[C] 撤销建卡（说明：哪个不需要建？）
```

✅ **对（AskUserQuestion）**：
```
[文本说明] 我建好 3 个 stub 卡了：露西·陈、废弃图书馆、古老药剂瓶。

[AskUserQuestion]
问题: "要现在补全这些 stub 卡的详情吗？"
header: "处理 stub"
options:
- "补全详情" — agent 引导填字段并生成参考图（推荐）
- "先放着" — 保持 stub，后续 lint 会提醒
- "撤销建卡" — 删除这 N 个 stub，下次再判断
```

---

### CLI 加固（重要）

skill 配套有一个 bash CLI（`~/.claude/skills/vibe-director/cli/vibe-director`），用于**确定性 + 高风险**的操作：

| CLI 命令 | 用途 | 何时调 |
|---------|------|--------|
| `vibe-director check-frozen <path>` | 检查路径是否在冻结版本下 | **任何 Edit/Write 前必调**（exit 1 = 拒写）|
| `vibe-director fork --to <name> --patches <list>` | 复制 wiki + 加 .frozen + 写待应用 patches | 用户说"试试 X 版本"时 |
| `vibe-director scan <file>` | 统计文件中的已知实体 + [[]] 引用 + X·Y 候选名 | 写完剧本后 |
| `vibe-director lint [--json]` | 9 项 wiki 健康检查 | 用户问 "现状怎样" / 周期检查 |

**调用方式**：
```bash
PATH="$HOME/.claude/skills/vibe-director/cli:$PATH" vibe-director <cmd> [args]
# 或直接绝对路径
~/.claude/skills/vibe-director/cli/vibe-director <cmd> [args]
```

**重要原则**：
- CLI 做**机械执行**（复制、检查、统计、模板填充）
- Agent 做**创意/决策**（解读意图、解读修改方案、写剧本、出图）
- CLI 失败时（exit ≠ 0）→ agent 不要绕过，而是把错误展示给用户

---

## 定位

整合剧本创作、故事板生成、Seedance视频提示词的全流程短剧制作技能。输出为 **Obsidian Wiki Vault** 格式——所有文件使用 Markdown，支持 `[[交叉引用]]`、图片内嵌、视频嵌入。

> **请在 Obsidian 中打开输出目录**以获得最佳体验：交叉引用跳转、图片内联显示、视频嵌入播放。

## 核心流程

```
启动 → 读 index.md / preferences.md / CLAUDE.md → 理解用户意图 → 执行
```

**三种制作范围**（决定需要哪些 API）：
- **只写剧本** — 无需任何 API
- **剧本 + 故事板** — 需要图片生成 API
- **剧本 + 故事板 + 视频** — 需要图片生成 + 视频生成 + 对象存储

**三种创作模式**（用户**不必显式选择**，可自然语言触发）：
- **A: 原创剧本** — 触发词：原创、新剧、我想做一部、从零开始
- **B: 剧本改故事板** — 触发词：故事板、出图、可视化已有剧本
- **C: 小说改编** — 触发词：改编、根据这本小说

> 用户用 slash 命令（`/原创`、`/故事板`、`/改编`）也可触发，但**不强制**。

---

## 一、新项目首次启动顺序（3 个问题）

新项目（空目录或无 wiki/）首次进 skill 时，**按以下顺序**用 AskUserQuestion 收集信息：

```
Step 1: 模式（做什么）
   ↓
Step 2: 范围（做到哪一步） — 部分模式可跳过
   ↓
Step 3: API 配置（根据范围决定要哪些 API）
```

### 1.0 模式选择（第一个问题）

**问什么**：你想怎么开始？

| 选项 label | description |
|-----------|------------|
| **原创剧本** | 从零开始，agent 引导你填角色、世界观、剧本 |
| **已有剧本要可视化** | 我有剧本，只想出故事板/视频 |
| **小说改编** | 我有小说，要改成短剧 |
| **导入既有素材** | 我有完整短剧（剧本+角色+世界观），结构化入库 |

> 用户也可以自然语言触发（"我想做一部新剧" / "我有剧本要出图" / "改这本小说" / "我有完整素材"），agent 直接进入对应模式不必再问。
>
> Mode E（方向性重构）不在新项目流程里——它需要已有 wiki，从 active wiki 触发。

### 1.1 制作范围（第二个问题，部分模式跳过）

根据 1.0 选的模式，决定是否问范围：

| 模式 | 是否问范围 | 默认范围 |
|------|---------|---------|
| **原创剧本** | 必问 | 用户选 |
| **小说改编** | 必问 | 用户选 |
| **已有剧本要可视化** | 不问（已经决定要故事板+） | 至少"剧本+故事板"，可加"+视频" |
| **导入既有素材** | 必问（看用户要做到哪一步）| 用户选 |

**问什么**：你要做到哪一步？

| 选项 label | description |
|-----------|------------|
| **只写剧本** | 纯文字创作，无需任何 API |
| **剧本 + 故事板** | 加图生图故事板和 Seedance 文本提示词，需图片生成 API |
| **剧本 + 故事板 + 视频** | 全流程含 Seedance 视频生成，需全套 API（最贵） |

如果用户选"只写剧本"，跳过 1.2-1.6 所有 API 配置直接进入创作。

### 1.2 图片生成 API（故事板及以上需要）

**存储位置**：Wiki Vault 根目录下的 `api-config.md`

**配置文件格式**：
```markdown
---
# 图片生成 API（GPT-image-2 或兼容接口）
img_api_gen: "https://api.example.com/v1/images/generations"
img_api_edit: "https://api.example.com/v1/images/edits"
img_api_key: "sk-your-key"
img_api_model: "gpt-image-2"
img_size_storyboard: "1792x1024"
img_size_character: "1024x1024"

# 视频生成 API（Seedance 2.0，仅"剧本+故事板+视频"需要）
vid_api: "https://api-direct.sumone.hk/v1/videos"
vid_api_key: "sk-your-key"
vid_model: "doubao-seedance-2-0-260128"

# 对象存储（仅"剧本+故事板+视频"需要，用于上传图片获取公开URL）
tos_endpoint: "tos-cn-beijing.volces.com"
tos_region: "cn-beijing"
tos_bucket: "your-bucket"
tos_ak: "your-ak"
tos_sk: "your-sk"
---
<!-- API 配置 — vibe-director 技能使用 -->
```

**配置流程**：
1. 检查当前工作目录是否有 `api-config.md`
2. 如果有 → 读取并显示配置摘要，询问用户是否复用
3. 如果没有 → **优先推荐模板法**，否则逐项问：

   **推荐：模板填空法（快）**
   - 把 `references/api-config.template.md` 的内容**完整粘贴给用户**
   - 告知："复制下方模板，填好值后粘贴回来，我一次性解析"
   - 用户粘贴填好的模板（或自由格式描述）→ agent 解析 → 写入 `wiki/api-config.md`
   
   **备用：一项一项问（慢，但适合用户没准备好时）**
   - **只写剧本**：跳过 API 配置
   - **剧本 + 故事板**：依次问 img_api_edit / key / model
   - **剧本 + 故事板 + 视频**：再问 vid_api / key + tos_endpoint / region / bucket / ak / sk
4. 写入 `api-config.md`

**模板解析规则**：
- 优先 YAML frontmatter（标准格式）
- 也接受自由格式：用户说"图片 endpoint 是 X，key 是 Y" → agent 提取关键值
- 缺失字段 → 反问该字段，不要瞎填默认值
- 占位符 `<...>` 未被替换 → 提示用户"这个字段还是模板占位符，请补充实际值"

**自动推断制作范围**：
- 用户只填板块 1 → 推断为"剧本 + 故事板"
- 用户填板块 1+2+3 → 推断为"剧本 + 故事板 + 视频"
- 跨板块缺关键字段 → 反问用户

**重新配置**：`/配置` 命令可随时修改 API 设置（也支持粘贴新模板）。

**读取方式**：每次需要调用 API 时，用 Read 工具读取 `api-config.md` 的 YAML frontmatter，提取所需字段。

### 1.3 视频生成 API（仅全流程需要）

**提交视频生成任务**（纯 bash）：
```bash
# 1. 提交任务 → 拿 task_id
TASK_ID=$(curl -s -X POST "$VID_API" \
  -H "Authorization: Bearer $VID_API_KEY" \
  -H "Content-Type: application/json" \
  -d @- <<EOF | jq -r '.task_id'
{
  "model": "$VID_MODEL",
  "prompt": "$SEEDANCE_PROMPT",
  "metadata": {
    "content": [{"type": "image_url", "image_url": {"url": "$IMAGE_URL"}}],
    "resolution": "1080p",
    "ratio": "16:9",
    "duration": $BEAT_DURATION
  }
}
EOF
)

# 2. 轮询任务状态（每 10s）
while true; do
  STATUS=$(curl -s "$VID_API/$TASK_ID" -H "Authorization: Bearer $VID_API_KEY" | jq -r '.status')
  case "$STATUS" in
    success)   VIDEO_URL=$(curl -s "$VID_API/$TASK_ID" -H "Authorization: Bearer $VID_API_KEY" | jq -r '.video_url'); break ;;
    failed)    echo "视频生成失败"; exit 1 ;;
    *)         sleep 10 ;;
  esac
done

# 3. 下载到 04_剧本/02_创作剧本/第N集/videos/
curl -sL "$VIDEO_URL" -o "04_剧本/02_创作剧本/第${N}集/videos/${BEAT_NAME}.mp4"
```

要点：
- `metadata.content` 不设 `role` 字段 = 参考模式（推荐，首帧不会硬抄故事板）
- 设 `"role": "first_frame"` 会让首帧就是故事板（不推荐）

**重要参数说明**：
- `metadata.duration`：视频时长（秒），最长 15 秒。**必须放在 metadata 里**，顶层会被忽略
- `metadata.content` 中**不设 `role` 字段** = 参考模式（推荐）。设 `role: "first_frame"` 会导致首帧就是故事板
- `metadata.resolution`：`"720p"` 或 `"1080p"`
- `metadata.ratio`：`"16:9"` / `"9:16"` / `"1:1"`

### 1.4 图片上传（对象存储 / TOS）

视频生成需要故事板图片的公开 URL。如果 Wiki 中图片只有本地路径，需上传到对象存储：

```bash
# 火山引擎 TOS S3 兼容协议上传 — 纯 bash + curl + openssl（S3 Signature V4）
upload_to_tos() {
  local file="$1"           # 本地文件路径
  local key="$2"            # TOS object key（如 storyboards/S01E01_SB01.png）

  local host="${TOS_BUCKET}.${TOS_ENDPOINT}"
  local content_type
  content_type=$(file -b --mime-type "$file")
  local date_stamp=$(date -u +%Y%m%d)
  local amz_date=$(date -u +%Y%m%dT%H%M%SZ)
  local payload_hash=$(openssl dgst -sha256 -hex < "$file" | awk '{print $2}')

  # Canonical request
  local canonical_req="PUT
/${key}

host:${host}
x-amz-content-sha256:${payload_hash}
x-amz-date:${amz_date}

host;x-amz-content-sha256;x-amz-date
${payload_hash}"

  local canonical_hash=$(printf '%s' "$canonical_req" | openssl dgst -sha256 -hex | awk '{print $2}')
  local credential_scope="${date_stamp}/${TOS_REGION}/tos/request"

  # String to sign
  local string_to_sign="TOS4-HMAC-SHA256
${amz_date}
${credential_scope}
${canonical_hash}"

  # Derive signing key
  local k_date=$(printf '%s' "$date_stamp" | openssl dgst -sha256 -hmac "TOS4${TOS_SK}" -hex | awk '{print $2}')
  local k_region=$(printf '%s' "$TOS_REGION" | openssl dgst -sha256 -mac HMAC -macopt hexkey:"$k_date" -hex | awk '{print $2}')
  local k_service=$(printf '%s' "tos" | openssl dgst -sha256 -mac HMAC -macopt hexkey:"$k_region" -hex | awk '{print $2}')
  local k_signing=$(printf '%s' "request" | openssl dgst -sha256 -mac HMAC -macopt hexkey:"$k_service" -hex | awk '{print $2}')
  local signature=$(printf '%s' "$string_to_sign" | openssl dgst -sha256 -mac HMAC -macopt hexkey:"$k_signing" -hex | awk '{print $2}')

  # Authorization
  local auth="TOS4-HMAC-SHA256 Credential=${TOS_AK}/${credential_scope}, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=${signature}"

  curl -s -X PUT "https://${host}/${key}" \
    -H "Host: ${host}" \
    -H "Authorization: ${auth}" \
    -H "x-amz-date: ${amz_date}" \
    -H "x-amz-content-sha256: ${payload_hash}" \
    -H "Content-Type: ${content_type}" \
    --data-binary "@${file}"

  echo "https://${host}/${key}"   # 返回公开 URL
}

# 用法
PUBLIC_URL=$(upload_to_tos "/path/to/storyboard.png" "storyboards/S01E01_SB01.png")
```

**说明**：
- 完全纯 bash，依赖 `curl` + `openssl`（macOS/Linux 自带）
- 实现 S3 V4 签名（TOS 兼容此协议）
- 30 行核心代码，可放在 `cli/lib/tos-upload.sh` 复用
- 如果嫌麻烦，agent 也可以用 `aws s3 cp --endpoint-url ...`（要装 awscli）

### 1.5 首帧裁剪

图生视频即使使用参考模式，首帧仍可能带有故事板痕迹。生成后用 ffmpeg 裁掉前 0.3 秒：

```bash
ffmpeg -y -i input.mp4 -ss 0.3 \
  -c:v libx264 -crf 18 -preset fast \
  -c:a aac -b:a 128k output.mp4
```

### 1.6 合并完整版

所有 beat 视频生成并裁剪完成后，用 ffmpeg concat 合并：

```bash
ffmpeg -y -f concat -safe 0 -i list.txt -c copy S01ENN_标题_完整版.mp4
```

---

## 二、命令集

| 命令 | 功能 |
|------|------|
| `/原创` | 启动 Mode A：原创剧本全流程 |
| `/故事板` | 启动 Mode B：剧本改故事板 |
| `/改编` | 启动 Mode C：小说改剧本和故事板 |
| `/导入` | 启动 Mode D：导入既有素材（追加模式） |
| `/导入 --merge` | Mode D 合并模式（冲突时显 diff） |
| `/导入 --replace` | Mode D 替换模式（先备份 + 强确认） |
| `/重构 "方向"` | 启动 Mode E：基于当前 active fork 新版本 |
| **版本管理（§五·F）** | |
| `/版本` | 列出所有版本，标 active 和 frozen |
| `/切换版本 vX` | 切 active 指针；旧 active 自动冻结，目标解冻 |
| `/对比 vX vs vY` | 列两版差异（基于 frontmatter `forked_from`）|
| `/解冻 vX` | 显式解冻（需输入"确认解冻 vX"） |
| `/删除版本 vX` | 移除 fork（须先冻结 + 输入"删除 vX"），实际归档到 `_archive/deleted_versions/` |
| `/创作方案` | 生成创作方案 |
| `/角色开发` | 角色档案 + 参考图 |
| `/目录` | 分集目录（50-70集） |
| `/分集 N` | 撰写第N集剧本 |
| `/自检 N` | 第N集质量评估 |
| `/生成故事板 N` | 为第N集生成故事板图片（需要图片API） |
| `/迭代 N P{beat} "指令"` | 迭代某个故事板（"再暗一点"），自动归档旧版本 |
| `/Seedance N` | 为第N集生成Seedance视频提示词（仅文本） |
| `/生成视频 N` | 为第N集生成Seedance视频并合并（需要视频API，需用户确认） |
| `/配图 角色名` | 生成角色/场景参考图（需要图片API） |
| `/合规` | 内容合规审核 |
| `/lint` | Wiki 健康检查（index 同步、manifest 完整、资产反查、POV、引用、needs-regen 队列） |
| `/lint --fix-index` | 自动重建 index.md |
| `/lint --fix-manifest` | 回填缺失的 manifest.md |
| `/lint --fix-orphan` | 列出孤儿资产 |
| `/lint --regen` | 列出所有 needs_regen=true 的故事板 + 批量重生（需用户确认）|
| **动态资产（§八·X）** | |
| `/盘点` | 全 wiki grep 找 dangling refs，列建议建卡的实体 |
| `/盘点 第N集` | 只盘点某集 |
| `/盘点 --backfill` | 显式触发跨集追溯回填 |
| `/补卡 X` | 引导用户补全 X 的字段（stub → partial → complete） |
| `/卡片状态` | 列出所有卡片按 status 分组 |
| `/重置 X` | 把 X 的 status 降回 stub（用于大改后重做） |
| **修改类（§十三.2）** | |
| `/执行` | 触发当前所有累积草案的批量影响分析 + 执行 |
| `/清空草案` | 清空 `_pending_changes.md`，所有未执行草案丢弃 |
| `/撤销` | 撤销最近一次 change-session（反向 Edit） |
| `/草案` | 显示当前累积的草案列表 |
| **沙盒（§十三.1）** | |
| `/沙盒` | 列出 `wiki/_sandbox/` 下所有临时构想 |
| `/提升 {沙盒名} → 第N集 P{beat}` | 沙盒构想升级到正式集 scenes/ |
| `/配置` | 重新配置API设置 |
| `/指令` | 显示所有命令 |

---

## 三、Mode A — 原创剧本

### 流程

```
/原创 → 题材选择 → 创作方案 → 角色开发 → 分集目录 → 分集剧本 → 故事板 → Seedance
```

### A.1 题材选择

读取 [genre-guide.md](references/genre-guide.md)，展示题材分类表，收集：
- 题材类型
- 目标受众（男频/女频/全年龄）
- 故事基调（爽燃/甜虐/搞笑/暗黑/温情）
- 结局类型（圆满/开放/反转/悲情）
- 集数规模
- 输出语言（中文/英文）

### A.2 创作方案

读取 [rhythm-design.md](references/rhythm-design.md) 和 [opening-hooks.md](references/opening-hooks.md)。

生成包含7个模块的创作方案：
1. 基础信息（剧名备选、受众、语言风格）
2. 时空背景
3. 故事核心（一句话故事线 + 核心冲突 + 主角困境）
4. 叙事结构（三幕拆解）
5. 节奏规划（付费卡点、情绪波形、转折集数）
6. 结局设计
7. 爽点矩阵（参考 [conflict-design.md](references/conflict-design.md)）

保存到 Wiki 根目录 `创作方案.md`。

### A.3 角色开发

读取 [character-dev.md](references/character-dev.md)。

为每个角色创建档案文件 `01_资产/01_角色/{角色名}.md`，包含：
- 角色信息表（姓名、角色、外貌、性格、公开身份/真实身份、目标、冲突、爽点功能）
- Mermaid 关系图（所有角色关系）
- 角色弧线设计

如果 `01_资产/01_角色/images/` 中没有角色参考图，使用 `/配图` 命令生成角色设定图（图生图，1024x1024）。

### A.4 分集目录

读取创作方案 + 角色档案。生成50-70集目录，标注核心冲突、爽点、付费卡点（💰）和重大转折（🔥）。

保存到 `04_剧本/分集目录.md`。

**必须输出完整目录后才能进入分集撰写。**

### A.5 分集剧本

读取 [script-format.md](references/script-format.md)、[episode-writing.md](references/episode-writing.md)。

每集前置读取：创作方案 + 角色档案 + 分集目录 + 最近2-3集剧本。

每集要求：
- ≥800字，3-5个场次
- 至少2个爽点或反转
- 结尾留悬念
- 每集分为 P01~P08 的剧情段（beat），用 `### P01：标题` 格式标记

保存到 `04_剧本/01_文学剧本/第N集_标题.md`。

### A.6 故事板生成

用户输入 `/生成故事板 N` 后执行。详见下方"故事板生成引擎"章节。

### A.7 Seedance 提示词

用户输入 `/Seedance N` 后执行。详见下方"Seedance提示词生成"章节。

---

## 四、Mode B — 剧本改故事板

### 流程

```
/故事板 → 分析剧本 → 提取要素 → 参考图匹配 → 生成故事板 → Seedance
```

### B.1 剧本输入

用户通过以下方式提供剧本：
- 直接粘贴内容
- 提供 Wiki Vault 中的文件路径
- 提供外部文件路径

### B.2 剧本分析

从剧本中提取：
- **剧情段**（beat）：按 `### P0X` 或场景标题分割
- **角色**：识别出场角色及外貌描述
- **场景**：识别所有场景地点
- **关键道具/视觉元素**
- **情绪弧线**

展示分析结果（剧情段拆分表）供用户确认。

### B.3 参考图匹配

在 Wiki Vault 中搜索参考图：
- 角色图：`01_资产/01_角色/images/*.png` 或 `*.jpg`
- 场景图：`01_资产/02_场景/images/*.png` 或 `*.jpg`
- 道具图：`01_资产/03_道具/images/*.png`
- 传说/机制图：`02_故事/03_传说/images/`、`02_故事/02_机制/images/`

用 Glob 搜索文件名匹配角色名/场景名的图片。将匹配结果映射为：`{角色/场景名} → 图片路径`。

**缺失参考图**：如果关键角色/场景没有参考图，先调用 `/配图` 生成角色设定图。

### B.4 生成故事板

与 A.6 相同流程。按 beat 顺序逐张生成。

### B.5 Seedance 提示词

与 A.7 相同流程。

---

## 五、Mode C — 小说改编

### 流程

```
/改编 → 分析小说 → 改编规划 → 角色开发 → 分集目录 → 剧本 → 故事板 → Seedance
```

### C.1 小说输入

用户通过粘贴内容、文件路径或 URL 提供小说/故事文本。

### C.2 小说分析

读取 [novel-adaptation.md](references/novel-adaptation.md) 获取改编方法论。

从小说中提取：
- 核心冲突和前提
- 主要角色及关系
- 关键场景和事件序列
- Hook点（适合作为每集开场的瞬间）
- 世界观规则

确定改编范围：集数、节奏结构、主要弧线。

展示分析摘要供用户确认。

### C.3 改编规划

将小说叙事映射到短剧集结构：
- 每集涵盖的内容
- 角色简化/合并方案
- Hook点分布
- 节奏规划

生成改编方案（类似创作方案），保存到 Wiki 根目录 `创作方案.md`。

### C.4 后续流程

执行角色开发（A.3）→ 分集目录（A.4）→ 剧本（A.5）→ 故事板（A.6）→ Seedance（A.7）。

---

## 五·D、Mode D — 导入既有素材（Wikify）

### 适用场景

用户**已有完整的短剧素材**（剧本+角色+世界观+设定），散落在 Word/Notion/飞书或纯文本里，需要**一次性结构化入库**到 Wiki。

**与 Mode B/C 区别**：
- Mode B = 只导剧本要可视化（不动世界观）
- Mode C = 从小说从头创作（要重新设计分集）
- **Mode D = 已经有完整短剧结构，仅需结构化入库**

### 流程

```
/导入 → 收集素材 → 分类识别 → 实体抽取 → 映射方案 → 冲突处理 → 批量生成 → lint 验证
```

### D.1 收集（Intake）

```
用户："我有完整的剧本和设定，要导入"
agent："好。给我素材（粘贴/文件路径/一段段加都行）"

用户：[粘贴 5000 字]
agent：[存到 raw/原始素材_part1.md] "还有更多吗？"
用户：[粘贴角色补充]
agent：[存到 raw/原始素材_part2.md] "还有吗？"
用户："就这些"
```

每段素材保存到 `raw/原始素材_partN.md`，**永不修改**（raw/ 不可变原则）。

### D.2 分类识别

Agent 对每段 raw/ 内容用 LLM 判别类型，输出**分类表**给用户审：

| 识别类型 | 触发特征 | 目标路径 |
|---------|---------|---------|
| 世界观/设定 | 描述世界规则、历史、术语 | `02_故事/世界观.md` |
| 时间线 | 时间序列事件 | `02_故事/完整时间线.md` |
| 单个角色 | 姓名+外形+性格 | `01_资产/01_角色/{name}.md` |
| 角色组合（阵营/身份） | 多角色分类规则 | `02_故事/01_身份/` |
| 单个场景 | 地点描述 | `01_资产/02_场景/{name}.md` |
| 道具 | 关键物品 | `01_资产/03_道具/{name}.md` |
| 剧本（含场次） | 含场景标签、对白 | `04_剧本/01_文学剧本/第N集.md` |
| 分集大纲 | 每集一段摘要 | `04_剧本/分集目录.md` |
| 视觉参考 | 图片 | `raw/参考/images/` |

用户可以修正分类（"part2 里 2 段是道具不是角色"）。

### D.3 实体抽取

对每类素材，提取结构化字段：

**角色**：姓名、性别、年龄、外貌、性格、背景、目标、关系、出场集数
**世界观**：核心规则、时空背景、术语、阵营
**剧本**：场景列表、出场角色、beat 拆分（如未拆，自动按场景拆 P01-P08）

未明确的字段标 `TODO`，不强行编造：

```yaml
外貌: TODO  # 素材中未提及
```

### D.4 映射方案

完整方案表给用户审批：

```
📋 导入方案

将创建：
- 02_故事/世界观.md（新建，1500 字）
- 02_故事/完整时间线.md（新建）
- 01_资产/01_角色/{11个}.md（其中 3 个外貌为 TODO）
- 01_资产/02_场景/{4个}.md
- 01_资产/03_道具/{2个}.md
- 04_剧本/01_文学剧本/{5集}.md
- 04_剧本/02_创作剧本/{5集目录 + manifest.md}
- 04_剧本/分集目录.md（80 集规划）
- 更新 index.md

⚠️ 当前 wiki 现状：空 / 已有 N 个文件
⚠️ 冲突：[列出会覆盖的文件] / 无

[A] 全部按方案执行
[B] 我先看某类素材的预览（如角色卡）
[C] 选择性导入（如只角色，剧本暂不要）
[D] 取消
```

### D.5 冲突处理

三种导入子模式：

| 命令 | 行为 | 冲突时 |
|------|------|------|
| `/导入` | **追加**（默认）| 已存在同名文件 → 跳过，告知用户 |
| `/导入 --merge` | **合并** | 展示 diff，按字段问用户保留谁 |
| `/导入 --replace` | **替换** | 先备份现有 wiki 到 `_archive/before_replace_{ts}/`，再覆盖 |

`--replace` 是危险操作，**强制**让用户输入"确认替换"才执行。

### D.6 批量生成

按方案多文件协同 Write：
- 角色卡用 `references/character-dev.md` 标准模板
- 世界观用 02_故事/世界观.md 标准格式
- 剧本用 `references/script-format.md` 标准格式
- **自动加 `[[交叉引用]]`**（角色名/场景名首次出现处）
- 更新 `index.md`（每个新建文件加一行）
- log.md 写 `[import-session-NNN]`

### D.7 lint 验证

自动跑 `/lint`，重点检查：
- 剧本引用角色但无角色卡 → 提示补全
- 剧本引用场景但无场景卡 → 提示补全
- 时间线与剧本矛盾 → 标矛盾点
- 引用断链 → 列出
- TODO 字段统计 → 提示哪些角色信息不全

### D.8 增量导入

用户后续追加素材（"还有一份角色补充"）：
1. 新素材进 `raw/`
2. 实体抽取
3. 与现有 wiki 合并：
   - 已存在角色 → 显示 diff，问"合并/覆盖/保留？"
   - 新角色 → 创建新卡
4. 视觉相关字段被改 → manifest 标 `needs_regen: true`

---

## 五·E、Mode E — 方向性重构（Directional Refactor）

### 适用场景

用户已有 wiki（不论是 Mode A 原创、Mode C 改编、还是 Mode D 导入），**对当前方向不满意**，想：
- 换调性（更暗黑/更轻松/加幽默）
- 换主角（性别/职业/动机）
- 换设定（年代/地点/世界规则）
- 换题材（romance → mystery）
- 换节奏（更快/更慢）
- 完全重构

**核心理念**：**Fork 而非 Branch**——v1.0 永久冻结，v2.0 是独立完整副本，不强制 merge。

### E.1 触发与方向解析

```
用户："我想试试暗黑版，把主角改成女性"
agent：[解析方向]
       识别 patch：
       - tone-darken
       - protagonist-gender-swap
       [查 references/direction-dictionary.md 取每个 patch 的影响范围]
```

方向 → patch 字典见 `references/direction-dictionary.md`。

### E.2 Fork 启动

**强制调 CLI**：
```bash
~/.claude/skills/vibe-director/cli/vibe-director fork \
  --to v2.0a-dark \
  --patches tone-darken,protagonist-gender-swap
```

CLI 负责机械操作：
- 首次 fork 自动迁移 `wiki/` → `wikis/v1.0_<date>/`
- 复制源到目标
- 给源加 `.frozen`
- 给目标写 `_patches_applied.md`（待应用 patches 列表）
- 更新 `wikis/current` 指针

CLI **不应用 patches 内容**——那是 agent 的事（通过 §十三.2 修改类草案流程，把 _patches_applied.md 里的每个 patch 应用到 active wiki）。

第一次 `/重构` 时，agent 自动迁移目录结构：

```
迁移前：                    迁移后：
project/                    project/
├── CLAUDE.md               ├── CLAUDE.md
└── wiki/                   └── wikis/
    ├── index.md                ├── current → v2.0a-dark/
    ├── 01_资产/                ├── v1.0_2026-05-14/
    └── ...                     │   ├── .frozen        ← 冻结标记
                                │   ├── index.md
                                │   ├── 01_资产/
                                │   └── ...（v1.0 完整复制）
                                └── v2.0a-dark/
                                    ├── _patches_applied.md
                                    ├── index.md
                                    ├── 01_资产/
                                    └── ...（v2.0 待应用 patch）
```

**关键约定**：
- 单版本时不启用 `wikis/`（wiki/ 直接在项目根）
- 第一次 fork 触发结构升级
- `current` 是软链或 `.active` 标记文件，指向当前可编辑版本

### E.3 应用 Patches

每个 patch 走 §十三.2 修改类草案流程，**但范围是 v2.0 整个 wiki**：

```
agent：[草案：tone-darken patch]
       将修改 wikis/v2.0a-dark/ 下 15 个文件：
       - 01_资产/01_角色/艾拉拉·万斯.md：性格"温和坚定"→"几乎冷血"
       - 04_剧本/01_文学剧本/第1集.md：删除幽默 beat × 3 处
       - 02_故事/世界观.md：加入"长期阴霾"调性描述
       - ...
       
       [继续追加 patch / 执行]
```

### E.4 Δ 块自动生成（每页顶部）

应用 patch 后，每个被修改的 v2.0 页面顶部自动写入：

```markdown
# 艾拉拉·万斯

> ## Δ from v1.0 (2026-05-14, patches: tone-darken + protagonist-gender-swap)
> - 性别：男 → 女
> - 性格："温和坚定" → "几乎冷血"
> - 入局动机："寻找失踪兄弟" → "调查死亡伴侣"（更暗黑）
>
> [📜 看 v1.0 原版](../v1.0_2026-05-14/01_资产/01_角色/艾拉拉·万斯.md)

---

## 角色档案
[v2.0 的正文内容]
```

v1.0 那边对应卡片底部自动加：

```markdown
---
## 衍生版本
- [v2.0a-dark](../v2.0a-dark/01_资产/01_角色/艾拉拉·万斯.md) — 暗黑女主向（2026-05-14）
```

### E.5 双向链接（frontmatter）

**v1.0 卡片 frontmatter**：
```yaml
---
version: v1.0_2026-05-14
status: frozen
forked_to:
  - wikis/v2.0a-dark/01_资产/01_角色/艾拉拉·万斯.md
---
```

**v2.0 卡片 frontmatter**：
```yaml
---
version: v2.0a-dark
status: active
forked_from: wikis/v1.0_2026-05-14/01_资产/01_角色/艾拉拉·万斯.md
patches_applied: [tone-darken, protagonist-gender-swap]
---
```

agent 读 frontmatter → 知道对应关系，**无需重新扫文件**。

### E.6 lint 跨版本检查

`/lint` 在多版本 wiki 中额外检查：
- v2.0 页面是否都有 Δ 块？
- v1.0 卡片是否都有"衍生版本"段？
- frontmatter 双向链接是否对称？
- v2.0 是否修改了不该改的（即 v1.0 之外没列在 patch 里的）字段？

---

## 五·F、版本管理硬规则（绝对不可违反）

### F.1 不可变性硬规则

**任何路径包含 `.frozen` 祖先目录的文件，Edit/Write 操作必须立刻拒绝。**

**强制实现方式**：用 CLI 检查，不靠 agent 自觉。

```bash
# 每次 Edit/Write 前调
~/.claude/skills/vibe-director/cli/vibe-director check-frozen <target_path>
# exit 0 → 可写
# exit 1 → 拒写（agent 必须停止并告诉用户）
# exit 2 → 错误（路径无效）
```

报错文案模板：
> "{version} 已冻结（marker: {marker}）。修改请切换 active 版本，或 /解冻 {version}（慎用）。"

### F.2 单 Active 指针

任何时刻只有**一个**版本可改：
- `wikis/current` 指向的 = active = 可编辑
- 其他全部 `.frozen` = read-only

切换 active：`/切换版本 vX`
1. 当前 active 自动加 `.frozen`
2. 目标版本移除 `.frozen`
3. `wikis/current` 更新指向

### F.3 解冻是显式且危险的

`/解冻 vX`：
1. 警告："你确定吗？这会破坏 v2.0 对 v1.0 的引用基准"
2. 用户必须输入"确认解冻 {vX}"
3. 删除 `.frozen`
4. log.md：`[unfreeze] {vX} 解冻于 {date}`（标红记录）

### F.4 删除版本

`/删除版本 vX`：
1. 目标必须先冻结
2. 警告"此操作不可逆"
3. 用户输入"删除 {vX}"
4. 实际是 `mv wikis/vX/` 到 `_archive/deleted_versions/`，不真删
5. log.md：`[delete-version] {vX} → _archive/`

### F.5 任意冻结版本均可再 fork

```
v1.0_original (frozen) ──┬─→ v2.0a-dark (was active, now frozen)
                         ├─→ v2.0b-comedy (was active, now frozen)
                         └─→ v3.0-noir (active, current)

v2.0a-dark (frozen) ─────→ v3.1-dark-refined (active)
```

fork 后的新版本 frontmatter 标 `forked_from: {真正的源}`，不一定是 v1.0。

---

## 六、故事板生成引擎

### 核心原则

1. **必须使用图生图（image-to-image）**：每张故事板必须以 Wiki 中的角色参考图作为输入，保持角色面部一致性
2. **专业电影预生产设计板**（Production Design Board）：包含 10 个板块（导演意图、角色设计、场景设计、机位调度、摄影规格、灯光参考、色彩脚本、3 帧分镜、Seedance 适配说明）
3. **写实电影摄影风格**：真人质感渲染，与角色参考图保持一致。Seedance 真人审核通过遮眼方案绕过

### 读取规范

读取 [storyboard-spec.md](references/storyboard-spec.md) 和 [storyboard-prompts.md](references/storyboard-prompts.md) 获取完整规范。

### 生成流程（每个 beat）

**Step 0: Stub 卡片检查（§八·X.6）**

在 Step 1 之前，先确认所有用到的资产是否为 stub：
1. 读 beat 涉及的角色 + 场景 + 道具
2. 查每个资产卡的 `status` 字段
3. 如有 stub 卡 → 提示用户：
   ```
   ⚠️ 本 beat 需要的以下资产是 stub：
   - 角色 X (外貌 TODO)
   - 场景 Y (无细节)
   
   [A] 先补全（推荐）
   [B] LLM 即兴生成
   [C] 用 stub 信息 + 默认风格直接出图，后续可迭代
   ```
4. 用户选 C → 用现有 stub 字段构建 fallback 提示词
5. 用户选 A → 触发 `/补卡 X` 流程，完成后回来继续 Step 1

**不阻塞**：用户始终可以选 C 推进，stub 卡的限制是"质量可能偏离"，不是"无法生成"。

**Step 1: 提取要素 + 影视技巧匹配**

读取 [cinematic-techniques.md](references/cinematic-techniques.md)。

从 beat 的剧本文本中提取：
- 出场角色及当前状态（表情、动作、服装变化）
- 场景地点及氛围（时间、天气、光线）
- 关键道具和视觉焦点
- 情绪弧线关键词
- 叙事节拍（该 beat 内 3-5 个视觉时刻）
- **声画关系分析**：当 VO/独白提到过去的人、事、物时，标记需要闪回（FLASHBACK）；当情绪转折时，标记适合的剪辑/声音技巧
- **技巧选择**：根据场景类型（恐怖/对话/发现/回忆等），从技巧速查表匹配最适配的技巧组合，在分镜剧本的 `[技术]` 标签中标注

**Step 2: 查找参考图**

```bash
# 角色参考图（图生图输入——所有出场角色都要找）
Glob: 01_资产/01_角色/images/*{角色英文名}*.png
Glob: 01_资产/01_角色/images/*{角色英文名}*.jpg

# 场景参考图（提取场景元素）
Glob: 01_资产/02_场景/images/*{场景关键词}*.png

# 道具参考
Glob: 01_资产/03_道具/images/*.png

# 故事相关参考
Glob: 02_故事/03_传说/images/*.png
Glob: 02_故事/02_机制/images/*.png
```

**所有出场角色的参考图全部作为图生图输入**（GPT-image-2 `/v1/images/edits` 支持多图）。每个角色用独立的 `-F "image[]=@路径"` 字段传入，最多传入该 beat 出场的全部角色，保证每个角色的面部一致性。

**Step 3: 构建提示词**

使用 [storyboard-prompts.md](references/storyboard-prompts.md) 中的完整 Production Design Board 模板。将剧本 beat 中的信息填入模板的 `{{变量}}`，生成完整提示词。

**关键：角色描述必须从角色参考图中逐项复刻**（发色、发型、眼色、肤色、服装、配饰），不能凭想象改写。风格为写实电影摄影（realistic cinematic photography），真人质感。

**Step 4: 调用 API（图生图）**

读取 `api-config.md` 获取配置。

```bash
# 单角色
curl --request POST \
  --url "${API_EDIT_ENDPOINT}" \
  --header "Authorization: Bearer ${API_KEY}" \
  -F "model=${API_MODEL}" \
  -F "prompt=${PROMPT}" \
  -F "image[]=@${CHARACTER_IMAGE_1}" \
  -F "size=${SIZE_STORYBOARD}" \
  --max-time 300 \
  -o /tmp/sb_response.json

# 多角色（所有出场角色参考图全部传入）
curl --request POST \
  --url "${API_EDIT_ENDPOINT}" \
  --header "Authorization: Bearer ${API_KEY}" \
  -F "model=${API_MODEL}" \
  -F "prompt=${PROMPT}" \
  -F "image[]=@${CHARACTER_IMAGE_1}" \
  -F "image[]=@${CHARACTER_IMAGE_2}" \
  -F "image[]=@${CHARACTER_IMAGE_3}" \
  -F "size=${SIZE_STORYBOARD}" \
  --max-time 300 \
  -o /tmp/sb_response.json
```

**Step 5: 解析响应并保存**

```bash
# 解析响应（纯 bash + jq）
SAVE_PATH="04_剧本/02_创作剧本/第${N}集_${TITLE}/scenes/S${S}E${EP}_SB${SB}_P${BEAT}_${DESC}.png"

# 试 URL 模式
IMAGE_URL=$(jq -r '.data[0].url // empty' /tmp/sb_response.json)
if [[ -n "$IMAGE_URL" ]]; then
  curl -sL "$IMAGE_URL" -o "$SAVE_PATH"
else
  # base64 模式
  B64=$(jq -r '.data[0].b64_json // empty' /tmp/sb_response.json)
  if [[ -n "$B64" ]]; then
    echo "$B64" | base64 -d > "$SAVE_PATH"
  else
    echo "响应中无 url 也无 b64_json" >&2
    exit 1
  fi
fi
```

**Step 6: 质量检查**

对照 [storyboard-spec.md](references/storyboard-spec.md) 中的质量检查清单验证。**角色面部一致性是必须通过项**——如果角色面部与参考图明显不同，必须重新生成。

### 遮眼方案（Seedance 真人审核绕过）

生成故事板后，提交 Seedance 视频前需执行遮眼处理：

```bash
curl --request POST \
  --url "${API_EDIT_ENDPOINT}" \
  --header "Authorization: Bearer ${API_KEY}" \
  -F "model=${API_MODEL}" \
  -F "prompt=Add thin white horizontal bars over the eyes of all human figures in this image. Keep everything else identical." \
  -F "image=@${STORYBOARD_PATH}" \
  -o censored_response.json
```

用遮眼版故事板提交 Seedance 视频生成，提示词中写明正确瞳色（如 `woman with dark brown eyes`），视频模型会恢复眼睛。

### 目录结构

```
04_剧本/02_创作剧本/第N集_标题/
├── 第N集_标题.md              ← 创作版剧本（含 beat 标记）
├── manifest.md                ← 【必须】故事板素材清单 + 资产依赖
├── scenes/                    ← 故事板图片
│   ├── S01E01_SB01_P01_航拍暴风雪.png       ← 当前 latest 版本
│   ├── _versions/                            ← 历史版本归档
│   │   ├── S01E01_SB01_P01_航拍暴风雪_v1.png
│   │   └── S01E01_SB01_P01_航拍暴风雪_v2.png
│   └── ...
├── videos/                    ← 原始 beat 视频（裁剪前）
└── seedance-prompts.md        ← Seedance 提示词
```

### 命名规范

- 故事板：`S{季}E{集}_SB{编号}_P{beat编号}_{中文描述}.png`
- 视频：`S{季}E{集}_P{beat编号}_{中文描述}.mp4`
- 历史版本：`{原文件名}_v{N}.png` 放到 `scenes/_versions/`

### manifest.md — 故事板素材清单（每集必写）

每集创作剧本目录下必须有 `manifest.md`，记录所有故事板的元数据和**资产依赖**。这是 lint 反查"资产改动影响哪些故事板"的核心数据。

**格式**：

```markdown
# 第N集_标题 — 故事板素材清单

> Agent 自动维护。资产变动时，lint 会列出受影响的故事板。

| Beat | File | Version | Status | Updated |
|------|------|---------|--------|---------|
| P01 | scenes/S01E01_SB01_P01_航拍暴风雪.png | v1 | latest | 2026-05-09 |
| P02 | scenes/S01E01_SB02_P02_车内驾驶.png | v2 | latest | 2026-05-10 |

## P01 航拍暴风雪
- depends_on_characters: []
- depends_on_character_images: []
- depends_on_scenes:
  - `01_资产/02_场景/黑木瀑布镇.md`
- depends_on_scene_images:
  - `01_资产/02_场景/images/blackwood_falls.png`
- depends_on_props: []
- generated_at: 2026-05-09
- prompt_summary: 航拍视角，暴风雪夜，缅因州山脉公路
- needs_regen: false

## P02 车内驾驶
- depends_on_characters:
  - `01_资产/01_角色/艾拉拉·万斯.md`
- depends_on_character_images:
  - `01_资产/01_角色/images/elara_vance_final.png`
- depends_on_scenes: []
- depends_on_scene_images: []
- depends_on_props: [车内仪表盘, 手机, 笔记本, 威士忌酒瓶]
- generated_at: 2026-05-09
- prompt_summary: 艾拉拉车内特写，仪表盘暖光，手握方向盘
- needs_regen: true
- regen_reason: "艾拉拉性格调整（change-session-001），眼神描述变化"
- iterations:
  - v1 → v2: "镜头压低，光线再暗一点"（2026-05-10）
```

**needs_regen 字段说明**：
- `false`（默认）：故事板与当前依赖资产一致
- `true`：依赖的某个资产被修改过，故事板可能过时
- `regen_reason`：标 true 时必填，简述原因（通常关联 change-session ID）
- 标 true 不强制立刻重生（费钱），但每次 `/lint` 会提醒，用户问"接下来做什么"时 agent 会主动建议

**生成时机**：
- 每次生成一张故事板 → 立即在 manifest 追加/更新该 beat 的条目
- 每次迭代（v1 → v2） → 更新 version 字段 + 追加 iterations 记录
- 资产被引用的故事板，必须在 depends_on 中明确列出

**Lint 用法**：
- 当 `01_资产/01_角色/艾拉拉·万斯.md` 修改时 → 全局 grep manifest.md 找出所有 depends_on 包含此路径的 beat → 提示用户"以下 N 张故事板可能需要重新生成"

### 错误处理

- API 超时：重试一次，增加 timeout
- 429 过载：等待 30 秒后重试
- 两次失败：跳过该 beat，告知用户，继续下一个
- 所有 beat 生成完毕后报告失败项

### 故事板版本化与迭代

每张故事板都可以被迭代（"再暗一点"、"镜头压低"），通过版本化保留所有历史，agent 也能在版本间对比学习用户偏好。

**约定**（不使用 symlink，纯文件命名约定）：
- `scenes/{name}.png` — **永远指向当前 latest 版本**
- `scenes/_versions/{name}_v1.png` — 历史归档
- `scenes/_versions/{name}_v2.png`
- ...

**迭代流程（用户说"再暗一点"）**：

1. **读取 manifest.md**，找到对应 beat 的当前 version 号（如 v1）
2. **归档当前版本**：把 `scenes/{name}.png` **移动**到 `scenes/_versions/{name}_v1.png`
3. **构建迭代提示词**：
   - 基础提示词（原 beat 的 prompt）+ 用户的修改指令（"darker mood, lower contrast"）
   - 关键：**用原参考图 + 当前 latest 故事板** 作为图生图输入，让模型在已有结果上调整，而不是从头生成
4. **生成新版本**：保存到 `scenes/{name}.png`（覆盖位）
5. **更新 manifest.md**：
   - 该 beat 的 version 字段 v1 → v2
   - 在 iterations 列表追加：`- v1 → v2: "用户原话"（日期）`
6. **告知用户**：展示新图，说明改动，问"满意吗还是再调？"

**回滚**：用户说"回到 v1" → 把 `_versions/{name}_v1.png` 复制回 `scenes/{name}.png`，manifest version 字段标注 `current: v1 (rolled back from v2)`。

**用户偏好提取（连接 preferences.md）**：
- 同一类型的迭代指令出现 ≥3 次（如"再暗一点"反复出现）→ agent 主动提议升级为 preferences.md 中的全局规则（如"色彩默认偏低饱和"）

### `/迭代` 命令

```
/迭代 第N集 P{beat} "修改指令"
例：/迭代 第1集 P02 "镜头压低，光线再暗一点，蓝调更冷"
```

执行：定位文件 → 归档 → 重生 → 更新 manifest → 展示新图。

---

## 七、Seedance 提示词生成

### 读取规范

读取 [seedance-guide.md](references/seedance-guide.md) 获取完整方法论。
读取 [cinematic-techniques.md](references/cinematic-techniques.md) 获取影视技巧的 AI 视频适配写法。

### 核心原则

1. **叙事描述式**：完整段落，不用关键词堆叠
2. **一条提示词 = 一段完整叙事**
3. **分时段描述**（根据 beat 时长）
4. **参考图已见原则**：故事板已有的静态内容不重复描述，重点描述"变化"
5. **不用否定句**
6. **技巧落地**：将分镜剧本中已标注的影视技巧（闪回、寂静、色彩编码等）转化为 Seedance 提示词中的具体画面描述

### 分时段模板

| 时长 | 分段 |
|------|------|
| 15s | 0-3s / 3-6s / 6-10s / 10-15s |
| 10s | 0-2s / 2-5s / 5-8s / 8-10s |
| 8s | 0-2s / 2-4s / 4-6s / 6-8s |

### 提示词结构

```
以[角色描述]为主角，场景参考[场景描述]。
[时段1]：[开场画面、环境建立]
[时段2]：[镜头运动，角色初始动作]
[时段3]：[核心动作/情绪转变/关键事件]
[时段4]：[收尾，定格画面或悬念]
音效：[环境音/动作音/音乐风格]。电影感，[氛围关键词]。
```

### 保存格式

每集的 Seedance 提示词保存到 `04_剧本/02_创作剧本/第N集_标题/seedance-prompts.md`。

```markdown
# 第N集 — Seedance 视频提示词

## 素材对应表

| Beat | 故事板 | 时长 | 提示词 |
|------|--------|------|--------|
| P01 | scenes/S01ENN_SB01_P01_xxx.png | 12s | 见下方 |
| ... | ... | ... | ... |

## P01：剧情标题（12秒）

**故事板**：`scenes/S01ENN_SB01_P01_xxx.png`

> [完整Seedance提示词]

---

## P02：...
```

### 真人检测绕过

Seedance I2V 有真人检测。如需绕过：
1. 用 API 的 `/v1/images/edits` 端点给故事板人物眼睛加白条
2. 用遮眼版故事板提交视频生成
3. 提示词中写明正确瞳色，视频模型会恢复

---

## 八、Wiki 集成规则

### 设计理念

Wiki 采用 **5+1 分块结构**，按生产流程从资产到成品排列。每个板块都是独立的管理单元，可独立迭代而不影响其他板块。

灵感来源：Karpathy 的 LLM Wiki 方法论——Wiki 是一个 **持续复利的持久产物**（compounding artifact），由 5 个原语支撑：
- `raw/` 存不可变原始素材
- `wiki/` 存 LLM 生成的衍生页面
- `index.md` 是 **agent 快速索引**（每条目：路径 + 8-15 字摘要）
- `log.md` 是追加式操作日志
- lint 操作保证一致性

### index.md — Agent 索引（核心原语）

`index.md` 是整个 Wiki 的"目录服务"，给 **agent** 看（不是给人看，给人看的是 `导航.md`）。设计原则：

1. **每条目一行**：路径 + 8-15 字摘要，绝不超过 1 行
2. **agent 启动必读**：每次会话开始、生成故事板/视频/回答用户问题前，**先 Read 此文件全文**
3. **建立世界模型**：读完此文件 agent 就知道"这个剧有谁、在哪、发生了什么、做到哪一步"
4. **避免 30 文件问题**：读 index 后只 Read 当前任务真正需要的 2-3 个文件，不要无脑遍历整个 wiki
5. **维护责任**：
   - 新增角色/场景/集 → 必须追加一行到 index
   - 文件路径变动 → 必须更新 index 对应行
   - 重大资产删除 → 从 index 删除对应行 + 在 log.md 追加记录
   - 任何时候发现 index 与实际不符 → 触发 `/lint` 重建

**示例条目**：
```markdown
- `01_资产/01_角色/艾拉拉·万斯.md` | 主角，独立调查记者，哥特暗黑，墨黑长直发，掌握轮回能力
- `01_资产/01_角色/images/elara_vance_final.png` | 艾拉拉三视图，红色露肩+黑皮裤
- `01_资产/02_场景/汽车旅馆.md` | 镇入口20房破旧旅馆，霓虹VACANCY招牌，游戏入口
```

**禁止**：在 index.md 写长段描述、写正文内容、写交叉引用 `[[]]`。详细信息应该留给具体的资产文件。

### preferences.md — 用户偏好层

`preferences.md` 是 agent 的 **学习记忆**——用户的 recurring 风格选择会在这里逐步沉淀。

**维护机制（三次确认法）**：
1. 用户第 1 次表达某偏好 → 当前会话记住，不写文件
2. 第 2 次相同偏好 → 在 `log.md` 标记 `[preference-candidate] {内容}`
3. 第 3 次出现 → agent 主动询问"我发现你似乎一直偏好 X，要不要写入 preferences.md？"
4. 用户确认 → 追加到 `preferences.md` 对应类别

**应用规则**：
- 每次生成任务前，Read `preferences.md`，将其作为默认参数
- 用户在当前任务中明确反对 → 本次忽略，不改文件
- 用户说"以后都不要 X 了" → 修改 preferences 对应行
- 偏好与剧本/创作方案冲突 → 剧本类优先

### 目录结构

```
项目名/                              ← Wiki Vault 根目录
├── index.md                         ← 【必读】agent 索引（路径+摘要，启动必读）
├── 导航.md                          ← 给人看的 Obsidian 导航（可选）
├── 创作方案.md                       ← 项目纲领（Wiki 根目录）
├── preferences.md                   ← 用户偏好层（recurring 风格选择）
├── api-config.md                     ← API 配置
├── log.md                           ← 操作日志（append-only，Karpathy）
│
├── raw/                             ← 原始素材（不可变，Karpathy）
│   ├── 小说原文.txt                  ← 改编模式下的原始文本
│   ├── 参考资料/                    ← 任何外部参考材料
│   └── ...                          ← 只读，不做修改
│
├── 01_资产/                         ← 【必选】Block 1 — 可复用素材
│   ├── 01_角色/                     ← 必选
│   │   ├── images/                  ← 角色参考图（图生图输入）
│   │   │   ├── elara_vance.png
│   │   │   └── ...
│   │   ├── audio/                   ← 可选：角色音色/声线样本
│   │   │   ├── elara_voice_sample.mp3
│   │   │   └── ...
│   │   ├── 艾拉拉·万斯.md            ← 角色卡（含外貌、性格、音色描述）
│   │   └── ...
│   ├── 02_场景/                     ← 必选
│   │   ├── images/                  ← 场景参考图（图生图输入）
│   │   │   ├── white_church.png
│   │   │   └── ...
│   │   ├── 白木教堂.md
│   │   └── ...
│   ├── 03_道具/                     ← 可选，按剧本特性按需创建
│   │   ├── images/
│   │   └── ...
│   └── 04_音频/                     ← 可选：BGM、音效、环境音
│       ├── bgm/
│       ├── sfx/
│       └── ambient/
│
├── 02_故事/                         ← 【必选】Block 2 — 上帝视角的完整世界
│   ├── 世界观.md                    ← 必填：整体世界观设定
│   ├── 完整时间线.md                 ← 必填：客观时间线（全知视角）
│   ├── 01_身份/                     ← 可选：角色身份类型（如狼人/先知）
│   ├── 02_机制/                     ← 可选：游戏/剧情规则（如狼人杀机制）
│   ├── 03_传说/                     ← 可选：背景传说、历史
│   └── ...                          ← 可选，按剧本特性自由创建子目录
│
├── 03_视角/                         ← 【必选】Block 3 — 观众认知管理（独立板块）
│   ├── POV设定.md                   ← 全局POV规则：谁是视点角色，信息边界
│   ├── 第1集_观众已知.md             ← 每集一份：该集结束后观众已知的信息
│   ├── 第2集_观众已知.md
│   └── ...
│
├── 04_剧本/                         ← 【必选】Block 4 — 文学剧本 + 创作剧本
│   ├── 分集目录.md                   ← 全剧分集规划
│   ├── 01_文学剧本/                 ← 给人看的：叙事流畅、台词精炼
│   │   ├── 第1集_标题.md
│   │   └── ...
│   └── 02_创作剧本/                 ← 给模型用的：故事板 + 参考图 + 音频 + 提示词
│       ├── 第1集_标题/
│       │   ├── 第1集_标题.md         ← 创作版剧本（含 beat 标记）
│       │   ├── scenes/              ← 故事板图片
│       │   │   ├── S01E01_SB01_P01_航拍暴风雪.png
│       │   │   └── ...
│       │   ├── videos/              ← beat 级视频
│       │   └── seedance-prompts.md  ← Seedance 提示词
│       └── ...
│
└── 05_视频/                         ← 【必选】Block 5 — 按层级全部保留
    ├── 第1集_标题/                   ← 单集视频
    │   ├── 01_beats/                ← beat 级成品片段
    │   │   ├── S01E01_P01_航拍暴风雪.mp4
    │   │   └── ...
    │   ├── 02_粗剪/                 ← 粗剪版（beat拼接）
    │   │   └── S01E01_标题_粗剪.mp4
    │   └── 03_成片/                 ← 最终成片
    │       └── S01E01_标题_成片.mp4
    ├── 第一幕/                      ← 幕级成片
    │   └── 第一幕_成片.mp4
    └── 第一季/                      ← 季级成片
        └── 第一季_成片.mp4
```

### 各板块说明

| 板块 | 定位 | 必选内容 | 可选内容 |
|------|------|---------|---------|
| **01_资产** | 可复用素材库 | 01_角色/(images/)、02_场景/(images/) | 03_道具/、04_音频/、01_角色/audio/ |
| **02_故事** | 上帝视角完整世界 | 世界观.md、完整时间线.md | 01_身份/、02_机制/、03_传说/ 及任意子目录 |
| **03_视角** | 观众认知管理 | POV设定.md、每集观众已知文件 | — |
| **04_剧本** | 文学+创作双轨 | 分集目录.md、01_文学剧本/、02_创作剧本/ | — |
| **05_视频** | 多层级视频存档 | — | 01_beats/、02_粗剪/、03_成片/ 按需 |

### log.md 操作日志

Wiki 根目录的 `log.md` 是一个 **append-only**（追加式）操作日志。每次重要操作后追加一条记录。

**前缀约定**（让 log 可被 grep）：

| 前缀 | 含义 |
|------|------|
| 无前缀 | 普通进度记录（剧本完成、故事板生成等） |
| `[change-session-NNN]` | 修改类批量操作（§十三.2），NNN 是流水号 |
| `[revert]` | 撤销操作 |
| `[lint]` | lint 执行结果摘要 |
| `[preference-candidate]` | 检测到的偏好候选（连续 3 次后升级到 preferences.md）|
| `[sandbox-promote]` | 沙盒构想升级到正式集 |

**示例**：

```markdown
# 操作日志

- 2026-05-09 创建项目，生成创作方案
- 2026-05-09 完成角色开发（8个角色），生成参考图
- 2026-05-09 生成分集目录（80集）
- 2026-05-10 完成第1集文学剧本
- 2026-05-10 完成第1集创作剧本 + 故事板（8张）
- 2026-05-10 完成第1集 Seedance 提示词
- 2026-05-10 完成第1集视频生成（8个beat），合并粗剪
- 2026-05-14 [change-session-001] 角色调整批次（3 条草案）
  - 草案 #1: 艾拉拉性格更冷酷（修 5 文件）
  - 草案 #2: 凯文改名 Kelvin（修 12 文件）
  - 草案 #3: 血月只在关键集出现（修 8 文件）
  - 共修改 25 个文件，标记 21 张故事板需重生
  - 归档：_archive/change-sessions/2026-05-14-001.md
- 2026-05-14 [sandbox-promote] 构想_20260514_2103_雪夜推门 → 第6集 P02
- 2026-05-14 [preference-candidate] 用户连续使用低饱和冷色调（第 2 次）
- 2026-05-14 [lint] 5/8 通过，3 项 needs_regen 待处理
```

**追加时机**：创作方案完成、角色开发完成、分集目录完成、每集剧本完成、故事板生成完成、视频生成完成、lint 执行完成、change-session 完成、撤销操作、沙盒提升。

### 交叉引用语法

- 角色：`[[艾拉拉·万斯]]`
- 场景：`[[白木教堂]]`
- 图片：`![描述](images/filename.png)`（相对路径）
- 故事板：`![故事板](scenes/S01ENN_SBXX_PXX_描述.png)`（创作剧本内相对路径）
- 视频：`<video src="../../05_视频/第1集_标题/01_beats/S01ENN_PXX_描述.mp4" controls width="100%"></video>`
- 故事板（创作剧本内）：`![故事板](scenes/S01ENN_SBXX_PXX_描述.png)`

### 创作剧本中的嵌入模板

创作剧本文件 `04_剧本/02_创作剧本/第N集_标题/第N集_标题.md`：

```markdown
### P01：剧情标题 | 内景/夜

![故事板](scenes/S01ENN_SBXX_PXX_描述.png)

<video src="../../05_视频/第1集_标题/01_beats/S01ENN_PXX_描述.mp4" controls width="100%"></video>

△ 剧情正文...
```

文学剧本文件 `04_剧本/01_文学剧本/第N集_标题.md`：

```markdown
### P01：剧情标题 | 内景/夜

△ 剧情正文（纯文本，无嵌入）...
```

### index.md 模板

```markdown
# {项目名}

> 创作方案 | [[创作方案]]
> 集数规模 | {N}集

## 剧集

| 集 | 标题 | 文学剧本 | 创作剧本 | 视频 |
|----|------|---------|---------|------|
| 01 | {标题} | [[第1集_{标题}]] | [创作版](04_剧本/02_创作剧本/第1集_{标题}/) | [成片](05_视频/第1集_{标题}/) |
| ... | ... | ... | ... | ... |

## 资产

| 类型 | 名称 | 链接 |
|------|------|------|
| 角色 | {角色名} | [[{角色名}]] |
| 场景 | {场景名} | [[{场景名}]] |

## 故事

| 文件 | 链接 |
|------|------|
| 世界观 | [[世界观]] |
| 完整时间线 | [[完整时间线]] |

## 视角

| 集 | 观众已知 | 链接 |
|----|---------|------|
| 01 | {摘要} | [[第1集_观众已知]] |

## 视频层级

| 层级 | 位置 |
|------|------|
| Beat 视频 | `05_视频/第N集/01_beats/` |
| 粗剪 | `05_视频/第N集/02_粗剪/` |
| 成片 | `05_视频/第N集/03_成片/` |
| 幕级 | `05_视频/第N幕/` |
| 季级 | `05_视频/第N季/` |
```

详细目录规范见 [wiki-structure.md](references/wiki-structure.md)。

---

## 八·X、动态资产增补（写作中自动增补 Wiki）

> 现实创作中 Wiki 不是一次建完——写到第 N 集突然冒出新角色/新场景/新道具是常态。
> 此机制保证 agent 在写作时**自动检测并增补 Wiki**，不让资产管理拖累创作节奏。
> 完整规则见 [asset-detection.md](references/asset-detection.md) 与 [asset-card-template.md](references/asset-card-template.md)。

### X.1 三种触发模式

| 模式 | 时机 | 行为 |
|------|------|------|
| **主动检测** | 每次写完一集剧本 / 解析完一段素材 | agent 写完顺便扫新实体，自动建 stub + 通知用户 |
| **批量盘点** | 用户说 "盘点" / `/盘点` | 全 wiki grep 专有名词 vs index，列 dangling refs |
| **被动 lint** | `/lint` 定期跑 | 列 dangling references + 按 status 分组 |

### X.2 检测算法（CLI + agent 配合）

**Step 1 — CLI 做机械扫描**：
```bash
~/.claude/skills/vibe-director/cli/vibe-director scan <file> --json
```

CLI 输出：
- `known_entities_present`：文件中已知实体出现统计
- `existing_wikilinks`：文件中的 `[[xxx]]` 引用
- `candidate_new`：X·Y 命名模式的候选（CLI 无法判断意图，只能给候选）

**Step 2 — Agent 做语义判断**：
基于 CLI 输出 + LLM 推理，决定：
- 候选哪些是真实体（排除歧义/无意义重复）
- 是否达到阈值（出现 ≥ 2 次 或 1 次但情节关键）
- 类型分类（角色 / 场景 / 道具）

**Step 3 — Agent 调用工具建 stub 卡** + 更新 index.md

详细阈值判断见 [asset-detection.md §阈值判断](references/asset-detection.md)。

### X.3 自动建卡（推荐配置 — 默认行为）

agent 写完剧本后自检流程：

1. 提取新实体（命名 + 出现 ≥ 2 次，或 1 次但情节关键）
2. 用 [asset-card-template.md](references/asset-card-template.md) 的 **stub 模板**批量建卡
3. 同步 `index.md`（追加新条目 + 标 `(stub)`）
4. 写 log.md：`[asset-detect] 第 N 集检测新增 X 角色 + Y 场景 + Z 道具`
5. 通知用户（不阻塞）：

```
✅ 第 21 集剧本已写完（1240 字）

📌 检测到 3 个新资产（已自动建 stub 卡）：
   - 👤 角色：露西·陈（出现 2 次，副警长助理）→ stub
   - 🏛️ 场景：废弃图书馆（整集核心）→ stub
   - 📦 道具：古老药剂瓶（情节核心）→ stub
   
要现在补全详情吗？
[A] 补全（agent 引导填字段 → 出参考图）
[B] 先放着（status 保持 stub）
[C] 撤销建卡（说明：哪个不需要建？）
```

### X.4 跨集追溯（推荐配置）

新增资产时 agent **回查前面集数**，找泛指可能就是新资产的句子：

```
agent: 你刚加了"露西·陈"（副警长助理）。
       前面集数有 2 处泛指可能是她：
       - 第 17 集 P04："副警长助理快进来一下"
       - 第 19 集 P02："助理把档案放在桌上"
       
       要不要回填？这会让前后连贯。
       [A] 全部回填  [B] 部分回填  [C] 不改
```

回填走 §十三.2 修改类草案流程（影响分析 → 用户审批 → 多文件 Edit）。

### X.5 卡片状态字段（status）

每张卡 frontmatter 含 status：

| status | 含义 |
|--------|------|
| `stub` | 仅命名 + 出场记录，其他 TODO |
| `partial` | 关键字段（如外貌+性格）已填 |
| `complete` | 所有字段完成 |
| `with-image` | 有参考图（可与 partial/complete 叠加）|

升级规则见 [asset-card-template.md §升级机制](references/asset-card-template.md)。

### X.6 Stub 不阻塞，但**生成视觉资产时提示**

故事板/视频生成前，agent 检测到目标 beat 用到 stub 卡：

```
⚠️ 第 21 集 P03 需要：
   - 露西·陈 (stub，外貌 TODO)
   - 废弃图书馆 (stub，无场景细节)

[A] 我先帮你补一下（5 分钟）  
[B] 直接 LLM 即兴生成（可能偏离风格）
[C] 用现有 stub 信息 + 默认风格出图，后续可迭代（推荐）
```

详细见 §六 故事板生成的 stub 处理步骤。

### X.7 命令

| 命令 | 功能 |
|------|------|
| `/盘点` | 全 wiki grep 找 dangling refs，列建议建卡的实体 |
| `/盘点 第N集` | 只盘点某集 |
| `/盘点 --backfill` | 显式触发跨集追溯回填 |
| `/补卡 X` | 引导用户补全 X 的字段（stub → partial → complete） |
| `/卡片状态` | 列出所有卡片按 status 分组 |
| `/重置 X` | 把 X 的 status 降回 stub（用于大改后重做） |

### X.8 偏好配置

阈值参数存在 `preferences.md`：

```markdown
## 资产检测偏好
- 自动建卡阈值：出现次数 >= 2（默认）
- 跨集追溯：开启（默认）
- Stub 卡出图前提醒：开启（默认）
```

用户可调，例如严格模式："出现 1 次就建卡"。

---

## 九、角色/场景参考图生成

### 触发方式

- `/配图 角色名` — 为指定角色生成设定图
- `/配图 场景名` — 为指定场景生成参考图

### 角色设定图

读取 `01_资产/01_角色/{角色名}.md` 中的外貌描述，按以下结构构建英文提示词：

```
Character design reference sheet, [age]-year-old [gender], realistic cinematic photography.

Physical: [hair color + texture + length], [eye color], [skin tone], [body type]
Aesthetic: [整体美学风格, e.g. gothic dark / clean preppy / military rugged]
Costume (head to toe): [从上到下逐层描述，e.g. structured black long coat → cropped black top → black lace bralette visible → black leather pants → chunky combat boots]
Hair & makeup: [发型细节], [妆容细节, e.g. smoky eye, minimal makeup]
Vibe: [气质关键词, e.g. icy sensual beauty, cold elegance]

Layout: plain neutral background, multi-view layout — full body front view + 3/4 angle + back view + face close-up, all views consistent, high detail, 8k
Name plate: centered at the bottom, character English name in elegant serif capitals (e.g. ELARA VANCE), with a thin decorative horizontal line beneath the name, muted tone matching the overall palette
```

- 使用图生图（如有部分参考图）或文生图（如完全新建）
- 尺寸：1024x1024
- 保存到 `01_资产/01_角色/images/{english_name}.png`

### 场景参考图

读取 `01_资产/02_场景/{场景名}.md` 中的环境描述：

```
Cinematic establishing shot of [地点英文描述], [建筑风格], [天气/时间], [关键视觉元素], realistic photography, dramatic lighting, 8k
```

- 尺寸：1792x1024
- 保存到 `01_资产/02_场景/images/{english_name}.png`

---

## 十、Wiki 健康检查（/lint）

**实现方式**：调 CLI（9 项确定性检查由代码完成）。

```bash
~/.claude/skills/vibe-director/cli/vibe-director lint            # 人类可读
~/.claude/skills/vibe-director/cli/vibe-director lint --json     # JSON for agent
```

退出码：0 全通过 / 1 有警告 / 2 有错误

Agent 拿到结果后做的事：
1. 把 errors 和高优先级 warnings 总结给用户
2. 对每条问题给出修复建议
3. 用户确认后用对应工具（Edit / fork / 重生故事板）修

定期执行 Wiki 一致性检查。灵感来自 Karpathy LLM Wiki 的 lint 操作——保证 Wiki 作为持久产物的质量。

### 检查项

| 检查 | 说明 | 方法 |
|------|------|------|
| **Index 同步性** | `index.md` 中列出的所有路径必须实际存在；所有 wiki 重要文件必须出现在 index | 两侧遍历：① 解析 index.md 取所有路径，验证文件存在；② Glob 全部 .md/.png，验证都在 index 中 |
| **Manifest 完整性** | 每个 `04_剧本/02_创作剧本/第N集_*/` 必须有 manifest.md，且与 scenes/ 中的实际文件对应 | 遍历集目录，对比 manifest 列出的 beat × 实际 scenes/ 文件 |
| **资产改动反查** | 资产文件（角色卡、场景卡、参考图）的 mtime 比依赖它的故事板更新 → 提示重新生成 | grep 所有 manifest.md 的 depends_on 字段，对比 mtime |
| **Needs-regen 队列** | 已被 change-session 标 `needs_regen: true` 的故事板，列表 + 估算批量重生成本 | grep manifest.md 中 `needs_regen: true` |
| **草案残留** | `_pending_changes.md` 存在但已超过 24 小时未执行 → 提示用户是否清理 | 检查文件 mtime |
| **Dangling references** | 剧本中提到但 wiki 中无卡片的实体 | 全 wiki grep 命名实体 vs index.md |
| **Stub 卡片分组** | 按 status 分组列出所有卡片（stub/partial/complete/with-image），提示哪些可推进 | grep frontmatter `status` 字段 |
| **POV 泄漏检测** | `03_视角/第N集_观众已知.md` 中不应包含该集观众不可能知道的信息 | 对比 02_故事/世界观.md 中的上帝视角信息 |
| **时间线一致性** | `02_故事/完整时间线.md` 中的事件顺序与各集剧本描述一致 | 遍历剧本中的时间描述 |
| **角色一致性** | `01_资产/01_角色/` 中的外貌/性格描述与剧本描写一致 | 提取剧本中的角色描写关键词，对比角色卡 |
| **引用完整性** | 所有 `[[交叉引用]]` 指向的文件都存在 | Glob 全部 .md，提取 `[[]]` 链接，验证目标存在 |
| **孤儿检测** | 没有任何文件引用的资产/页面 | 反查 `[[]]` 引用 + manifest depends_on，找出无人引用的资产 |
| **SKILL 合规** | wiki 实际结构是否符合 SKILL.md 中规定的 5+1 分块 | 检查 `01_资产/`、`02_故事/`、`03_视角/`、`04_剧本/`、`05_视频/` 是否存在 |

### 执行方式

用户输入 `/lint` 后：

1. 遍历 Wiki Vault 中的所有 .md 文件
2. 逐项执行上述 4 项检查
3. 生成检查报告，标注通过/失败项和具体问题
4. 追加一行到 `log.md`：`- {date} 执行 lint 检查，{N}项通过，{M}项问题`

### lint 报告格式

报告保存到 `lint-report-{YYYY-MM-DD}.md`（根目录，可清理）。

```markdown
# Wiki 健康检查 — 2026-05-13

## 通过项
- [x] Index 同步性：87/87 资产路径有效
- [x] SKILL 合规：5+1 分块结构完整
- [x] POV 泄漏检测：第1-20集无泄漏
- [x] 角色一致性：13个角色全部一致

## 问题项

### 资产改动反查（高优先级）
- ⚠️ `01_资产/01_角色/艾拉拉·万斯.md` 于 2026-05-13 修改，但以下 8 张故事板的 mtime 早于此时间：
  - `04_剧本/02_创作剧本/第1集_雪夜来客/scenes/S01E01_SB02_P02_车内驾驶.png`
  - ... (其余 7 张)
  - **建议**：用 `/迭代` 或 `/生成故事板` 重新生成

### Manifest 缺失（中优先级）
- ⚠️ 以下集目录缺少 manifest.md：
  - `04_剧本/02_创作剧本/第1集_雪夜来客/` （存在 scenes/ 但无 manifest）
  - `04_剧本/02_创作剧本/第2集_夜之觉醒/`
  - ...
  - **建议**：用 `/lint --fix-manifest` 自动回填（agent 读 scenes/ 目录 + 剧本生成 manifest）

### 引用完整性（低优先级）
- ⚠️ `[[废弃银矿]]` — 文件不存在
- ⚠️ `[[古代药剂]]` — 文件不存在

### 孤儿检测
- 🟡 `01_资产/01_角色/崔维斯.md` — 没有任何文件引用此角色（可能是非剧情路人）
```

### lint 修复命令

- `/lint` — 只检查，输出报告
- `/lint --fix-index` — 自动重建 index.md（扫描所有文件 + 自动摘要）
- `/lint --fix-manifest` — 回填缺失的 manifest.md（读 scenes/ + 剧本，推断依赖）
- `/lint --fix-orphan` — 列出孤儿资产供用户决定是否归档

---

## 十一、冷启动协议（新 agent 第一次进入此 skill）

**目的**：新 agent 没有任何会话上下文，必须靠 SKILL.md + Wiki 文件自我引导。

### Step 1 — 强制读三个文件（按顺序，不要跳过）

```
1. Read $PWD/CLAUDE.md           ← 项目级使命/目标（如存在）
2. Read $PWD/wiki/index.md       ← 整个剧的世界模型
3. Read $PWD/wiki/preferences.md ← 用户风格偏好
```

**如果三个文件都不存在** → 这是新项目，跳到 Step 4。
**如果 wiki/ 不存在但 CLAUDE.md 存在** → 用户可能在错误目录，提醒用户 cd 到 wiki 根。

### Step 2 — 判断当前是什么状态

读完三个文件后，你应该能回答：
- 这是什么剧？（类型、规模、调性）
- 进度到哪了？（剧本/故事板/视频各阶段的集数）
- 用户偏好什么风格？
- 这个 skill 在这个项目里被用过吗？

### Step 3 — 简短问候 + 状态摘要 + 等待意图

格式（≤ 4 行）：
```
👋 [剧名] · [类型]
进度：文学剧本 1-N 集 / 分镜剧本 1-M 集 / 故事板+视频 1-K 集
偏好：[1-2 个核心偏好关键词]
你想做什么？
```

**不要主动列命令菜单**——用户会用自然语言说。

### Step 4 — 新项目分支（无 index.md）

按 §一 的 3 步顺序走：

1. **模式选择**（§1.0）—— 用 AskUserQuestion，4 个选项：原创 / 已有剧本 / 小说改编 / 导入素材
2. **范围选择**（§1.1）—— 用 AskUserQuestion，3 个选项：只剧本 / +故事板 / +视频。部分模式跳过
3. **API 配置**（§1.2-1.4）—— 仅当范围 >= "+故事板"
4. **创建 Wiki 骨架** —— 含 index.md / preferences.md / log.md / api-config.md（如需）
5. **进入对应模式工作流**（§三/§四/§五/§五·D）

### Step 5 — 意图识别（用户开口后）

参见 §十一·B（自由意图识别）。

---

## 十一·B、自由意图识别（关键）

用户**不必用 slash 命令**。你必须把自然语言映射到具体动作。

### 映射规则

#### 生成类（直接执行，图片跳过确认）

| 用户说什么 | 你执行什么 |
|----------|----------|
| "做一张/出一张/帮我画/给我看 [描述]" | 故事板生成（§六 + §十三.1）。先从 index.md 识别资产 |
| "再暗一点 / 镜头压低 / 换个角度 / 这张里把X改成Y" | `/迭代` 流程（§六·版本化与迭代） |
| "做成视频 / 出视频 / 这张拍成 N 秒" | Seedance 视频生成（§七），**必须先确认** |
| "我想做一部关于X的剧 / 从零开始" | Mode A 原创（§三） |
| "我有剧本要可视化 / 给这集出故事板" | Mode B 故事板（§四） |
| "把这本小说改成剧" | Mode C 改编（§五） |
| "我有完整剧本+设定要导入 / 帮我入库" | Mode D 导入（§五·D） |
| "我有自己的角色和世界观，全替换掉" | Mode D `--replace` 模式 |
| "我想试试X版 / 改成X方向 / 完全重构" | Mode E 重构 fork（§五·E） |
| "回到 v1.0 看看 / 切回原版" | `/切换版本 v1.0`（自动管理 frozen）|
| "v1.0 和现在比有啥不同" | `/对比 v1.0 vs current`（只读） |
| "这是 v1.0 的，能改吗" | **拒绝** + 提示 frozen 规则（§五·F.1）|
| "盘点 / 看看哪些资产没建卡 / 哪些遗漏了" | `/盘点` 全 wiki 扫 dangling refs |
| "补全 X / X 的卡补一下 / 把 X 完善" | `/补卡 X` 引导填字段 |
| "X 是个新角色/场景/道具" | 立即建 stub 卡（不需要等"出现 2 次"阈值）|
| "把刚才那个新角色叫 X" | 用 X 创建 stub，把最近未命名提及关联上去 |
| "哪些是 stub / 多少卡没建完" | `/卡片状态` 按 status 分组报告 |
| "第N集的故事板继续 / 接下来做第N集" | 找出第N集状态，生未完成的故事板 |
| "把刚才那张存到第N集 P{beat}" | 沙盒提升流程（§十三.1） |

#### 修改类（**进入草案模式，不直接 Edit**）

| 用户说什么 | 你执行什么 |
|----------|----------|
| "我觉得X不对 / X应该是Y / 把X改成Y" | 写草案（§十三.2），追加到 `_pending_changes.md` |
| "X 更XX一点 / X 不够XX" | 弱描述：自己解读 + 出草案给用户审，**不反问** |
| "删掉 X / 不要 X / 砍掉 X" | 删除类草案，标注"删除"意图 |
| "X 改名叫 Y" | 重命名类草案，会自动 grep 全 wiki 找引用 |
| "执行 / 改吧 / 开始 / 走起" | 触发批量影响分析（§十三.2） |
| "清空草案 / 都不要了 / 重来" | 清空 `_pending_changes.md` |
| "撤销刚才的修改 / 回退" | 读最近 change-session，反向 Edit |

#### 查询类（不修改任何文件）

| 用户说什么 | 你执行什么 |
|----------|----------|
| "现在到哪了 / 进度如何" | 基于 index.md 项目快照段直接答 |
| "最近做了什么 / 都做了什么" | 读 log.md 末尾 5-10 条 |
| "X 是谁 / X 角色卡" | index.md 找路径 → Read 角色卡，摘要 |
| "X 和 Y 啥关系" | Grep wiki + 读角色卡 |
| "第N集涉及谁 / 用了什么资产" | 读第N集 manifest 的 depends_on 字段 |
| "哪些故事板需要重生" | 全局 Grep manifest 找 `needs_regen: true` |
| "搜一下 X / 哪里提到 X" | Grep 工具 |
| "你能做什么 / 怎么用" | 简述三类操作（生成/修改/查询），**不**列命令菜单 |

### 模糊指代解析

用户常用模糊指代："那张图"、"刚才那个"、"这集"、"这个剧"、"我刚生成的"。规则：

#### 项目级指代（**优先最新原则**）

"这个剧 / 我刚生成的 / 现在 / 那个项目 / 我做的剧" 等指代时——

**默认指用户最近修改的 wiki 项目**，不要默认套用到当前工作目录或某个具名旧项目。

判断"最新"的方法：
```bash
find ~/Documents ~/Documents/剧本改编 -maxdepth 4 \
  \( -name "wiki" -o -name "wikis" \) -type d 2>/dev/null | \
  xargs -I{} stat -f "%m %N" {} 2>/dev/null | sort -rn | head -3
```

策略：
- 若只有一个候选 → 直接用
- 若多个候选且 mtime 接近 → 用 AskUserQuestion 列出最近 3 个让用户选
- 不要因为某个项目的 CLAUDE.md 有"项目使命"段就默认所有问题都套用它
- 若用户明确说项目名（"血月轮回"/"裙子下的秘密"等）→ 按那个走

#### 元素级指代

- "那张图 / 刚才那个" → 默认指最近一次 agent 生成的故事板。若不确定，反问"你说的是 P02 还是 P03？"
- "这集 / 当前集" → 看 log.md 最近一次涉及的集数
- "主角 / 女主" → 看 index.md，找标注为"主角"的角色
- 多个候选时不要瞎猜，用 AskUserQuestion 反问

### 反问的时机

**主动反问**（必须）：
- 用户描述场景但缺少关键资产（"做一张她在地下室"——"她"是谁？地下室是哪个场景？）
- 用户偏好与 preferences 矛盾（已记录"偏好冷色调"，用户却说"做一张温暖感觉的"——确认是临时还是永久变更）
- 即将执行**昂贵操作**（生成视频前必须确认，按秒计费）

**不要反问**（直接做）：
- 信息完整、明确的请求
- 用户已经在等结果（不要"为了反问而反问"）

---
   - 没有 → 建议创建新项目，询问项目名称
5. **模式选择**：展示三种创作模式
   - **A: 原创剧本** — 从零开始，完整流程
   - **B: 剧本改故事板** — 已有剧本，只需故事板（需要"剧本+故事板"或以上范围）
   - **C: 小说改编** — 有小说/故事文本，需先改剧本
6. 根据用户选择进入对应工作流

> **注意**：如果用户选择"只写剧本"后又要求生成故事板或视频，提示需要先配置对应 API。

---

## 十二、总体规则

- **输出语言**：根据用户选择（中文/英文），全程一致
- **API 密钥不硬编码**：始终从 `api-config.md` 读取
- **故事板仅用图生图**：必须使用 Wiki 参考图作为输入
- **节奏第一**：宁可牺牲逻辑也不拖节奏
- **每集至少2个爽点或反转**
- **合规意识**贯穿始终（[compliance-checklist.md](references/compliance-checklist.md)）
- **废片不删**：废弃素材归档到 Wiki Vault 外的 `_archive/` 目录（与 Wiki Vault 同级）
- **视频生成需用户确认**：Seedance 视频按秒计费，未经用户说"生成"不得提交
- **修改类操作"先报告后执行"**：见 §十三
- 每个阶段完成后，告知用户下一步操作和对应命令

---

## 十三、VibeDirector 对话层（核心工作流）

> **此章节描述 agent 如何把自然语言映射成具体动作。是整个 skill 的执行入口。**

### 三大操作类型

| 类型 | 用户说什么 | Agent 怎么做 | 是否需要确认 |
|------|----------|------------|------------|
| **生成** | "做一张X"、"出视频"、"写第N集" | 走生成流程 → 立刻执行 | 图片：跳过 ／ 视频：必须确认 |
| **修改** | "我觉得X不对"、"把X改成Y"、"删X" | 进入草案模式 → 收集 → 执行时统一影响分析 | **必须确认** |
| **查询** | "现在到哪了"、"X 和 Y 啥关系" | 基于 index/log/manifest 直接答 | 不需要 |

---

### 13.1 生成类工作流

#### 6 步内部流程（每次生成都走这个）

| 步 | 内容 |
|----|------|
| 1. 解析 | 从口述中提取实体：角色 / 场景 / 道具 / 动作 / 氛围 / 时段 |
| 2. 映射 | 用 `index.md` 把实体对应到 Wiki 资产路径 |
| 3. 决定 | 全匹配 → 继续；1 个缺 → 1 个反问；多缺 → AskUserQuestion |
| 4. 确认 | 图片生成：**跳过**确认直接做；视频生成：**必须**展示参数（时长、分辨率、成本估算）让用户拍板 |
| 5. 生成 | 走 §六（故事板）或 §七（Seedance）流程 |
| 6. 监听 | 展示结果 → 等用户后续口述（迭代 / 视频化 / 保存到某集） |

#### 输出位置策略

| 情境 | 路径 |
|------|------|
| **临时构想（沙盒）** | `wiki/_sandbox/构想_{YYYYMMDD_HHMM}_{slug}/` |
| **关联到某集** | `04_剧本/02_创作剧本/第N集_*/scenes/` |
| **从沙盒提升** | `mv` 沙盒目录到对应集 scenes/，更新 manifest |

沙盒目录也含简化版 manifest.md，方便日后提升或回顾。

#### 沙盒目录约定

```
wiki/_sandbox/
├── 构想_20260514_2103_雪夜推门/
│   ├── description.md       ← 用户原口述 + agent 解读
│   ├── manifest.md          ← 资产依赖（简化版）
│   ├── prompt.md            ← 完整 Production Design Board 提示词
│   ├── output.png           ← latest
│   └── _versions/           ← 迭代历史
│       ├── output_v1.png
│       └── ...
└── ...
```

#### 沙盒 → 正式集的"提升"

用户说 "把刚才那张存到第6集 P02" → agent：
1. 定位最近沙盒目录
2. `mv` 图片到 `04_剧本/02_创作剧本/第06集_*/scenes/`，重命名为正式格式
3. 合并 manifest 到目标集的 manifest.md
4. log.md 追加 `- {date} 沙盒提升 → 第6集 P02`

---

### 13.2 修改类工作流（草案 + 批量执行）

修改类操作不能"边说边改"——必须**先草案、再批量、再执行**。这是硬规则。

#### 工作模式：草案累积 + 显式执行

```
[修改类口述 #1] → agent 写草案 #1，展示，问"继续追加？还是执行？"
[修改类口述 #2] → agent 追加草案 #2
[修改类口述 #3] → agent 追加草案 #3
[用户：执行]    → agent 做整体影响分析 → 报告 → 用户选 A/B/C/D
                                                  ↓
                                             执行 → log.md 写 [change-session]
```

#### 草案文件

草案累积到 `wiki/_pending_changes.md`（临时文件，执行后自动归档）：

```markdown
# 待执行修改草案 — 会话 {YYYY-MM-DD HH:MM}

> Agent 解读用户口述，生成具体修改方案。用户审核后说"/执行"批量改。

## 草案 #1：艾拉拉性格调整
**用户原话**：「我觉得艾拉拉应该更冷酷一点」（2026-05-14 21:03）

**Agent 解读**：当前角色卡描述"极度理性"+"温和眼神"。"更冷酷"意味着：
- 减弱：温和眼神、对陌生人的好奇心
- 加强：拒绝人情、对死亡的麻木、台词更短促

**具体修改**：
1. `01_资产/01_角色/艾拉拉·万斯.md`
   - 性格特征 第1条："极度理性" → "极度理性，几乎冷血"
   - 性格特征 新增："对死亡习以为常——见过太多遗体"
   - 外形："烟熏淡妆衬托温和眼神" → "烟熏淡妆，眼神锐利不带温度"
2. `04_剧本/01_文学剧本/第1集_雪夜来客.md`
   - 旅馆登记台词：删除"请问"开头，缩短

---

## 草案 #2：...

---

[继续追加？输入更多想法 | 输入 "/执行" 启动批量影响分析]
```

#### 弱描述处理（按用户决策 B）

用户说"艾拉拉应该更冷酷一点"——agent **不反问**，而是：
1. 自己解读这句话可能的具体含义
2. 生成"我打算这么改"的具体草案
3. 让用户审：满意 → 等后续；不满意 → 用户修正解读，agent 重写草案

这样**用户不必逐字描述**，只需评判 agent 的解读对不对。

#### 影响分析（执行时触发）

用户说 `/执行` 后，agent 对所有累积草案做**统一**影响扫描：

**流程**（agent 用 Bash 工具逐步执行）：

```
对 _pending_changes.md 中每个草案：
  1. Grep wiki/ 找该草案目标实体的所有引用 → 记入"受影响文件"
  2. Grep manifest.md depends_on 字段，找到引用该资产的所有故事板 → 加入"受影响"
  3. Grep log.md 找已生成视频涉及的资产 → 加入"受影响"

汇总所有受影响文件，按规则分类风险：
  🔴 高：续集冲突 / 世界观自洽破坏 / POV 泄漏
  🟡 中：关系网破坏 / 视觉资产需重生 / 机制依赖
  🟢 低：纯文本替换 / 单点修订
```

具体 grep 命令：

```bash
# 1. 实体引用
grep -rn "草案目标实体名" "$WIKI_ROOT" --include="*.md"

# 2. 受影响故事板
grep -rln "depends_on.*草案目标实体" "$WIKI_ROOT/04_剧本/02_创作剧本" --include="manifest.md"

# 3. 已生成视频
grep -n "video_generated.*草案目标实体" "$WIKI_ROOT/log.md"
```

#### 风险三色等级

| 等级 | 类别 | 例子 |
|------|------|------|
| 🔴 高 | 续集冲突、世界观自洽、POV 泄漏 | 改职业导致入局动机崩塌 |
| 🟡 中 | 关系网破坏、视觉重生、机制依赖 | 已生成 13 张故事板需重生 |
| 🟢 低 | 纯文本替换、单点修订 | 5 处台词词汇替换 |

#### 报告模板

```markdown
📋 影响分析（草案 #1-#3 合计）

🔴 严重影响（需要重新设计）：
- [影响项 1]
  └─ 涉及文件：...

🟡 中等影响（需调整）：
- [影响项 1]
  └─ 涉及文件：...

🟢 轻微影响（文本替换）：
- [影响项 1]

📝 总计涉及文件 N 个：
- ...

⚠️ 视觉资产影响：
- M 张故事板需重生（成本估算：约 X 美元，Y 分钟）
- 这些会标记 `needs_regen: true`，可稍后批量重生

选择：
[A] 全部按草案改 + 标记需重生
[B] 我先看 diff 逐项决定
[C] 修改某条草案 / 删除某条
[D] 取消整批
```

#### 执行 + log

用户选 A 后：
1. 多文件协同 Edit
2. 受影响 manifest 标 `needs_regen: true`
3. log.md 写整段 change-session：
   ```
   - 2026-05-14 [change-session-001] 角色调整批次（3 条草案）
     - 草案 #1: 艾拉拉性格更冷酷（修 5 文件）
     - 草案 #2: 凯文改名 Kelvin（修 12 文件）
     - 草案 #3: 血月只在关键集出现（修 8 文件）
     - 共修改 25 个文件，标记 21 张故事板需重生
     - 草案归档：_archive/change-sessions/2026-05-14-001.md
   ```
4. `_pending_changes.md` 归档到 `_archive/change-sessions/`，清空当前草案

#### 撤销整个 change-session

用户说"撤销刚才的修改" → agent：
1. 读 `_archive/change-sessions/{最近一个}.md`
2. 反向 Edit 所有受影响文件（用 git 历史或草案中的 before/after）
3. log.md 追加 `[revert] 撤销 change-session-001`

---

### 13.3 查询类工作流

| 用户说 | Agent 做 | 来源 |
|--------|---------|------|
| "现在到哪了 / 进度" | 摘要：剧本/故事板/视频各阶段集数 | `index.md` 项目快照段 |
| "最近做了什么" | 列最近 5-10 条 log | `log.md` 末尾 |
| "X 角色是谁" | 摘要角色卡 | `index.md` 找路径 → Read 角色卡 |
| "X 和 Y 啥关系" | grep wiki 找关系描述 | Grep + 角色卡 |
| "第N集都涉及谁" | 读该集 manifest 的 depends_on_characters | `04_剧本/02_创作剧本/第N集_*/manifest.md` |
| "哪些故事板需要重生" | 全局 grep manifest 找 `needs_regen: true` | 所有 manifest.md |
| "搜一下 X" | 全 wiki Grep | Grep 工具 |

**查询不修改任何文件**。如果用户在查询过程中说出修改意图（"那 X 应该改成 Y 才对"），转入修改类草案模式。

---

### 13.4 模式切换规则

会话中用户可能在三种模式间跳来跳去。规则：

| 当前状态 | 用户突然说 | Agent 做 |
|---------|-----------|---------|
| 草案累积中 | 生成类口述（"做一张 X"） | 直接执行生成，**不影响**已有草案 |
| 草案累积中 | 查询类口述 | 直接答，**不影响**已有草案 |
| 草案累积中 | "执行" / "改吧" / "开始" | 触发批量影响分析 |
| 草案累积中 | "清空草案" / "都不要了" | 清空 _pending_changes.md |
| 任何状态 | "撤销刚才的" | 看上次操作是什么，对应处理（撤生成 / 撤改） |
| 任何状态 | "你能做什么" / "怎么用" | 简短说明三类操作，不要 dump 整本 SKILL |

---

### 13.5 实操示例（4 个完整场景）

#### 示例 1：纯生成（沙盒）
```
用户：做一张艾拉拉雪夜推门进旅馆，灯光昏黄，回头看血月
agent：
  [读 index.md，识别：艾拉拉 / 汽车旅馆 / 血月]
  [全资产匹配，跳过确认，直接生成]
  → 生成完毕，保存到 wiki/_sandbox/构想_20260514_2103_雪夜推门/
  → "这是你的图（展示）。满意吗 / 改 / 存到某集 / 做成视频？"
```

#### 示例 2：纯生成（关联到集）
```
用户：为第6集 P02 做一张艾拉拉车上犹豫
agent：
  [定位 04_剧本/02_创作剧本/第06集_重置/]
  [读 P02 beat 描述补充上下文]
  → 生成 → 写入 scenes/ + 更新 manifest
  → "已加入第6集。要继续 P03 还是回看 P02？"
```

#### 示例 3：单次修改
```
用户：我觉得艾拉拉应该更冷酷一点
agent：
  [写草案 #1：解读"更冷酷"的具体含义 + 列出 5 个修改点]
  → 展示草案
  → "继续追加修改？还是 /执行 开始改？"
用户：执行
agent：
  [扫影响 → 1 个 🟡 中等（5 张故事板视觉调整）+ 8 个 🟢 文本]
  [报告 → 用户选 A]
  → 修完 → log change-session
```

#### 示例 4：批量修改
```
用户：艾拉拉应该是侦探不是记者
agent：[草案 #1，展示]
用户：还有，凯文改成 Kelvin
agent：[草案 #2，展示]
用户：再有，血月只在关键集出现
agent：[草案 #3，展示]
用户：执行
agent：
  [对 3 个草案统一扫影响]
  [报告：🔴 1 项（动机崩塌）+ 🟡 3 项 + 🟢 12 项]
  [用户选 B 看 diff]
  [用户逐项确认 / 修改某条草案]
  → 批量改 → log [change-session-001]
```

---

### 13.6 失败处理

| 情境 | Agent 行为 |
|------|----------|
| 草案累积时 agent 崩溃/会话中断 | `_pending_changes.md` 持久保留，下次启动恢复"你有未执行草案，要继续吗？" |
| 影响分析中发现严重不可逆冲突 | 标 🔴 + 警告"此修改将破坏 X，建议先调整 Y" |
| 用户选 A 后某文件 Edit 失败 | 立刻停止，回滚已 Edit 的文件，告诉用户失败位置 |
| 资产标 needs_regen 但用户没重生就出视频 | 在视频生成前提示"5 张故事板未更新，确定用旧版？"
