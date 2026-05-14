# 故事板规范

## 概述

**一个剧情点（beat）= 一张故事板 = 一条Seedance提示词 = 一个视频片段**

**核心流程**：剧本 → 故事板（Production Design Board）→ Seedance提示词 → 视频片段

故事板是一张**专业电影预生产设计板**（Production Design Board），包含导演意图、角色设计、场景设计、机位调度、摄影规格、灯光参考、色彩脚本和 3 帧分镜面板。整板采用**写实电影摄影风格**（realistic cinematic photography），角色面板和分镜面板使用真人质感渲染。Seedance 真人审核通过**遮眼方案**解决——生成故事板后用图片 API 给人物眼睛加白色条带，用遮眼版提交视频生成，提示词中写明正确瞳色即可恢复。

---

## 画面规格

- **比例**：16:9 横版 Production Board
- **底色**：cream paper film pre-production sheet aesthetic
- **布局**：clean technical layout with thin section dividers and clear section headers
- **风格**：realistic cinematic photography for character and environment panels, monochrome concept sketches for technical diagrams (camera blocking, floor plans). 整体质感：professional Hollywood pre-vis production design board
- **文字**：所有板面内文字必须为**简体中文**，严禁日语假名、韩文、阿拉伯文、英文混入

---

## 板块结构（从上到下、从左到右）

每张故事板必须包含以下板块，按固定布局排列：

### 1. Title Bar（顶部标题栏）

```
PROJECT: {{剧名}} — EP{{集数}} CLIP {{场景号}}
SETUP / Production Board
```

故事背景小字：
```
{{剧名}} / {{时间段}} / {{时间}} / short drama
Logline: {{一句话概括本场景冲突}}
Emotional arc: {{情绪走向}}
Dramatic question: {{戏剧性问题}}
Beat type: {{节拍类型}}
```

### 2. DIRECTOR'S INTENT（左上）

```
Theme: {{节拍类型}} — {{主题描述}}
Performance: Shot 1: {{镜头1描述}}; Shot 2: {{镜头2描述}}; ...
Rhythm: {{节奏：slow_burn / building / climax}}
Camera emotion: {{摄影情绪}}
Audience feeling: {{观众感受}}
```

### 3. CHARACTER REFERENCE PLATE（中上，原资产精确复制）

**原资产复制原则**——角色板块必须从资产库参考图原封不动复制，不得重新设计或重新想象角色外貌。只标注当前 beat 的情绪和动作变化。

每个角色：
```
{{角色名}} / EXACT COPY from reference image
Source: provided reference image for {{角色名}} — reproduce identically
Current emotion: {{当前情绪}}
Notes: {{仅限当前beat的情绪/动作变化，不描述外貌}}
```

### 4. ART & SET DESIGN（右上）

```
Set: {{场景名称}}
Environment: {{室内/室外描述}}
Production design keywords: short drama, {{关键词1}}, {{关键词2}}
Required visuals: main_set_render, floor_plan, prop_table, set_detail
Key props:
- {{道具1}}: {{道具用途}}
```

包含：主场景概念渲染（上）、俯视平面图（下）、道具缩略图行（底部）

### 5. CAMERA BLOCKING PLAN（中左，俯视机位图）

黑白/白底俯视平面图，标注角色位置和编号相机图标（三角形+视场角弧线）+运镜箭头。

```
Subjects:
- {{角色位置描述}}
Cameras:
Cam 1: {{景别}} · {{镜头描述}}; {{运镜方式}}; {{起始角度}} to {{结束角度}}
Cam 2: ...
```

### 6. CINEMATOGRAPHY PLAN（中间）

```
Camera format: large format cinematic digital
Lens package: 35mm / 50mm / 85mm prime lenses
Aspect look: 2.39:1 cinematic crop inside 16:9 board
Visual style: realistic cinematic photography for character and scene panels
Depth of field: shallow for close-ups, deep for environment establish
Camera language: {{摄影语言}}
```

镜头规格表（等宽字体）：
```
{{景别1}}   | {{焦段1}}     | {{光圈1}}  | {{运镜1}}                   | {{镜头描述1}}
{{景别2}}   | {{焦段2}}     | {{光圈2}}  | {{运镜2}}                   | {{镜头描述2}}
...
```

