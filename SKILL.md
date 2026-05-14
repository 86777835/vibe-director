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
3. $PWD/wiki/preferences.md  ← 用户风格偏好
```

读完后才回应用户。详细的冷启动协议见 **§十一**。
意图识别（自然语言 → 动作）见 **§十一·B**。

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

## 一、制作范围与 API 配置

### 1.1 制作范围（首次必问）

首次使用时，**首先**用 AskUserQuestion 询问用户要做什么范围的工作：

| 范围 | 说明 | 需要的 API |
|------|------|-----------|
| **只写剧本** | 剧本创作 + 角色开发 + 分集目录，无图片/视频 | 无 |
| **剧本 + 故事板** | 剧本 + 图生图故事板 + Seedance 提示词（仅文本） | 图片生成 API |
| **剧本 + 故事板 + 视频** | 全流程，包含 Seedance 视频生成和合并 | 图片生成 API + 视频生成 API + 对象存储 |

用户的选择决定后续需要配置哪些 API。如果用户选择"只写剧本"，跳过所有 API 配置直接进入创作。

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
3. 如果没有 → 根据制作范围收集对应的 API 信息：
   - **只写剧本**：跳过 API 配置
   - **剧本 + 故事板**：收集图片生成 API（endpoint、key、model）
   - **剧本 + 故事板 + 视频**：收集图片生成 API + 视频生成 API + 对象存储
4. 写入 `api-config.md`

**重新配置**：`/配置` 命令可随时修改 API 设置。

**读取方式**：每次需要调用 API 时，用 Read 工具读取 `api-config.md` 的 YAML frontmatter，提取所需字段。

### 1.3 视频生成 API（仅全流程需要）

**提交视频生成任务**：
```python
payload = {
    'model': vid_model,          # 如 'doubao-seedance-2-0-260128'
    'prompt': seedance_prompt,
    'metadata': {
        # 参考模式：不设 role 字段，图片仅做视觉参考
        'content': [{'type': 'image_url', 'image_url': {'url': image_url}}],
        'resolution': '1080p',
        'ratio': '16:9',
        'duration': beat_duration,   # 8/10/12/15 秒
    }
}
# POST → vid_api
# 轮询 → GET vid_api/{task_id}
# 下载 → 保存到 04_剧本/02_创作剧本/第N集/videos/
```

**重要参数说明**：
- `metadata.duration`：视频时长（秒），最长 15 秒。**必须放在 metadata 里**，顶层会被忽略
- `metadata.content` 中**不设 `role` 字段** = 参考模式（推荐）。设 `role: "first_frame"` 会导致首帧就是故事板
- `metadata.resolution`：`"720p"` 或 `"1080p"`
- `metadata.ratio`：`"16:9"` / `"9:16"` / `"1:1"`

### 1.4 图片上传（对象存储 / TOS）

视频生成需要故事板图片的公开 URL。如果 Wiki 中图片只有本地路径，需上传到对象存储：

```python
import tos
client = tos.TosClientV2(ak=tos_ak, sk=tos_sk, endpoint=tos_endpoint, region=tos_region)
client.put_object_from_file(tos_bucket, tos_key, local_image_path)
# 公开 URL: https://{tos_bucket}.{tos_endpoint}/{tos_key}
```

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

## 六、故事板生成引擎

### 核心原则

1. **必须使用图生图（image-to-image）**：每张故事板必须以 Wiki 中的角色参考图作为输入，保持角色面部一致性
2. **专业电影预生产设计板**（Production Design Board）：包含 10 个板块（导演意图、角色设计、场景设计、机位调度、摄影规格、灯光参考、色彩脚本、3 帧分镜、Seedance 适配说明）
3. **写实电影摄影风格**：真人质感渲染，与角色参考图保持一致。Seedance 真人审核通过遮眼方案绕过

### 读取规范

读取 [storyboard-spec.md](references/storyboard-spec.md) 和 [storyboard-prompts.md](references/storyboard-prompts.md) 获取完整规范。

### 生成流程（每个 beat）

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

```python
import json, base64
with open('/tmp/sb_response.json') as f:
    d = json.load(f)
image_data = d['data'][0].get('url') or d['data'][0].get('b64_json')
if image_data.startswith('http'):
    # 下载 URL
elif image_data:
    # 解码 base64
# 保存到: 04_剧本/02_创作剧本/第N集_标题/scenes/S{季}E{集}_SB{编号}_P{beat}_{描述}.png
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

定期执行 Wiki 一致性检查。灵感来自 Karpathy LLM Wiki 的 lint 操作——保证 Wiki 作为持久产物的质量。

### 检查项

| 检查 | 说明 | 方法 |
|------|------|------|
| **Index 同步性** | `index.md` 中列出的所有路径必须实际存在；所有 wiki 重要文件必须出现在 index | 两侧遍历：① 解析 index.md 取所有路径，验证文件存在；② Glob 全部 .md/.png，验证都在 index 中 |
| **Manifest 完整性** | 每个 `04_剧本/02_创作剧本/第N集_*/` 必须有 manifest.md，且与 scenes/ 中的实际文件对应 | 遍历集目录，对比 manifest 列出的 beat × 实际 scenes/ 文件 |
| **资产改动反查** | 资产文件（角色卡、场景卡、参考图）的 mtime 比依赖它的故事板更新 → 提示重新生成 | grep 所有 manifest.md 的 depends_on 字段，对比 mtime |
| **Needs-regen 队列** | 已被 change-session 标 `needs_regen: true` 的故事板，列表 + 估算批量重生成本 | grep manifest.md 中 `needs_regen: true` |
| **草案残留** | `_pending_changes.md` 存在但已超过 24 小时未执行 → 提示用户是否清理 | 检查文件 mtime |
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

按 §一 走：制作范围选择 → API 配置 → 模式选择 → 创建 Wiki 骨架（含 index.md / preferences.md / log.md）

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

用户常用模糊指代："那张图"、"刚才那个"、"这集"。规则：
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

```python
# 伪代码
for each draft in pending_changes:
    affected_files = []
    # 1. Grep 全 wiki 找实体引用
    affected_files += Grep(draft.entity_keywords)
    # 2. 查 manifest 找受影响故事板
    affected_files += GrepManifests(draft.target_asset)
    # 3. 查 log.md 找已生成视频
    affected_files += GrepLog(draft.target_asset, type="video_generated")

# 合并去重，分类
risks = classify_risks(affected_files)  # 🔴🟡🟢
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
