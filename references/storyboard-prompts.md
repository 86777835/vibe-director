# 故事板提示词模板

## 核心原则

故事板使用**专业电影预生产设计板**（Production Design Board）格式，包含 10 个板块。风格为**写实电影摄影**（realistic cinematic photography），真人质感渲染。Seedance 真人审核通过遮眼方案绕过。

## 完整提示词模板

以下模板直接用于图生图 API 的 `prompt` 参数。将 `{{变量}}` 替换为具体内容。

```
Create a professional film pre-production design board, NOT a comic page. This is a director / cinematographer / art director / lighting team production document, not a manga storyboard.

Canvas:
- 16:9 horizontal production board, cream paper film pre-production sheet aesthetic
- clean technical layout with thin section dividers and clear section headers (white labels on dark, or black labels on cream)
- high-end film / MV / short-drama pre-production document, like the kind hung on a director's wall
- readable section headers in capital letters, small technical notes underneath
- NO large speech bubbles. NO manga comic page composition. NO empty black areas.

Title bar (top of board):
PROJECT: {{剧名}} — EP{{集数}} CLIP {{场景号}}
SETUP / Production Board

Story context (small text):
{{剧名}} / {{时间段}} / {{时间}} / short drama
Logline: {{一句话概括本场景冲突}}
Emotional arc: {{情绪走向}}
Dramatic question: {{戏剧性问题}}
Beat type: {{节拍类型}}

DIRECTOR'S INTENT (top-left section):
Theme: {{节拍类型}} — {{主题描述}}
Performance: {{每个镜头的表演指导}}
Rhythm: {{节奏}}
Camera emotion: {{摄影情绪}}
Audience feeling: {{观众感受}}

CHARACTER REFERENCE PLATE (top-center section — CRITICAL: reproduce EXACTLY from provided reference images):
DO NOT redesign or re-imagine any character. Copy the exact appearance from the reference images provided in this request — same face, same hair, same skin tone, same build, same clothing. Display as a character reference sheet with multi-view layout (front + 3/4 + closeup + hands). Each character shown exactly as they appear in their reference image. Only add emotion/expression appropriate to this beat.

{{角色1名}} / EXACT COPY from reference image
Source: provided reference image for {{角色1名}} — reproduce identically
Current emotion: {{当前情绪}}
Notes: {{仅限当前beat的情绪/动作变化，不描述外貌}}

{{角色2名}} / EXACT COPY from reference image (if applicable)
Source: provided reference image for {{角色2名}} — reproduce identically
Current emotion: {{当前情绪}}
Notes: {{仅限当前beat的情绪/动作变化}}

ART & SET DESIGN (top-right section):
Set: {{场景名称}}
Environment: {{室内/室外描述}}
Production design keywords: short drama, {{关键词1}}, {{关键词2}}
Required visuals: main_set_render, floor_plan, prop_table, set_detail
Key props:
- {{道具1}}: {{道具用途}}

CAMERA BLOCKING PLAN (middle-left section, top-down room plan diagram):
Render a clean top-down floor plan of the room with subject positions labeled and numbered camera icons plus camera movement arrows.
Subjects:
- {{角色位置描述}}
Cameras:
Cam 1: {{景别}} · {{镜头描述}}; {{运镜方式}}; {{起始角度}} to {{结束角度}}
Cam 2: ...
Cam 3: ...

CINEMATOGRAPHY PLAN (middle-center section):
Camera format: large format cinematic digital
Lens package: 35mm / 50mm / 85mm prime lenses
Aspect look: 2.39:1 cinematic crop inside 16:9 board
Visual style: realistic cinematic photography, professional film production quality
Depth of field: shallow for close-ups, deep for environment establish
Camera language: {{摄影语言}}
Shot rules:
- Closeup: reserve close-ups for confession / climax / paywall reaction
- Wide shot: wide shot opens with environment pressure
- Motion: slow push-in only when emotional pressure escalates; static otherwise
Lens notes:
{{景别1}} | {{焦段1}} | {{光圈1}} | {{运镜1}} | {{镜头描述1}}
{{景别2}} | {{焦段2}} | {{光圈2}} | {{运镜2}} | {{镜头描述2}}

LIGHTING REFERENCES (middle-right section):
Mood: {{灯光氛围}}
Key light: {{主光描述}}
Fill: {{辅光描述}}
Back: {{背光描述}}
Practical: {{实景光源}}
Contrast: {{对比度}}
Render a 2x2 strip of small lighting reference thumbnails showing: lamp / window / candle / screen_light

COLOR SCRIPT (bottom-left section):
Palette: {{色彩主题}}
- {{主色}}: main palette
- {{辅色}}: shadow areas
- {{点缀色}}: character anchors
Color script: {{色彩叙事}}
Avoid: {{避免色}}
Render this section as a horizontal swatch strip with hex blocks, palette names underneath.

STORYBOARD PANELS (full bottom strip, 3 cuts — CRITICAL: all human characters MUST look EXACTLY like their reference images):
Render exactly 3 storyboard panels as a horizontal strip. Each panel is a realistic cinematic photography frame. IMPORTANT: Every character shown in these panels MUST be an exact visual copy of their provided reference image — same face, same hair, same skin, same build, same clothing. Do NOT redesign or reinterpret any character. Below each panel, place tiny technical notes (cut number, shot type, lens, camera movement, duration). DIALOG: render dialog as TINY italic script-note line under each panel, prefixed with speaker name in caps. Use Simplified Chinese for dialog. Do NOT use comic speech bubbles.

CUT 1: {{镜头描述}}
Shot: {{景别}} | Lens: {{焦段}} | Move: {{运镜}} | Duration: {{时长}}
Description: {{详细镜头描述}}
Character focus: {{角色}} | Emotion: {{情绪}}

CUT 2: {{镜头描述}}
Shot: {{景别}} | Lens: {{焦段}} | Move: {{运镜}} | Duration: {{时长}}
Description: {{详细镜头描述}}
Character focus: {{角色}} | Emotion: {{情绪}}
Dialog note: {{对白内容（简体中文）}}

CUT 3: {{镜头描述}}
Shot: {{景别}} | Lens: {{焦段}} | Move: {{运镜}} | Duration: {{时长}}
Description: {{详细镜头描述}}
Character focus: {{角色}} | Emotion: {{情绪}}
Dialog note: {{对白内容（简体中文）}}

SEEDANCE2 ADAPTATION NOTES (bottom-right small section):
Use original fictional characters. For close-ups, prepare safe alternatives: partial face, back view, over-the-shoulder, hands-only.
{{角色名}}: character → fictionalized_character

LANGUAGE LOCK (CRITICAL):
ALL on-image text MUST be in Simplified Chinese (简体中文) ONLY. Do NOT render Japanese, Korean, Arabic, or English text.

OVERALL STYLE — REALISTIC CINEMATIC PHOTOGRAPHY:
Entire board rendered as realistic cinematic photography for character and scene panels, with professional technical layout for diagrams and plans. Clean editorial layout with thin section dividers. Technical typography (capital-letter section headers, small body text). Color palette cinematic and muted. Every section labeled with its name at the top.

AVOID:
Japanese kana, Korean hangul, English text mixed with Chinese, comic page layout, manga-style faces, large speech bubbles, big dialogue balloons, panels-only layout, empty black areas, messy layout, unreadable labels, missing sections, brand logos, distorted faces, warped text, jpeg artifacts, oversaturated colors, modern neon UI.
```