### 7. LIGHTING REFERENCES（中右）

```
Mood: {{灯光氛围}}
Key light: {{主光描述}}
Fill: {{辅光描述}}
Back: {{背光描述}}
Practical: {{实景光源}}
Contrast: {{对比度}}
```

包含 2x2 小灯光参考缩略图（lamp / window / candle / screen_light）

### 8. COLOR SCRIPT（左下）

水平色块条 + 色名标注 + 色彩叙事。

```
Palette: {{色彩主题}}
- {{主色}}: main palette
- {{辅色}}: shadow areas
- {{点缀色}}: character anchors
Color script: {{色彩叙事}}
Avoid: {{避免色}}
```

### 9. STORYBOARD PANELS（底部全宽，3 帧分镜）

**写实电影摄影风格**，真人质感渲染。每帧下方有技术注释和**微小斜体台词标注**（4-12pt，如剧本注释），禁止漫画气泡。

```
CUT 1: {{镜头描述}}
Shot: {{景别}} | Lens: {{焦段}} | Move: {{运镜}} | Duration: {{时长}}
Description: {{详细镜头描述}}
Character focus: {{角色}} | Emotion: {{情绪}}
Dialog note: {{对白内容（中文）}}

CUT 2: ...（同上格式）
CUT 3: ...（同上格式）
```

### 10. SEEDANCE2 ADAPTATION NOTES（右下小区域）

```
Use original fictional characters, realistic cinematic photography style.
真人审核绕过：生成故事板后，用图片 API 给所有人物眼睛加白色条带，遮眼版提交 Seedance 视频生成，提示词中写明正确瞳色即可恢复。
For close-ups, prepare safe alternatives: partial face, back view, over-the-shoulder, hands-only, costume-only, or prop-only compositions.
Variants required:
{{角色名}}: character → fictionalized_character
```

---

## 核心风格约束

### 必须遵守
- **写实电影摄影风格**：角色和场景使用真人质感渲染，与角色参考图保持一致
- **所有板面文字为简体中文**
- **3 帧分镜**（不是 5 帧）
- **台词用微小斜体文字标注**（不用漫画气泡）
- **专业制作文档质感**（导演墙上挂的那种）

### 绝对禁止
- 日本假名（平假名/片假名）
- 韩文
- 英文文字标签混入中文
- 漫画/分镜页面布局（缺少其他板块）
- 大型对话框/气泡
- 空白黑色区域

---

## 质量检查清单

- [ ] Title Bar：剧名、集数、场景号、logline、情绪弧线
- [ ] Director's Intent：主题、表演指导、节奏、摄影情绪
- [ ] Character Reference Plate：原资产精确复制，不重新设计角色外貌，只标注情绪变化
- [ ] Art & Set Design：场景渲染 + 平面图 + 道具
- [ ] Camera Blocking：俯视机位图（相机图标 + 运镜箭头）
- [ ] Cinematography Plan：镜头规格表
- [ ] Lighting References：灯光描述 + 2x2 缩略图
- [ ] Color Script：色块条 + 色彩叙事
- [ ] Storyboard Panels：3 帧分镜，写实电影摄影风格，台词标注
- [ ] Seedance2 Notes：遮眼绕过方案说明
- [ ] 全板文字为简体中文
- [ ] 无漫画气泡
- [ ] 整体质感：专业制作设计板

---

## 目录结构

```
04_剧本/02_创作剧本/第N集_标题/
├── 第N集_标题.md              ← 创作版剧本（含 beat 标记）
├── scenes/                    ← 故事板图片
│   ├── S01E01_SB01_P01_航拍暴风雪.png
│   └── ...
├── videos/                    ← 原始 beat 视频（裁剪前）
└── seedance-prompts.md        ← Seedance 提示词
```

## 命名规范

- 故事板：`S{季}E{集}_SB{编号}_P{beat编号}_{中文描述}.png`
- 视频：`S{季}E{集}_P{beat编号}_{中文描述}.mp4`
