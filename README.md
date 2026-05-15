# vibe-director 操作手册

> **VibeDirector** — 用自然语言口述做短剧的 Claude Code skill。
> 用户描述脑海中的场景 → agent 用 Wiki 知识库理解整部剧 → 出故事板 → 确认后出视频。

---

## 目录

- [1. 这是什么](#1-这是什么)
- [2. 完整使用路径（全景图）](#2-完整使用路径全景图) ⭐
- [3. 安装](#3-安装)
- [4. 首次启动（新项目）](#4-首次启动新项目)
- [5. 日常使用（已有项目）](#5-日常使用已有项目)
- [6. 三类操作详解](#6-三类操作详解)
- [7. 端到端示例](#7-端到端示例)
- [8. 版本管理（Mode E 启用后）](#8-版本管理mode-e-启用后)
- [9. Wiki 文件结构](#9-wiki-文件结构)
- [10. 命令速查](#10-命令速查)
- [11. 常见问题](#11-常见问题)
- [12. 进阶](#12-进阶)
- [13. CLI（可选但推荐）](#13-cli可选但推荐) ⚙️

---

## 1. 这是什么

`vibe-director` 是一个让 Claude Code 变成 **VibeDirector**（口语化导演）的 skill。

### 核心理念

短剧生产传统流程：写剧本 → 画分镜 → 拍/生视频 → 剪辑。
VibeDirector 流程：**口述脑海中的场景 → agent 自动完成所有中间步骤**。

### 它能做什么

| 你说 | 它做 |
|------|------|
| "做一张艾拉拉雪夜推门进旅馆" | 出故事板（30 秒-1 分钟） |
| "再暗一点 / 镜头压低" | 迭代故事板（版本化保留） |
| "做成视频" | 提交 Seedance，生 8-15 秒视频 |
| "我觉得艾拉拉应该是侦探不是记者" | 影响分析 + 多文件协同改 |
| "现在到哪了" | 基于 wiki 直接回答 |
| "我想做一部时间循环 + 狼人杀的剧" | 引导从零搭建世界观 |

### 它的依赖

- **Claude Code**（CLI 工具）
- **图片生成 API**（GPT-image-2 兼容，用于故事板）— 可选
- **视频生成 API**（Doubao Seedance 2.0）— 可选
- **对象存储**（火山引擎 TOS 等）— 可选，视频生成时上传参考图

只要写剧本不出图，**不需要任何 API**。

---

## 2. 完整使用路径（全景图）

> 不论你处于哪个阶段，先看这张图就知道下一步该去哪。

### 2.1 决策树 — 进 skill 后该走哪条路

```
                  ┌──────────────────┐
                  │  启动 Claude Code │
                  │  + 触发 skill     │
                  └────────┬─────────┘
                           │
                           ▼
                  ┌─────────────────────┐
                  │ 项目目录现状？       │
                  └────┬───────┬───────┬┘
                       │       │       │
              ┌────────┘       │       └─────────┐
              │                │                 │
        【空目录】       【单 wiki/ 已有】    【wikis/ 多版本】
              │                │                 │
              ▼                ▼                 ▼
        【选 Mode】       【日常三类操作】    【版本管理 +
        A/B/C/D                                 日常三类操作】
              │
   ┌──────────┼──────────┬──────────┐
   │          │          │          │
   ▼          ▼          ▼          ▼
 Mode A     Mode B     Mode C     Mode D
 原创       已有剧本   小说改编   导入全套素材
 从零开始   要可视化   要重新创作  结构化入库
   │          │          │          │
   └──────────┴────┬─────┴──────────┘
                   ▼
            【单 wiki/ 状态】
                   │
        ┌──────────┼──────────┐
        │          │          │
        ▼          ▼          ▼
     【生成】   【修改】    【查询】
     出图/视频  改设定/    查进度/
                改剧情     查资产
                           
     当你说"想试试别的方向"：
        ▼
     【触发 Mode E (/重构)】
        ▼
     单 wiki/ 变成 wikis/v1.0 + wikis/v2.0
        ▼
     【多版本状态】（v1.0 永久冻结）
```

### 2.2 五种入口 — 选哪个？

| 你的现状 | 选 | 进入后做什么 |
|---------|----|------------|
| 完全从零，只有一个想法 | **Mode A 原创** | agent 反问关键缺口，引导你填角色/世界观 |
| 我有完整剧本，要可视化 | **Mode B 故事板** | 粘贴剧本 → agent 拆 beat → 出故事板 |
| 我有小说，想改成剧 | **Mode C 改编** | 粘贴小说 → agent 重新规划分集 |
| 我有完整素材（剧本+角色+世界观） | **Mode D 导入** | 全部粘贴 → agent 分类入库 |
| 已有 wiki，想换个方向 | **Mode E 重构** | "我想试试暗黑版" → fork 出 Wiki 2.0 |

### 2.3 典型用户生命周期

下面是一个**完整项目**从开始到完成的时间轴。你的项目不一定经历所有阶段——根据需要跳。

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

【阶段 1 — 立项】（Day 1）

  ▢ 装 skill：cp -R 到 ~/.claude/skills/，重启 Claude Code
  ▢ 新建项目目录 + cd
  ▢ 启动 claude，触发 skill
  ▢ 选制作范围（只剧本 / +故事板 / +视频）
  ▢ 配 API（如需）
  ▢ 选 Mode A/B/C/D 入口

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

【阶段 2 — 建立世界】（Day 1-3）

  ▢ 创作方案（题材/受众/调性/结局）
  ▢ 角色开发（13-15 个角色卡 + 参考图）
  ▢ 场景定义（4-8 个场景卡 + 参考图）
  ▢ 世界观 + 时间线
  ▢ 分集目录（50-80 集规划）

  这阶段每个文件都进 wiki/，agent 自动写 index.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

【阶段 3 — 写剧本】（Day 3-30）

  日复一日：
  ▢ 写第 N 集文学剧本（800+ 字，beat 标注）
  ▢ 写第 N 集分镜剧本（创作版，含 beat 拆分）
  ▢ /自检 N 检查质量
  
  每 5 集：
  ▢ /lint 检查 wiki 一致性
  
  随时：
  ▢ 用对话调整设定（"贝基的服装太露了" → 修改类草案）

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

【阶段 4 — 出故事板】（Day 10+，可以与阶段 3 并行）

  每一集：
  ▢ /生成故事板 N（按 beat 顺序自动出图，全部图生图）
  ▢ 看图，"再暗一点" / "镜头压低" → /迭代
  ▢ manifest.md 自动记录每张图的资产依赖

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

【阶段 5 — 出视频】（每集故事板满意后）

  ▢ /Seedance N（先出提示词，免费看效果）
  ▢ 确认后 /生成视频 N（必须确认参数，按秒计费）
  ▢ 自动遮眼 → Seedance API → 裁首帧 → ffmpeg 合并粗剪
  ▢ 加字幕 → 配音 → 成片

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

【阶段 6 — 方向重构】（可选，任何时候）

  当你觉得 wiki 整体方向不对：
  ▢ "我想试试暗黑女主版" → /重构 触发 Mode E
  ▢ 第一次 fork 自动迁移：wiki/ → wikis/v1.0_*/
  ▢ wikis/v2.0a-dark/ 是新 active，v1.0 永久冻结
  ▢ 每页顶部自动加 ## Δ from v1.0 块
  ▢ 可平行 fork（v2.0a 暗黑 / v2.0b 喜剧）
  
  ▢ /对比 v1.0 vs current  随时看版本差异
  ▢ /切换版本 v2.0b  切到平行 fork

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

【阶段 7 — 维护与扩展】（持续）

  ▢ 写更多集（重复阶段 3-5）
  ▢ 改资产 → 自动 lint 警告"N 张故事板需重生"
  ▢ /lint --regen 批量重生过时故事板
  ▢ 加新角色 / 加新道具 / 改世界观
  
  Wiki 是持续复利的产物（compounding artifact）—— 越用越懂你
  Agent 通过 preferences.md 学习你的风格

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

【阶段 8 — 归档】（项目完成）

  ▢ 最终 /lint 通过
  ▢ 整个项目目录提交 git（推 GitHub 备份）
  ▢ 或归档到 iCloud / 网盘
  
  Wiki 是永久产物——日后可以基于它再 fork、再创作

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 2.4 关键岔路口 — 什么时候用什么

| 你想 | 用 | 走哪个流程 |
|------|----|----|
| 创造新东西（图/视频/集） | **生成类** | 直接说 "做一张..."，agent 立即生成（图片跳过确认） |
| 调整现有东西（设定/角色/剧情） | **修改类** | 自然语言说改动 → agent 出草案 → 累积 → `/执行` 批量改 |
| 询问/查找/汇总 | **查询类** | 直接问，agent 基于 wiki 答 |
| 改方向（整体不对劲） | **Mode E 重构** | "我想试试 X 版" → fork 出 wiki 2.0 |
| 撤销刚才的改动 | **撤销** | `/撤销` 反向 Edit 最近 change-session |
| 看版本之间差异 | **对比** | `/对比 v1.0 vs current` |

### 2.5 反向使用路径（修复/回退）

不是所有流程都向前走。常见的"修复"路径：

| 情境 | 应对 |
|------|------|
| 改错了 | `/撤销` → 反向 Edit |
| 草案累积太多想清空 | `/清空草案` |
| 试错的 fork 不想要了 | `/删除版本 vX`（实际归档不真删） |
| Wiki 状态混乱 | `/lint` → 看报告 → `/lint --fix-*` 自动修复 |
| 想冻结某版本不要被改 | 切到别的 active，那一版就自动冻结 |
| 想解冻旧版本回去改 | `/解冻 vX` + 输入"确认解冻 vX" |

---

## 3. 安装

### Step 1: 准备 Claude Code 环境

如果还没装 Claude Code：
```bash
# 参考 Claude Code 官方安装文档
brew install claude  # 或其他方式
```

### Step 2: 把 skill 放到 Claude 的 skills 目录

```bash
mkdir -p ~/.claude/skills/
cp -R /path/to/vibe-director ~/.claude/skills/vibe-director

# 安装 CLI（推荐）
bash ~/.claude/skills/vibe-director/cli/install.sh
# 这会把 vibe-director 命令软链到 ~/.local/bin/
# 如果 ~/.local/bin 不在 PATH，按提示加到 .zshrc
```

CLI 是可选的，但**强烈建议安装**——它强制执行硬规则（.frozen 拒写）+ 加速 fork（30 文件 5 秒搞定）+ 加速 lint 等。详见下面的 §13。

确认安装成功：
```bash
ls ~/.claude/skills/vibe-director/
# 应该看到：
# SKILL.md  README.md  references/
```

### Step 3: 重启 Claude Code

Skill 需要 Claude Code **重启**才能被识别。重启后，输入 `/help` 应该能看到 skill 列表里有 `vibe-director`。

也可以让当前会话**直接加载**（不重启）：让 agent 读取 `~/.claude/skills/vibe-director/SKILL.md`。但**正式使用建议重启**，让 skill 真正进入 skill registry。

---

## 4. 首次启动（新项目）

### Step 1: 创建项目目录

```bash
mkdir -p ~/Documents/my-drama
cd ~/Documents/my-drama
```

### Step 2: 启动 Claude Code 并触发 skill

```bash
claude
```

然后输入任一触发：
- `/vibe-director`（显式触发）
- 或自然语言：「我想做一部短剧」、「教我用 VibeDirector」

### Step 3: 跟随 skill 引导

Skill 检测到目录是空的（无 `wiki/index.md`），会问你三件事：

#### 4.1 制作范围

```
你想做哪个范围的工作？
[1] 只写剧本（不出图、不出视频）— 无需任何 API
[2] 剧本 + 故事板 — 需要图片生成 API
[3] 剧本 + 故事板 + 视频 — 需要全套 API（最贵）
```

#### 4.2 API 配置（如选 2 或 3）

会创建 `wiki/api-config.md`，引导你填入：

```yaml
# 图片生成 API（任选一个 OpenAI 兼容的 GPT-image-2 服务）
img_api_edit: "https://your-provider.com/v1/images/edits"
img_api_key: "sk-xxx"
img_api_model: "gpt-image-2"

# 视频生成 API（如选范围 3）
vid_api: "https://api-provider.com/v1/videos"
vid_api_key: "sk-xxx"
vid_model: "doubao-seedance-2-0-260128"

# 对象存储 TOS（视频生成时上传参考图）
tos_endpoint: "tos-cn-beijing.volces.com"
tos_bucket: "your-bucket"
tos_ak: "xxx"
tos_sk: "xxx"
```

#### 4.3 创作模式

```
你想怎么开始？
[A] 原创剧本 — 从零开始（题材 → 创作方案 → 角色 → 剧本）
[B] 剧本改故事板 — 已有剧本，只要可视化
[C] 小说改编 — 给我一本小说，改成剧
[D] 导入既有素材 — 已有完整短剧（剧本+角色+世界观），一次性入库
[E] 方向性重构 — 已有 wiki，想换方向（更暗黑/换主角/换年代等）→ Wiki 2.0
```

### Step 4: 生成 Wiki 骨架

Skill 创建：

```
my-drama/
├── CLAUDE.md                  # 项目使命（agent 启动必读）
└── wiki/
    ├── index.md               # Agent 索引
    ├── 导航.md                # 给人看的 Obsidian 导航
    ├── preferences.md         # 用户偏好层
    ├── api-config.md          # API 配置（敏感）
    ├── log.md                 # 操作日志
    ├── raw/                   # 原始素材（不可变）
    ├── 01_资产/01_角色/        
    ├── 01_资产/02_场景/        
    ├── 02_故事/                
    ├── 03_视角/                
    ├── 04_剧本/                
    └── 05_视频/                
```

### Step 5: 开始口述

```
你：我想做一个时间循环 + 真人狼人杀的剧
agent：[反问关键缺口]
       - 主角是谁？为什么入局？
       - 循环触发条件是什么？
       - 第一季多少集？
你：（回答）
agent：[把回答写入对应 wiki 板块] → "下一步建议：定主角外貌"
```

---

## 5. 日常使用（已有项目）

### Step 1: 进入项目目录

```bash
cd ~/Documents/my-drama
claude
```

### Step 2: Agent 自动加载上下文

Claude Code 启动时：
- 自动加载项目根的 `CLAUDE.md`（项目使命）
- skill 被触发时自动读 `wiki/index.md` + `wiki/preferences.md`

你看到的第一屏（理想效果）：
```
👋 血月轮回 · 美式狼人恐怖微短剧
进度：文学剧本 1-20 集 / 分镜剧本 1-72 集 / 故事板+视频 1-5 集
偏好：冰蓝调 + 写实摄影 + 多角色图生图
你想做什么？
```

### Step 3: 自由口述

不用记命令，自然语言说就行：

- "继续做第 6 集的故事板"
- "给我看艾拉拉的图"
- "我觉得贝基的服装太露了，改保守一点"
- "现在哪些故事板需要重生成？"
- "把刚才那张存到第 7 集 P03"

---

## 6. 三类操作详解

### 5.1 生成类（创造新内容）

| 你说 | 它做 |
|------|------|
| "做一张 X 的故事板" | 出图，存到沙盒（`wiki/_sandbox/`） |
| "为第 N 集 P{beat} 做一张 X" | 出图，直接存到对应集 |
| "再暗一点 / 镜头压低" | 迭代上一张，归档 v1 到 `_versions/`，生 v2 |
| "做成视频" / "出 12 秒视频" | **必须确认** Seedance 参数后才提交 |
| "为第 N 集出全套故事板" | 按 beat 顺序逐张生成 |
| "写第 N 集的文学剧本" | 基于创作方案+角色卡+前后集写 800+ 字 |

**关键点**：
- 图片生成**跳过**确认（低成本，快）
- 视频生成**必须**确认（按秒计费）

### 5.2 修改类（变更已有内容）

这是 VibeDirector 最强的能力。**不是边说边改，而是先草案、再批量、再执行。**

#### 工作流

```
[修改类口述 #1] → agent 写草案 #1 给你审
[修改类口述 #2] → agent 写草案 #2
[修改类口述 #3] → agent 写草案 #3
[你说"执行"]    → agent 批量扫影响 → 报告 → 你选 A/B/C/D → 改
```

#### 例子

```
你：我觉得艾拉拉应该更冷酷一点

agent：[写草案 #1]
       📝 草案 #1：艾拉拉性格调整
       
       理解："更冷酷"意味着：
       - 减弱：温和眼神、对陌生人的好奇
       - 加强：拒绝人情、对死亡的麻木
       
       具体修改：
       1. 01_资产/01_角色/艾拉拉·万斯.md
          - 性格特征 #1：「极度理性」→「极度理性，几乎冷血」
          - ...
       2. 第1集_雪夜来客.md
          - 旅馆登记台词：删除"请问"，缩短
       
       [继续追加？还是 /执行 开始改？]

你：还有，凯文改名叫 Kelvin

agent：[写草案 #2]

你：执行

agent：[扫影响]
       📋 影响分析（草案 #1-#2 合计）
       
       🔴 严重：无
       🟡 中等：5 张故事板视觉调整
       🟢 轻微：22 处台词词汇替换
       
       📝 涉及 17 个文件
       ⚠️ 5 张故事板会标 needs_regen=true
       
       选择：
       [A] 全部按草案改 + 标记需重生
       [B] 我先看 diff 逐项决定
       [C] 修改某条草案
       [D] 取消

你：A

agent：[多文件协同改 → log 写 change-session-001]
       ✅ 改完 17 个文件，5 张故事板标记需重生
       下一步建议：要现在重生这 5 张故事板吗？（约 5 分钟，$1.5）
```

### 5.3 查询类（不修改任何文件）

| 你说 | 它做 |
|------|------|
| "现在到哪了" | 基于 index.md 项目快照答 |
| "最近做了什么" | 读 log.md 末尾 5-10 条 |
| "X 是谁" | 找路径 → 读角色卡摘要 |
| "X 和 Y 啥关系" | grep wiki + 读卡 |
| "第 N 集涉及谁" | 读该集 manifest |
| "哪些故事板需要重生" | 全局 grep `needs_regen: true` |
| "搜一下 X" | grep |

---

## 7. 端到端示例

### 场景：从零做一集

```
[Day 1] 创作
你：我想做第 21 集，剧情大概是艾拉拉发现凯文是混血儿
agent：[读 index 看前 20 集进度] → "好。前一集（20 集）结尾是凯文影子异常，
       第 21 集如果用'发现'作为转折，建议放在 P05 高潮。我先起草分集卡片？"
你：好
agent：[写第 21 集 beat 大纲到 04_剧本/02_创作剧本/第21集_*/]
       展示 P01-P08 beat 概要
你：P05 的发现方式改一下，让她在浴室看到凯文用爪子刮镜子
agent：[修改 P05 beat]
你：写出来吧
agent：[基于 beat 写 800+ 字文学剧本到 01_文学剧本/]
       → "完了。要现在出故事板吗？"

[Day 2] 出图
你：出故事板
agent：[按 P01-P08 顺序逐张生成图生图，全部用对应角色参考图]
       → 8 张图，存到 04_剧本/02_创作剧本/第21集_*/scenes/
       → 自动写 manifest.md 记录每张图的资产依赖
你：P05 的爪子改成血色不要灰色
agent：[/迭代 第21集 P05] 归档 v1 → 生 v2
你：好

[Day 3] 视频
你：做成视频
agent：[列 8 个 beat 的参数表]
       "默认 12 秒 / 1080p / 16:9，总时长 96 秒，估算成本 $X，确认？"
你：第 5 个改成 15 秒，其他不变
agent：[调整参数] → "确认？"
你：确认
agent：[遮眼处理 → Seedance 提交 → 轮询 → 下载 → 裁首帧]
       → 8 个视频到 05_视频/第21集_*/01_beats/
       → ffmpeg concat 合并到 02_粗剪/
       → "粗剪完成。要现在加字幕吗？"
```

### 场景：修改世界设定

```
你：我重新想了一下，血月不应该每集都出现，应该只在关键集（5/10/15/20/25 集）出现
agent：[草案 #1]
       📝 草案 #1：血月出现频率调整
       理解：将血月从"每集 BGM"改为"关键集专属意象"。
       具体修改：
       - 02_故事/03_传说/狼人传说.md：修改"血月每夜可见" → "仅银月审判夜可见"
       - 第 1-20 集剧本：删除非关键集的血月描述（共 14 处）
       - 故事板：8 张含血月的非关键集图片标 needs_regen
       
你：执行

agent：[扫影响]
       🟡 中等：故事板视觉差异（8 张需重生）
       🟢 轻微：14 处剧本文本删除
       
       选择 A/B/C/D...
你：A

agent：[改完]
       ✅ 23 个文件已改，8 张故事板标记需重生
       建议：要现在重生这 8 张吗？(估算 $2, 8 分钟)
```

### 场景：导入既有素材（Mode D）

```
你：我有一套完整的短剧设定和前 5 集剧本，要导入

agent："好。给我素材（粘贴/文件路径/一段段加都行）"

你：[粘贴 5000 字混合内容]
agent：[存到 raw/原始素材_part1.md] "还有更多吗？"
你：[粘贴角色补充 2000 字]
agent：[存到 raw/原始素材_part2.md] "还有吗？"
你：就这些

agent：[分类识别]
       📋 我识别到 12 段素材：
       - part1 → 世界观（1500 字）+ 时间线 + 5 角色 + 第 1 集剧本
       - part2 → 8 个角色补充
       对吗？

你：part2 里其实有 2 个是道具（古代药剂、血月手镯）

agent：[修正分类]
       [实体抽取]
       - 世界观规则：7 条
       - 时间线事件：12 个
       - 角色：11 个（3 个外貌为 TODO）
       - 道具：2 个
       - 剧本：1 集（自动拆为 P01-P06）

       [映射方案]
       将创建 16 个文件 + 更新 index.md
       ⚠️ 当前 wiki 为空，无冲突
       
       [A/B/C/D]
你：A

agent：[批量 Write 16 文件 → 加交叉引用 → 更新 index → 跑 /lint]
       ✅ 导入完成
       [lint] 3 个角色没有视觉参考图，要现在生成吗？
```

### 场景：方向性重构（Mode E — Wiki 1.0 → 2.0）

```
你：我想试试暗黑版，把主角改成女性

agent：[解析方向 → 查 direction-dictionary]
       识别 2 个 patch：
       - tone-darken（调性更暗黑）
       - protagonist-gender-swap（主角性别互换）
       
       ⚠️ 第一次 /重构，将启动版本系统：
       - wiki/ → wikis/v1.0_2026-05-14/（永久冻结）
       - 创建 wikis/v2.0a-dark/（active，待应用 patches）
       
       确认开始？

你：好

agent：[迁移目录结构 → v1.0 加 .frozen]
       [应用 tone-darken 草案]：将修 v2.0a-dark/ 下 15 文件...
       [应用 protagonist-gender-swap 草案]：将修 12 文件...
       
       两个 patch 影响汇总：
       🔴 严重：主角性别变化导致 13 张故事板需全部重生
       🟡 中等：v2.0 所有角色卡和剧本里"他"→"她"
       🟢 轻微：22 处词汇调整
       
       [A] 全部应用 / [B] 看 diff / [C] 取消

你：A

agent：[多文件改 + 每页加 ## Δ from v1.0 块]
       ✅ v2.0a-dark 生成完成，37 个文件已改
       [自动 lint 跨版本检查通过]
       
       现在：
       - wikis/current → v2.0a-dark/（active）
       - wikis/v1.0_2026-05-14/（frozen，只读）
       
       下一步：看哪一页可以 /对比 v1.0 vs current
       
你：对比 艾拉拉

agent：[列 v1.0 vs current 艾拉拉卡 diff]
       - 性别：男 → 女
       - 性格："温和坚定" → "几乎冷血"
       - 入局动机："寻找失踪兄弟" → "调查死亡伴侣"

你：v1.0 那张原版我想看看
agent：[Read wikis/v1.0_2026-05-14/01_资产/01_角色/艾拉拉·万斯.md 展示]
       注：v1.0 已冻结，如要修改请用 /解冻

你：把 v2.0 的艾拉拉年龄改大 3 岁
agent：[草案 #3] [在 v2.0a-dark/ 范围内修改]
       （v1.0 保持不变）
```

---

## 8. 版本管理（Mode E 启用后）

### 何时启用版本系统

- 单 wiki 时不启用，目录结构保持简单（`wiki/`）
- 第一次执行 `/重构` 时自动启用，迁移到 `wikis/` 结构

### 核心规则

| 规则 | 说明 |
|------|------|
| **只有一个 active** | 任何时刻仅 `wikis/current` 指向的版本可改 |
| **其他全冻结** | 所有非 active 版本含 `.frozen` 标记，agent 拒绝写入 |
| **冻结是不可绕过的** | 必须 `/解冻 vX` + 输入"确认解冻 vX"才能改 |
| **切换自动管理** | `/切换版本 vX` 自动冻结旧 active，解冻新 active |
| **删除是归档** | `/删除版本 vX` 实际 mv 到 `_archive/deleted_versions/` |

### 多版本目录

```
project/
├── CLAUDE.md
└── wikis/
    ├── current → v2.0a-dark/         # 软链或 .active 文件
    ├── v1.0_2026-05-14/               # 冻结
    │   ├── .frozen                    
    │   ├── index.md
    │   ├── 01_资产/
    │   ├── 02_故事/
    │   └── ...
    └── v2.0a-dark/                    # active
        ├── _patches_applied.md        # 已应用 patch 列表
        ├── index.md
        ├── 01_资产/
        │   └── 01_角色/
        │       └── 艾拉拉·万斯.md      # 顶部含 ## Δ from v1.0 块
        └── ...
```

### 双向链接（frontmatter）

**v1.0 卡片**：
```yaml
---
version: v1.0_2026-05-14
status: frozen
forked_to:
  - wikis/v2.0a-dark/01_资产/01_角色/艾拉拉·万斯.md
---
```

**v2.0 卡片**：
```yaml
---
version: v2.0a-dark
status: active
forked_from: wikis/v1.0_2026-05-14/01_资产/01_角色/艾拉拉·万斯.md
patches_applied: [tone-darken, protagonist-gender-swap]
---
```

### Δ 块（v2.0 每页顶部）

```markdown
# 艾拉拉·万斯

> ## Δ from v1.0 (2026-05-14, patches: tone-darken + protagonist-gender-swap)
> - 性别：男 → 女
> - 性格："温和坚定" → "几乎冷血"
> - 入局动机："寻找失踪兄弟" → "调查死亡伴侣"
>
> [📜 看 v1.0 原版](../v1.0_2026-05-14/01_资产/01_角色/艾拉拉·万斯.md)
```

### 方向 → Patch 词典

完整词典见 `references/direction-dictionary.md`。常见方向：

| 用户说 | 编译为 patch |
|--------|------------|
| 更暗黑 / 压抑 / Nordic noir | `tone-darken` |
| 更轻松 / 加点幽默 | `tone-lighten` |
| 换主角性别 | `protagonist-gender-swap` |
| 主角职业改成 X | `protagonist-job-change` |
| 背景改到 X 年 | `setting-time-shift` |
| 去掉感情线 | `genre-strip-romance` |
| 节奏更快 | `pacing-faster` |
| 完全重构 | `full-restructure`（agent 会反问"要不要直接重做"）|

Patches **可叠加**（暗黑+换主角性别 = 两个 patch 串行应用），冲突时 agent 警告（如 tone-darken vs tone-lighten 不能同时用）。

### 危险操作清单

| 操作 | 风险 | 防护 |
|------|------|------|
| `/解冻 vX` | 破坏 v2.0 对 v1.0 的引用基准 | 必须输入"确认解冻 vX" |
| `/删除版本 vX` | 失去 fork 历史 | 必须先 frozen + 输入"删除 vX"，且实际是归档不真删 |
| `/导入 --replace` | 全替换现有 wiki | 自动备份到 `_archive/before_replace_{ts}/` + 强确认 |
| `full-restructure` patch | 几乎重做一遍 | agent 强烈反问，建议直接 Mode A |

---

## 9. Wiki 文件结构

```
项目根/
├── CLAUDE.md                       # 项目使命，agent 启动必读
└── wiki/
    ├── index.md                    # ⭐ Agent 索引（每条目：路径+8-15字摘要）
    ├── 导航.md                     # 给人看的 Obsidian 导航
    ├── 创作方案.md                  # 项目纲领
    ├── preferences.md              # ⭐ 用户偏好层
    ├── api-config.md               # API 配置（敏感）
    ├── log.md                      # ⭐ 操作日志（append-only）
    ├── _pending_changes.md         # （临时）累积草案
    │
    ├── raw/                        # 不可变原始素材
    │   └── 创作方案_v0.md
    │
    ├── _sandbox/                   # 临时构想沙盒
    │   └── 构想_20260514_2103_雪夜推门/
    │       ├── description.md
    │       ├── prompt.md
    │       ├── output.png
    │       └── _versions/
    │
    ├── _archive/                   # 归档
    │   └── change-sessions/
    │       └── 2026-05-14-001.md
    │
    ├── 01_资产/                    # 可复用素材
    │   ├── 01_角色/
    │   │   ├── 艾拉拉·万斯.md       # 角色卡
    │   │   └── images/
    │   │       └── elara_vance.png # 参考图（图生图输入）
    │   ├── 02_场景/
    │   ├── 03_道具/（可选）
    │   └── 04_音频/（可选）
    │
    ├── 02_故事/                    # 上帝视角的完整世界
    │   ├── 世界观.md
    │   ├── 完整时间线.md
    │   ├── 01_身份/
    │   ├── 02_机制/
    │   └── 03_传说/
    │
    ├── 03_视角/                    # 观众认知管理
    │   ├── POV设定.md
    │   └── 第N集_观众已知.md
    │
    ├── 04_剧本/
    │   ├── 分集目录.md
    │   ├── 01_文学剧本/            # 给人看的
    │   │   └── 第N集_标题.md
    │   └── 02_创作剧本/            # 给模型用的
    │       └── 第N集_标题/
    │           ├── 第N集_标题.md   # 分镜剧本（含 beat）
    │           ├── manifest.md     # ⭐ 资产依赖清单
    │           ├── scenes/         # 故事板图片
    │           │   ├── S01ENN_SB01_P01_xxx.png
    │           │   └── _versions/  # 迭代历史
    │           ├── videos/         # beat 视频
    │           └── seedance-prompts.md
    │
    └── 05_视频/
        └── 第N集_标题/
            ├── 01_beats/           # beat 级视频
            ├── 02_粗剪/            # 合并版
            └── 03_成片/            # 含字幕配音
```

⭐ 标记的文件是 **agent 必读的核心 wiki 原语**。

---

## 10. 命令速查

> **重要**：你**不必**用命令——自然语言就行。命令只是显式触发的快捷方式。

### 模式入口

| 命令 | 功能 |
|------|------|
| `/vibe-director` | 启动 skill |
| `/原创` | Mode A：原创剧本全流程 |
| `/故事板` | Mode B：剧本改故事板 |
| `/改编` | Mode C：小说改剧本 |
| `/导入` | Mode D：导入既有素材（追加） |
| `/导入 --merge` | Mode D 合并模式（冲突时显 diff） |
| `/导入 --replace` | Mode D 替换模式（备份+强确认） |
| `/重构 "方向"` | Mode E：fork 出新版本 |

### 版本管理

| 命令 | 功能 |
|------|------|
| `/版本` | 列出所有版本，标 active 和 frozen |
| `/切换版本 vX` | 切 active 指针；旧 active 自动冻结 |
| `/对比 vX vs vY` | 列两版差异 |
| `/解冻 vX` | 显式解冻（需输入"确认解冻 vX"） |
| `/删除版本 vX` | 移除 fork（必须先 frozen + 强确认） |

### 创作

| 命令 | 功能 |
|------|------|
| `/创作方案` | 生成创作方案 |
| `/角色开发` | 角色档案 + 参考图 |
| `/目录` | 分集目录（50-70集） |
| `/分集 N` | 撰写第 N 集剧本 |
| `/自检 N` | 第 N 集质量评估 |

### 生成（生成类）

| 命令 | 功能 |
|------|------|
| `/生成故事板 N` | 第 N 集所有 beat 出故事板 |
| `/迭代 N P{beat} "指令"` | 迭代某张故事板 |
| `/Seedance N` | 第 N 集生成 Seedance 提示词（仅文本） |
| `/生成视频 N` | 第 N 集出视频（需确认） |
| `/配图 角色名` | 生成角色/场景参考图 |

### 修改（修改类）

| 命令 | 功能 |
|------|------|
| `/草案` | 显示当前累积的修改草案 |
| `/执行` | 触发批量影响分析 + 执行 |
| `/清空草案` | 丢弃所有未执行草案 |
| `/撤销` | 撤销最近一次 change-session |

### 沙盒

| 命令 | 功能 |
|------|------|
| `/沙盒` | 列出 `_sandbox/` 下所有临时构想 |
| `/提升 {沙盒名} → 第N集 P{beat}` | 沙盒构想升级到正式集 |

### 健康检查

| 命令 | 功能 |
|------|------|
| `/lint` | Wiki 健康检查 |
| `/lint --fix-index` | 自动重建 index.md |
| `/lint --fix-manifest` | 回填缺失的 manifest.md |
| `/lint --fix-orphan` | 列出孤儿资产 |
| `/lint --regen` | 列出 needs_regen 故事板 + 批量重生 |

### 其他

| 命令 | 功能 |
|------|------|
| `/配置` | 重新配置 API |
| `/合规` | 内容合规审核 |
| `/指令` | 显示所有命令 |

---

## 11. 常见问题

### Q1: 我没有图片 API，能用吗？
能。选"只写剧本"范围，全程不需要 API。所有命令里只有生成图/视频会失败，其他都正常。

### Q2: 我已经有剧本了，能直接出故事板吗？
能。把剧本放进 `04_剧本/01_文学剧本/`，然后说 "为第 N 集出故事板"。如果剧本没有 beat 标记（`### P01：标题`），skill 会先帮你拆 beat。

### Q3: 我换电脑了，wiki 怎么同步？
推荐：
- iCloud Drive（macOS 内置，文件大时可能慢）
- Git + GitHub（最稳，但需要 LFS 处理图片/视频）
- Syncthing / Dropbox

注意 `api-config.md` 含密钥，**别提交到公开仓库**。

### Q4: 故事板生成失败怎么办？
1. 检查 `api-config.md` 配置正确
2. 检查角色参考图存在（`01_资产/01_角色/images/`）
3. 检查 API 余额
4. 让 agent 重试：`/迭代 第N集 P{beat} "重新生成"`

### Q5: 视频生成太贵了怎么办？
- 先用 Seedance 提示词（`/Seedance N`）—— 只出文本提示词，不计费
- 满意后再 `/生成视频 N`
- 单 beat 测试：`/生成视频 第N集 P{beat}` 而不是整集
- 用 720p 而不是 1080p

### Q6: 我改了角色卡，故事板要不要重生？
看 `/lint` 报告。每张故事板的 manifest 会标 `needs_regen: true`。重生与否由你决定：
- 角色面部变化大 → 必须重生
- 服装小调整 → 可暂不重生
- 性格调整（不影响视觉）→ 不必重生

### Q7: 我能并行做多集吗？
可以，但 API 是串行的（避免超限）。Skill 默认按 beat 顺序生成。如果你有多个 Claude Code 实例，可以分集并行，但要注意 `_pending_changes.md` 别冲突。

### Q8: Agent 没按 SKILL.md 走怎么办？
1. 确认 skill 真的被加载（`/help` 看列表）
2. 确认在 wiki 根目录（不是子目录）
3. 重启 Claude Code
4. 主动说 "请遵循 SKILL.md 的冷启动协议"

### Q9: `_pending_changes.md` 累积太多怎么办？
- `/草案` 查看
- `/清空草案` 全清
- 或者 `/执行` 真的执行掉

### Q10: 多人协作怎么处理？
目前 skill **未设计**多人并发——一人一时段。如果团队协作：
- 用 Git，每个人在 feature branch 工作
- 修改类操作上传到 PR，由一人 merge
- `_pending_changes.md` 不要共享，本地化

---

## 12. 进阶

### 10.1 自定义 preferences

编辑 `wiki/preferences.md`，在对应类别下追加你的偏好：

```markdown
## 视觉风格

### 色调偏好
- **我的偏好**：高对比的 noir 风格，重阴影，少高光
```

Agent 每次生成前会读 preferences。

### 10.2 自定义 CLAUDE.md

`项目根/CLAUDE.md` 是 agent 启动**必读**的项目使命。可以放：
- 项目核心目标（VibeDirector 已默认）
- 团队约定（如"角色不能死超过 50%"）
- 风格指令（"始终用克制叙事，不要旁白"）

### 10.3 模板批量启动新项目

把现有 wiki 结构作为模板：

```bash
cp -R ~/Documents/template-drama ~/Documents/new-drama
cd ~/Documents/new-drama
# 编辑 CLAUDE.md 和 wiki/index.md 适配新项目
```

### 10.4 与 Obsidian 配合

打开 `项目根/wiki/` 作为 Obsidian Vault：
- `导航.md` 就是首页
- 所有 `[[]]` 双链可用
- 图片/视频内嵌显示
- 可用 graph view 看角色关系

### 10.5 lint 定期检查

每完成一个里程碑（一集 / 一幕 / 一季），跑一次 `/lint`：
- 检查 wiki 一致性
- 找出 needs_regen 故事板
- 找出孤儿资产
- 找出引用断链

修复后再继续，避免后期累积问题。

### 10.6 撤销与回滚

如果整次 change-session 改坏了：
1. `/撤销` 反向 Edit
2. 或用 git：`git reset --hard HEAD~1`（如果 commit 过）

Skill 自己不做版本控制，强烈建议 **wiki 进 git**，每个里程碑提交一次。

---

## 13. CLI（可选但推荐）

skill 配套有一个 bash CLI（`cli/vibe-director`），把"确定性 + 高风险"的操作交给代码，agent 只做"创意 + 决策"。

### 4 个命令

| 命令 | 用途 | 何时被调用 |
|------|------|----------|
| `vibe-director check-frozen <path>` | 检查路径是否在冻结版本下 | Agent 每次 Edit/Write 前 |
| `vibe-director fork --to <name> --patches <list>` | 复制 wiki + 加 .frozen + 写 patches 待办 | 用户说"试试 X 版" |
| `vibe-director scan <file>` | 统计文件中已知实体 + [[]] 引用 + 候选新名 | Agent 写完剧本后 |
| `vibe-director lint [--json]` | 9 项 wiki 健康检查 | 周期检查 / 用户问"现状" |

### 为什么 CLI 比纯 markdown 规则好

**例 1：Frozen 拒写**
- 没 CLI：靠 agent 看 SKILL.md 自觉。一不小心 LLM 忘了就违反。
- 有 CLI：`check-frozen` 是代码，exit 1 = 强拒。agent 必须看到错误。

**例 2：Fork 速度**
- 没 CLI：agent 一个个 Read → 推理 → Edit 30+ 文件，2-5 分钟。
- 有 CLI：一次 `cp -R` + 写 .frozen + 写 _patches_applied.md，5 秒。

**例 3：Lint 一致性**
- 没 CLI：agent 跑 lint 每次结果可能略不同（LLM 非确定性）。
- 有 CLI：9 项检查是代码，相同 wiki 永远相同报告。

### 安装

```bash
bash ~/.claude/skills/vibe-director/cli/install.sh
# 软链到 ~/.local/bin/vibe-director
# 加 ~/.local/bin 到 PATH（如还没）
```

### Agent 怎么调

Agent 通过 Bash 工具调：

```bash
~/.claude/skills/vibe-director/cli/vibe-director check-frozen ./wiki/index.md
~/.claude/skills/vibe-director/cli/vibe-director lint --json
~/.claude/skills/vibe-director/cli/vibe-director scan wiki/04_剧本/01_文学剧本/第21集.md
~/.claude/skills/vibe-director/cli/vibe-director fork --to v2.0a-dark --patches tone-darken
```

### 退出码

| 退出码 | 含义 | Agent 应如何反应 |
|-------|------|--------------|
| 0 | 成功 / 全通过 | 继续 |
| 1 | 警告 / 冻结拒写 | 停止并告知用户 |
| 2 | 错误 / 无效输入 | 报错给用户，让用户修 |

### 设计原则

- **CLI 做机械执行**：文件操作、模板填充、检查、统计
- **Agent 做创意/决策**：解读意图、写剧本、出图、提供修改方案
- **CLI 失败不可绕过**：agent 看到 exit 1 必须停，不能自己 Edit 强写

详细 CLI 实现见 `cli/lib/*.sh`。

---

## 附录：理论基础

`vibe-director` 的 wiki 架构基于：

- **Karpathy 的 LLM Wiki 理论**（2026-04）：`raw/` + `wiki/` + `CLAUDE.md` + `index.md` + `log.md` 五原语
- **LLM Wiki v2**（社区扩展）：supersession + confidence + 知识图谱
- **Avi Chawla "next step"**：typed-entity + backlink-based 动态上下文
- **INSIGHTS_LOG**：偏好沉淀的 append-only 模式
- **VibeDirector**（本 skill 原创）：把 wiki 用作 agent 认知基质 + 口语化对话层

---

**有问题？** 让 agent 直接打开 SKILL.md 找规范，或者编辑这个 README.md 贡献你的发现。