---

## 变量填入指南

### 从剧本 beat 提取变量

| 变量 | 来源 | 示例 |
|------|------|------|
| `{{剧名}}` | 项目名 | 银月审判 |
| `{{集数}}` | 当前集 | 01 |
| `{{场景号}}` | beat 编号 | P02 |
| `{{时间段}}` | 剧本场景标签 | 内景/夜 |
| `{{时间}}` | 剧本时间 | 暴风雪夜 |
| `{{一句话概括}}` | beat 核心冲突 | 艾拉拉在暴风雪中独自驾车驶向黑木瀑布镇 |
| `{{情绪走向}}` | 从台词和动作推断 | 紧张→决心→不安 |
| `{{戏剧性问题}}` | 观众想知道的 | 丹尼尔在这个小镇上遇到了什么？ |
| `{{节拍类型}}` | narrative beat type | setup / discovery / tension / climax / revelation |

### 角色描述

从角色档案 `01_资产/01_角色/{角色名}.md` 提取外貌、服装、妆发信息，用英文描述：

```
Visual: {{角色英文名}} (fictional), [age]-year-old [gender], [hair], [eyes], [skin], [build]
Costume: [从上到下完整描述服装]
Hair & makeup: [发型+妆面]
Emotion: [当前 beat 的情绪]
```

---

## 镜头角度词汇

| 中文 | 英文 | 典型用途 |
|------|------|---------|
| 全景 | `wide shot` | 场景全貌 |
| 中景 | `medium shot` | 对话 |
| 近景 | `medium close-up` | 情感 |
| 特写 | `close-up` | 表情/物品 |
| 大特写 | `extreme close-up` | 细节 |
| 过肩 | `over-the-shoulder` | 对话正反打 |
| 俯拍 | `high angle` | 渺小感 |
| 仰拍 | `low angle` | 力量感 |
| 航拍 | `aerial shot` | 环境概览 |

## 光影氛围词汇

| 类型 | 英文关键词 |
|------|-----------|
| 暴风雪 | `blizzard whiteout, harsh cold light` |
| 月夜 | `moonlit night, blue tint` |
| 强对比 | `dramatic chiaroscuro` |
| 烛光 | `candlelight, flickering warm` |
| 仪表盘光 | `dashboard instrument glow, warm amber` |
| 教堂光线 | `stained glass light beams, dust particles` |

## 色板组合

**冰蓝调**：`ice blue, frost white, steel gray, pale lavender, deep navy, silver`
**暗红调**：`crimson red, blood orange, dark burgundy, ash gray, midnight black`
**温暖调**：`warm amber, honey gold, soft cream, terracotta, candlelight yellow`
**神秘调**：`deep violet, ethereal silver, midnight blue, forest green, antique gold`
