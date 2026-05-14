# 影视制作技巧百科

> 用于 mantur-dramawiki 技能。AI 撰写分镜剧本和 Seedance 提示词时自动参考。
> 当分析剧本中每个 beat 的声画关系时，读取本文件选择最适配的影视技巧。

## 使用方法

1. **分镜剧本阶段**：分析每个 beat 的叙事需求（VO内容、情绪、场景转换），从本文件匹配技巧，在 `[技术]` 标签中标注
2. **Seedance 提示词阶段**：根据已标注的技巧，按对应的"Seedance 写法"描述画面
3. **声画一致性检查**：当 VO 提到某角色/事件/回忆时，画面必须配合展示（不是留空让AI脑补）

## AI 视频适配等级说明

| 等级 | 含义 | 说明 |
|------|------|------|
| ⭐⭐⭐ | 高适配 | Seedance 单条提示词可实现，直接描述 |
| ⭐⭐ | 中适配 | 需要特殊处理（如过曝标记、特定关键词），但单条可完成 |
| ⭐ | 低适配 | 单条 Seedance 难实现，需多条视频后期拼接 |

---

## 一、叙事技巧 Narrative Techniques

### 1.1 闪回 Flashback | ⭐⭐

**定义**：当下叙事暂停，插入过去的场景片段。通常用于揭示角色背景、解释动机、建立情感连接。

**视觉标记**：
- 过曝暖黄色调（温暖回忆）：`overexposed warm yellow, memory fragment`
- 冰蓝色调（痛苦回忆）：`ice blue tint, cold memory`
- 画面微微失焦、胶片颗粒感：`slightly out of focus, film grain`
- 手机视频质感（现代回忆）：`phone video quality, slight camera shake`

**声画规则**（核心！）：
- 当 VO 提到过去的人/事/物时，画面**必须**闪回展示，不能只停留在当下场景
- 闪回通常持续 1-2 秒（短闪回）或 3-5 秒（长闪回）
- 闪回前后用视觉标记与当下场景区分

**适用场景**：
- VO 提到已故/失踪的角色 → 闪回该角色的画面
- 角色回忆过去的事件 → 闪回事件画面
- 角色看到某物触发回忆 → 先拍物品特写，再闪回

**Seedance 写法**：
```
3-5s: FLASHBACK — overexposed warm yellow, [描述回忆画面内容], one second.
```
或中文：
```
4-5秒：过曝暖黄闪回——[描述回忆内容]，只有一秒。
```

**本项目已用示例**：
- 第1集 P02：VO提到Daniel，闪回他在记者办公室举杯、停车场两人并肩
- 第1集 P05：VO提到"那个R"，闪回Daniel的手写字食指伤疤
- 第2集 P01：VO提到Daniel也有烙印吗，闪回Daniel躺在床上烙印发光
- 第2集 P07：VO提到Daniel听过同样的话吗，闪回Daniel坐在教堂长椅
- 第2集 P08：VO提到Daniel来过这里吗，闪回Daniel站在彩色玻璃窗前

**文学剧本标记**：`△ **[FLASH]** 过曝暖黄闪回。`
**分镜剧本标记**：`[技术] 闪回 FLASH`

---

### 1.2 闪前 Flashforward | ⭐⭐

**定义**：提前展示未来将发生的事件，制造悬念和期待。

**视觉标记**：
- 冷色调 + 微微失焦
- 比闪回更短暂（0.5-1秒）
- 常配以低频预兆音

**适用场景**：
- 角色做出决定时，闪前展示决定的后果
- 悬疑片中闪前展示将要发生的危险
- 开场闪前（倒叙结构）——先展示高潮，再从头讲

**Seedance 写法**：
```
FLASHFORWARD — cold blue tint, slightly out of focus, [未来画面], brief flash, 0.5 seconds.
```

---

### 1.3 交叉剪辑 Cross-cutting | ⭐

**定义**：在两个同时发生的场景之间来回切换，建立紧张感和关联性。

**AI 适配性低**：需要生成两条独立视频后剪辑拼接。Seedance 单条提示词无法实现真正的交叉剪辑。

**替代方案**：
- 在一条视频中用分屏（split screen）暗示同时性
- 用声音桥连接两个场景（A场景的VO延续到B场景画面）
- 放弃交叉剪辑，改为线性叙事

**适用场景**：
- 两拨人同时行动（如救援vs被困）
- 角色A在做某事时，角色B同时在做出反应

---

### 1.4 平行蒙太奇 Parallel Montage | ⭐

**定义**：将多个相关场景的片段快速交替展示，强调主题联系或对比。

**AI 适配性低**：同交叉剪辑，需后期拼接。

**替代方案**：
- 时间压缩蒙太奇（单条视频内快速切换不同时段）——Seedance 可以尝试
- 用 VO 串联多个场景，画面只选一个主要场景

**适用场景**：
- 多人同时经历不同事件（如风暴夜各角色的反应）
- 角色训练/成长过程的快速展示

---

### 1.5 时间压缩蒙太奇 Time Compression Montage | ⭐⭐

**定义**：用一系列短片段压缩展示长时间的过程。

**Seedance 写法**：
```
0-8s: Time compression montage — rapid scene changes: [场景1描述], cut to [场景2描述], cut to [场景3描述], each 2 seconds. Lighting shifts from [起始光] to [结束光] showing time passage.
```

**适用场景**：
- 角色等待一夜（窗外光影变化：深夜→黎明）
- 角色翻阅大量资料
- 季节/时间流逝

---

### 1.6 倒叙开场 In medias res | ⭐⭐⭐

**定义**：故事从中间或高潮开始，再回到起点。在短剧中极为常见。

**Seedance 写法**：直接从高潮场景开始描述，无需特殊标记。

**适用场景**：
- 短剧第一集开场（先展示悬念/冲突，再回到"6小时前"）
- 每集 cold open

---

### 1.7 画外音/独白 Voiceover/Narration | ⭐⭐⭐

**定义**：角色的内心声音以画外音形式呈现，观众听到但其他角色听不到。

**声画规则**：
- VO 提到具体事物时，画面必须展示该事物
- VO 回忆时，画面配合闪回
- VO 分析/观察时，画面展示角色扫视的环境

**适用场景**：
- 第一人称视角剧（如本项目的 Elara 视角）
- 角色内心独白
- 开场/结尾旁白

---

### 1.8 画中画 Frame within Frame | ⭐⭐⭐

**定义**：角色被门框、窗户、镜子等自然框架包围，暗示被观察、被困、或与外界隔离。

**Seedance 写法**：
```
Medium shot through doorway frame — [角色描述] seen through the rectangular frame of an open door, [环境描述] in background.
```

**适用场景**：
- 角色被囚禁/困住
- 角色被监视/跟踪
- 隔离感和孤独感

---

### 1.9 非线性叙事 Non-linear Narrative | ⭐⭐

**定义**：打乱时间顺序讲述故事，通过闪回和闪前碎片化呈现。

**在短剧中的应用**：通常每集内部是线性的，但整部剧可以非线性（如第1集从中间开始，第2集回到起点）。

---

### 1.10 冷开场 Cold Open | ⭐⭐⭐

**定义**：在标题卡/片头之前先展示一段完整场景，通常是悬念或高潮片段，直接抓住观众注意力。

**Seedance 写法**：直接从高紧张度场景开始描述，无需铺垫。最后加 `Title card appears.` 切入正片。

**适用场景**：
- 短剧第一集开场（先展示悬念，再回到"6小时前"）
- 每集开场（先展示本集最紧张的一刻，再从头讲）
- 预告/悬念片段

**短剧中的关键地位**：短剧前3秒决定观众是否继续看。冷开场是最有效的留存技巧。

---

### 1.11 定格画面 Freeze Frame | ⭐⭐

**定义**：画面突然静止，时间冻结。用于强调关键时刻、制造戏剧效果、或配合旁白解说。

**Seedance 写法**：
```
[时间点]: Frame freezes — [角色] frozen mid-[动作], time stopped, only camera slowly pushes in slightly on the frozen image.
```

**适用场景**：
- 角色做出重大决定的瞬间
- 关键信息的揭示（配合旁白"这就是我犯的第一个错误"）
- 喜剧中的"你应该知道一件事"叙事

---

### 1.12 慢动作 Slow Motion | ⭐⭐⭐

**定义**：画面以低于正常速度播放，拉伸时间感，赋予瞬间以仪式感和重量。

**Seedance 写法**：
```
[时间点]: Slow motion — [角色]'s [动作] in dramatic slow motion, every detail visible, [环境元素] floating in air.
```

**适用场景**：
- 角色觉醒/变身的瞬间
- 暴力/冲击画面（泼水、碎玻璃、血溅）
- 情感高潮（眼泪滑落、手松开）
- 超自然现象（烙印发光、眼睛变色）

---

### 1.13 快进/延时 Fast Motion / Time-lapse | ⭐⭐⭐

**定义**：画面以加速播放，压缩时间，展示过程或变化。

**Seedance 写法**：
```
Time-lapse — [场景] over [时间段], [光影变化], clouds racing, shadows shifting, [角色/物体] moving rapidly.
```

**适用场景**：
- 等待一夜（窗外暴风雪持续→黎明）
- 角色多次尝试某事（翻遍所有资料）
- 城市/环境的时间流逝
- 角色改变/成长（如头发变长）

---

### 1.14 插入镜头 Insert Shot / Cutaway | ⭐⭐⭐

**定义**：在主镜头中短暂插入某个细节的特写——角色手部动作、物品、环境细节、他人反应。

**Seedance 写法**：
```
Cut to insert: ECU of [细节描述], then back to main scene.
```

**适用场景**：
- 强调关键道具（烙印、登记簿、手机录音键）
- 角色的微表情/手部动作
- 环境中的线索（门缝的光、地板的缝隙）
- 反应镜头（其他角色对事件的反应）

**分镜剧本中的标记**：`[插入] ECU [描述]`

---

### 1.15 视觉母题 Visual Motif | ⭐⭐⭐

**定义**：反复出现的视觉元素，每次出现都强化主题。与声音动机（Sound Motif）配对使用。

**本项目视觉母题**：

| 母题 | 视觉 | 关联 |
|------|------|------|
| 烙印发光 | 腹部淡红光芒脉动 | 超自然身份激活 |
| 门缝光 | 红/白/金/绿光从门缝渗入 | 其他身份者的力量 |
| 彩色玻璃窗 | "群狼与月亮"光影投射 | 角色被狼人包围 |
| 爪痕 | 墙上三道深痕 | 狼人存在的物理证据 |

**Seedance 写法**：在对应 beat 中重复出现母题元素，如 `brand on abdomen pulses with faint red glow` 在多个 beat 中反复描述。

---

### 1.16 速度渐变 Speed Ramp | ⭐⭐

**定义**：同一镜头内从正常速度渐变为慢动作（或反之），强调从日常到关键瞬间的转变。

**Seedance 写法**：
```
[时间点]: Speed ramps — normal pace slows to dramatic slow motion as [关键事件发生], then gradually returns to normal speed.
```

**适用场景**：
- 角色突然注意到重要信息（世界减速）
- 暴力/冲击的瞬间（突然慢放，再恢复）
- 角色的"子弹时间"感知（超自然反应）

---

## 二、剪辑与转场 Editing & Transitions

### 2.1 硬切 Hard Cut | ⭐⭐⭐

**定义**：最基础的转场——一个画面直接切换到下一个画面。

**Seedance 写法**：在提示词中用 `cut to` 或 `suddenly` 标记切换点。

**适用场景**：几乎所有场景切换。

---

### 2.2 叠化 Dissolve | ⭐⭐

**定义**：前一个画面逐渐淡出的同时后一个画面逐渐淡入，两个画面短暂重叠。

**视觉暗示**：时间流逝、场景转换、梦境与现实的交融。

**Seedance 写法**：
```
6-8s: Image slowly dissolves — current scene fades out while [新场景] fades in, dreamlike transition, 2 seconds dissolve.
```

**适用场景**：
- 梦境与现实的转换
- 回忆结束回到当下
- 时间跳跃

---

### 2.3 跳切 Jump Cut | ⭐

**定义**：同一场景内，角色位置/状态突然跳跃，制造不安或时间压缩感。

**AI 适配性低**：需要后期剪辑。

**替代方案**：用"快进"或"闪烁"效果在提示词中描述。

---

### 2.4 匹配剪辑 Match Cut | ⭐⭐

**定义**：两个画面在形态、动作或构图上相似，通过这种相似性实现自然过渡。

**经典案例**：《2001太空漫游》骨头→飞船。

**Seedance 写法**：
```
7-8s: Match cut — [当前画面中的形状/动作] matches to [下一个场景中的相似形状/动作], seamless transition.
```

**适用场景**：
- 两个不同时空的连接（如丹尼尔的烙印→艾拉拉的烙印）
- 场景之间的主题连接

---

### 2.5 J-cut / L-cut | ⭐

**定义**：
- J-cut：声音先于画面出现（先听到下一个场景的声音，再看到画面）
- L-cut：画面先切走，但声音延续

**AI 适配性低**：需要后期音画对齐。

**替代方案**：在 Seedance 提示词中描述"声音先于画面"的效果，但不保证实现。

---

### 2.6 Smash Cut | ⭐⭐

**定义**：从极端安静突然切到极端喧嚣（或反之），制造强烈冲击。

**Seedance 写法**：
```
3-4s: SMASH CUT from dead silence to [嘈杂场景], jarring transition, sound explosion.
```

**适用场景**：
- 噩梦惊醒（梦境安静→现实嘈杂）
- 突发事件（平静→爆炸/尖叫）

---

### 2.7 淡入淡出 Fade In/Out | ⭐⭐⭐

**定义**：画面从黑屏逐渐出现（淡入）或逐渐消失到黑屏（淡出）。

**Seedance 写法**：
```
0-2s: Fade in from black — [场景] gradually appears from darkness.
8-10s: Scene slowly fades to black, final image lingers.
```

**适用场景**：
- 开场和结尾
- 重要段落的起止
- 暗示"新篇章"

---

### 2.8 隐形剪辑 Invisible Cut | ⭐⭐

**定义**：用物体经过镜头、快速摇过等运动隐藏剪辑点，让两个镜头看起来是一个连续镜头。

**Seedance 写法**：
```
3-4s: Camera whips past a dark object (passing car/pillar), when it emerges on the other side the scene has changed to [新场景], seamless hidden cut.
```

**适用场景**：
- 时空转换但保持流畅感
- 长镜头风格

---

### 2.9 光圈收缩/展开 Iris In/Out | ⭐⭐

**定义**：画面从四周边缘向中心收缩成圆形黑圈（Iris Out），或从圆形黑圈展开到全画面（Iris In）。经典无声电影转场。

**Seedance 写法**：
```
7-8s: Iris out — black circular mask closes from edges toward center, focusing on [角色/细节], then black.
```

**适用场景**：
- 经典/复古风格的强调
- 聚焦最后的关键细节
- 复古短剧的特殊调性

---

### 2.10 蒙太奇段落 Montage Sequence | ⭐⭐

**定义**：一系列短镜头快速剪辑组合，展示过程、对比、或主题联系。与交叉剪辑不同，蒙太奇不要求同时性。

**蒙太奇类型**：

| 类型 | 说明 | 示例 |
|------|------|------|
| 叙事蒙太奇 | 压缩时间展示过程 | 角色翻阅资料、一夜等待 |
| 对比蒙太奇 | 对比两个概念 | 富人的晚宴 vs 穷人的挣扎 |
| 主题蒙太奇 | 通过意象传达主题 | 各种"门"的镜头=选择 |
| 理性蒙太奇 | 两个无关镜头产生新含义 | 狼的镜头+角色的镜头=狼人 |

**Seedance 写法**（单条内的简化蒙太奇）：
```
0-8s: Montage sequence — rapid cuts: [画面1] 2s, [画面2] 2s, [画面3] 2s, [画面4] 2s, unified by [主题/色彩/音乐].
```

**AI 适配性**：单条内可实现简单的蒙太奇（快速切换不同画面），复杂蒙太奇需后期。

---

### 2.11 速度渐变转场 Speed Ramp Transition | ⭐⭐

**定义**：通过速度变化实现转场——画面加速到模糊，然后在另一个场景减速到正常。

**Seedance 写法**：
```
6-8s: Motion blur accelerates — world spins into blur, then decelerates into [新场景], seamless speed ramp transition.
```

**适用场景**：
- 时空跳跃
- 角色从回忆回到现实
- 情绪从平静到激动的转换

---

## 三、镜头与运动 Camera & Movement

### 3.1 推镜头 Zoom In / Push In | ⭐⭐⭐

**定义**：镜头向主体靠近，增加亲密感和聚焦感。

**Seedance 写法**：
```
Camera slowly pushes in toward [角色/物体], from [起始景别] to [结束景别].
```

**适用场景**：
- 角色发现重要信息
- 情绪转变的关键瞬间
- 强调某个道具/细节

---

### 3.2 拉镜头 Zoom Out / Pull Out | ⭐⭐⭐

**定义**：镜头从主体后退，揭示更多环境信息。

**Seedance 写法**：
```
Camera slowly pulls back from [角色] to reveal [周围环境], establishing the full scene.
```

**适用场景**：
- 揭示角色所处环境的全貌
- 角色在广阔空间中的渺小感
- 场景结束时的收束

---

### 3.3 横摇 Pan | ⭐⭐⭐

**定义**：相机水平旋转，左右扫视场景。

**Seedance 写法**：
```
Camera pans [left/right] across [场景], revealing [元素1], [元素2], [元素3].
```

**适用场景**：
- 展示场景全貌
- 角色群像展示
- 跟随角色视线扫描环境

---

### 3.4 跟拍 Tracking Shot | ⭐⭐⭐

**定义**：相机跟随角色移动，保持相对距离不变。

**Seedance 写法**：
```
Tracking shot following [角色] as they [动作], camera moves at the same pace.
```

**适用场景**：
- 角色行走/奔跑
- 揭示新空间
- 保持与角色的亲密感

---

### 3.5 环绕 Orbit Shot | ⭐⭐⭐

**定义**：相机围绕角色旋转，展示角色与环境的全方位关系。

**Seedance 写法**：
```
Camera slowly orbits around [角色], 180 degrees, revealing [环境元素] behind them.
```

**适用场景**：
- 角色的关键时刻（觉醒、决定）
- 展示角色被环境包围
- 强调孤独或力量

---

### 3.6 手持晃动 Handheld | ⭐⭐⭐

**定义**：手持相机的轻微晃动，增加紧张感和纪实感。

**Seedance 写法**：
```
Handheld camera, slight shake, following [角色] through [场景], raw documentary feel.
```

**适用场景**：
- 紧张/危险场景
- 战区/犯罪现场
- 恐怖片（增加代入感）

---

### 3.7 航拍 Aerial / Drone Shot | ⭐⭐⭐

**定义**：从高空俯瞰的移动镜头。

**Seedance 写法**：
```
Cinematic aerial drone shot, [高度] above [场景], slowly [descending/rising/tracking], [天气/光线].
```

**适用场景**：
- 开场建立镜头（展示小镇全貌）
- 角色在广阔空间中的渺小
- 孤立感（暴风雪中的公路）

---

### 3.8 第一人称 POV | ⭐⭐

**定义**：从角色眼睛看到的视角。

**Seedance 写法**：
```
POV shot from [角色]'s perspective — [他们看到的内容], camera moves as their eyes would.
```

**适用场景**：
- 角色发现恐怖事物的瞬间
- 昏迷/醒来时的模糊视角
- 增强观众代入感

---

### 3.9 升降镜头 Crane / Vertigo | ⭐⭐⭐

**定义**：相机垂直上升或下降，改变视角高度。

**Seedance 写法**：
```
Camera rises from [低处/角色视角] up to [高处/鸟瞰视角], dramatic vertical movement.
```

**Vertigo 效果**（滑动变焦 / 希区柯克变焦）：`Dolly zoom / Vertigo effect / Hitchcock zoom — camera pulls back while zooming in, background appears to stretch and distort, disorienting.`
注意：Vertigo 效果在 AI 视频中可能不稳定，但值得一试。

**适用场景**：
- 从角色视角上升到上帝视角（揭示全貌）
- 恐怖场景的压迫感（从高处压迫角色）
- 场景结尾的史诗感
- 角色意识到恐怖真相的瞬间（世界扭曲感）——希区柯克经典用法

---

### 3.10 纵摇 Tilt | ⭐⭐⭐

**定义**：相机垂直旋转，上下扫视。常用于展示建筑高度或角色全貌。

**Seedance 写法**：
```
Camera tilts up from [低处/角色脚部] to [高处/角色面部], revealing [内容] vertically.
```

**适用场景**：
- 展示高大的建筑/教堂
- 角色从脚到头的"亮相"镜头
- 从地面仰视到天空

---

### 3.11 快速摇摄 Whip Pan | ⭐⭐⭐

**定义**：相机极快速水平旋转，画面变成运动模糊。用于场景转换或制造紧迫感。

**Seedance 写法**：
```
Whip pan [left/right] — camera snaps rapidly, motion blur streaks, then settles on [新场景/角色].
```

**适用场景**：
- 快速场景转换（比硬切更有动感）
- 紧急反应（角色快速转头）
- 揭示意外（快速摇到意外出现的角色）
- 隐形剪辑的载体（快速摇摄中切换场景）

---

### 3.12 横移 Dolly / Slider | ⭐⭐⭐

**定义**：相机在轨道上水平滑动，与推拉不同——推拉是前后（z轴），横移是左右（x轴）。

**Seedance 写法**：
```
Camera dollies [left/right] on a smooth track, sliding past [前景] while [角色] remains in frame.
```

**适用场景**：
- 平行于角色行走（边走边拍的侧面视角）
- 展示场景的横向全貌（如一条走廊）
- 前景物体滑过增加层次感

---

### 3.13 拉焦 Rack Focus / Focus Pull | ⭐⭐⭐

**定义**：在同一镜头内改变焦点——前景清晰→背景模糊变为前景模糊→背景清晰。引导观众注意力转移。

**Seedance 写法**：
```
Rack focus — initially focused on [前景物体] with [背景角色] blurred, then focus shifts to [背景角色] while [前景] blurs.
```

**适用场景**：
- 先展示道具（如手机录音界面），再拉焦到角色表情
- 先拍门缝的光，再拉焦到角色惊恐的脸
- 在两个角色间切换焦点（暗示关系变化）
- 发现隐藏信息（先模糊→聚焦→看清真相）

**短剧中的重要性**：拉焦是制造悬念的利器——观众知道画面中有重要信息但看不清，然后聚焦揭示。

---

### 3.14 斯坦尼康 Steadicam | ⭐⭐⭐

**定义**：使用稳定器拍摄的平滑移动镜头。比手持更稳定，比轨道更自由。如电影般流畅地穿越空间。

**Seedance 写法**：
```
Smooth steadicam shot, gliding through [场景], floating past [元素], following [角色] with fluid, weightless movement.
```

**适用场景**：
- 角色穿越复杂空间（如旅馆走廊→大厅→门外）
- 单镜头展示整个场景（如《闪灵》的走廊骑行）
- 梦幻/超现实感的移动

---

### 3.15 弧形运动 Arc Shot | ⭐⭐⭐

**定义**：相机沿弧线运动（半圆或局部弧线），与环绕（Orbit）相似但通常是不完整的弧。展示角色从不同角度。

**Seedance 写法**：
```
Camera arcs from [起始位置] to [结束位置], sweeping around [角色] in a partial semicircle, revealing [新角度信息].
```

**适用场景**：
- 对话中的角度变化（从正面到侧面）
- 角色表情的转变（从冷静到愤怒，相机同步弧形移动）
- 揭示角色背后的信息

---

### 3.16 景深控制 Depth of Field | ⭐⭐⭐

**定义**：控制画面前后清晰范围。浅景深=只有主体清晰，背景模糊；深景深=前后都清晰。

**浅景深（Shallow DOF）**：
```
Shallow depth of field — [角色/物体] in sharp focus, background smoothly blurred (bokeh), isolating the subject.
```

**深景深（Deep DOF）**：
```
Deep focus — everything from foreground to background in sharp focus, [前景元素] and [背景元素] all clearly visible.
```

**适用场景**：
- 浅景深：强调孤独（只有角色清晰，世界模糊）、亲密感、聚焦关键信息
- 深景深：展示空间关系（角色+背景威胁同时清晰）、环境叙事、奥逊·威尔斯风格

---

## 四、构图与景别 Composition & Shot Size

### 4.1 大全景 Extreme Wide Shot (EWS) | ⭐⭐⭐

**定义**：极远距离拍摄，角色在画面中很小甚至看不见，环境占主导。

**Seedance 写法**：`Extreme wide shot` 或 `EWS`

**适用场景**：
- 场景开场建立镜头
- 展示角色在环境中的渺小
- 史诗感/压迫感

---

### 4.2 全景 Full Shot (FS) | ⭐⭐⭐

**定义**：角色全身在画面中，可见部分环境。

**Seedance 写法**：`Full shot` 或 `FS`

**适用场景**：
- 角色进入/离开场景
- 展示角色服装/姿态
- 动作场面

---

### 4.3 中景 Medium Shot (MS) | ⭐⭐⭐

**定义**：从腰部以上拍摄，最常用的对话景别。

**Seedance 写法**：`Medium shot` 或 `MS`

**适用场景**：
- 对话场景
- 角色互动
- 日常场景

---

### 4.4 近景 Medium Close-up (MCU) | ⭐⭐⭐

**定义**：胸部以上，比中景更聚焦面部表情。

**Seedance 写法**：`Medium close-up` 或 `MCU`

**适用场景**：
- 角色表达情绪
- 重要对话
- 角色反应

---

### 4.5 特写 Close-up (CU) | ⭐⭐⭐

**定义**：面部填满画面，突出微表情和情绪细节。

**Seedance 写法**：`Close-up` 或 `CU`

**适用场景**：
- 情绪高潮
- 发现/震惊的瞬间
- 烙印/伤疤/道具的细节展示

---

### 4.6 大特写 Extreme Close-up (ECU) | ⭐⭐⭐

**定义**：极度放大的细节——眼睛、嘴唇、指尖、物品纹路。

**Seedance 写法**：`Extreme close-up` 或 `ECU`

**适用场景**：
- 眼睛中的恐惧/泪水
- 指尖触碰烙印
- 关键道具的纹理/文字
- 身体细节（伤疤、纹身、烙印）

---

### 4.7 过肩镜头 Over-the-shoulder (OTS) | ⭐⭐⭐

**定义**：从角色A的肩膀后方拍摄角色B，建立空间关系和对话感。

**Seedance 写法**：`Over-the-shoulder shot from [角色A]'s shoulder, focused on [角色B]`

**适用场景**：
- 两人对话
- 角色对峙
- 展示角色看到的内容

---

### 4.8 高角度俯拍 High Angle | ⭐⭐⭐

**定义**：从上方拍摄角色，使角色看起来弱小、无助。

**Seedance 写法**：`High angle shot looking down at [角色]`

**适用场景**：
- 角色被压制/被困
- 展示角色的脆弱
- 受害者视角

---

### 4.9 低角度仰拍 Low Angle | ⭐⭐⭐

**定义**：从下方拍摄角色，使角色看起来强大、有威慑力。

**Seedance 写法**：`Low angle shot looking up at [角色], [角色] appears dominant and imposing`

**适用场景**：
- 反派/权力角色的登场
- 角色获得力量的瞬间
- 英雄时刻

---

### 4.10 荷兰角 Dutch Angle | ⭐⭐⭐

**定义**：相机倾斜，地平线不水平，制造不安、失衡、疯狂感。

**Seedance 写法**：`Dutch angle, tilted composition, [场景描述]`

**适用场景**：
- 角色精神崩溃/恐慌
- 超自然现象出现
- 世界失衡/失序

---

### 4.11 对称构图 Symmetry | ⭐⭐⭐

**定义**：画面左右或上下严格对称，制造秩序感、仪式感或压迫感。

**Seedance 写法**：`Perfectly symmetrical composition, [场景描述], centered`

**适用场景**：
- 仪式/宗教场景
- 机构/权力空间
- 强迫症/控制欲角色

---

### 4.12 留白构图 Negative Space | ⭐⭐⭐

**定义**：画面大部分留空，角色只占很小一部分，制造孤独、渺小、被吞没感。

**Seedance 写法**：`Wide shot with vast negative space — [角色] small in [巨大环境], surrounded by emptiness`

**适用场景**：
- 角色的孤独和脆弱
- 自然力量面前的渺小
- 绝望/无助

---

### 4.13 三分法则 Rule of Thirds | ⭐⭐⭐

**定义**：将画面分为九宫格，将主体放在交叉点上（非中心），画面更动态、更有引导性。

**Seedance 写法**：`Rule of thirds composition — [角色/主体] positioned at [左/右] third, [环境/负空间] fills the remaining space`

**适用场景**：
- 大部分镜头的默认构图（比居中更自然）
- 角色看向画面外时，留出"呼吸空间"
- 风景/环境中有明确主体的镜头

---

### 4.14 引导线 Leading Lines | ⭐⭐⭐

**定义**：利用场景中的线条（走廊、道路、栏杆、河流）引导观众视线到画面焦点。

**Seedance 写法**：`Leading lines composition — [线条元素: corridor/road/railings] draw the eye toward [焦点: 角色/物体] in the distance`

**适用场景**：
- 走廊/道路镜头（线条自然引导到远处的角色）
- 透视感强的空间（教堂、隧道、桥梁）
- 强调距离感和方向性

---

### 4.15 前景遮挡 Foreground Framing | ⭐⭐⭐

**定义**：在镜头前景放置物体（柱子、树叶、窗帘、人物肩膀），部分遮挡画面，增加深度和窥视感。

**Seedance 写法**：
```
Shot through foreground [遮挡物: foliage/curtain/pillar] — [角色] visible in the gap between foreground elements, voyeuristic framing.
```

**适用场景**：
- 角色被监视/偷窥的暗示
- 增加画面层次感
- 暗示角色被"框住"或隐藏

---

### 4.16 深度分层 Deep Staging | ⭐⭐⭐

**定义**：在画面前景、中景、背景分别安排不同元素，制造纵深感。每个层次都传达信息。

**Seedance 写法**：
```
Deep staging — foreground: [前景元素], midground: [角色/主要动作], background: [背景信息/威胁/环境], three layers of depth.
```

**适用场景**：
- 角色不知道背景中有危险（前景安全、背景威胁）
- 展示空间关系（前台对话、后台有人窥视）
- 丰富画面信息量

---

## 五、光影 Lighting

### 5.1 高调照明 High-key Lighting | ⭐⭐⭐

**定义**：明亮均匀的照明，阴影很少。用于喜剧、日常、安全场景。

**Seedance 写法**：`High-key lighting, bright and even illumination, minimal shadows`

**适用场景**：喜剧、浪漫、日常、童年回忆。

---

### 5.2 低调照明 Low-key Lighting | ⭐⭐⭐

**定义**：强烈的明暗对比，大面积阴影。用于悬疑、恐怖、戏剧性场景。

**Seedance 写法**：`Low-key lighting, strong contrast between light and shadow, deep dark areas`

**适用场景**：恐怖片、悬疑、超自然、夜晚场景、反派场景。

---

### 5.3 明暗对比 Chiaroscuro | ⭐⭐⭐

**定义**：源自绘画的光影技法，面部一侧被照亮另一侧在阴影中。戏剧性极强。

**Seedance 写法**：`Chiaroscuro lighting, one side of face illuminated, other side in deep shadow, dramatic`

**适用场景**：
- 角色内心冲突的外化
- 暗示角色有两面性
- 关键对话/对峙

---

### 5.4 逆光 Backlight | ⭐⭐⭐

**定义**：光源在角色背后，角色变成剪影，面容模糊。

**Seedance 写法**：`Backlit silhouette — [角色] backlit by [光源], face in shadow, outline glowing`

**适用场景**：
- 神秘角色登场
- 威胁的暗示（看不清面容的人影）
- 美学化的戏剧性画面

---

### 5.5 侧光 Side Light | ⭐⭐⭐

**定义**：光线从一侧打来，面部一半亮一半暗。

**Seedance 写法**：`Side lighting from [方向], half of [角色]'s face illuminated, other half in shadow`

**适用场景**：同明暗对比，但更自然。暗示角色的秘密或两面。

---

### 5.6 底光 Under Lighting | ⭐⭐⭐

**定义**：光线从下方打来，制造不自然的阴影，角色看起来恐怖/鬼魅。

**Seedance 写法**：`Under lighting, light source from below, casting unnatural upward shadows on face, eerie`

**适用场景**：恐怖场景、超自然生物、噩梦。

---

### 5.7 色温叙事 Color Temperature | ⭐⭐⭐

**定义**：用暖色（琥珀/金色）和冷色（蓝/青色）区分不同时空、情绪、现实状态。

**色温编码表**（本项目已用）：

| 色温 | 画面效果 | 叙事含义 |
|------|---------|---------|
| 暖琥珀 amber | 金色暖光 | 当下安全场景、旅馆灯光 |
| 过曝暖黄 overexposed warm yellow | 泛白发光 | 回忆/闪回（温暖记忆） |
| 冰蓝 ice blue | 冷冽蓝色 | 痛苦回忆、超自然冷光、死亡暗示 |
| 深红 crimson | 血红色 | 危险、血月、烙印、狼人力量 |
| 银白 silver-white | 冷冽白光 | 神圣力量、先知 |
| 暗金 dark gold | 温暖金光 | 守卫/保护力量 |
| 翠绿 emerald green | 活力绿光 | 女巫/自然力量 |
| 去饱和 desaturated | 灰蓝色调 | 现实的残酷、绝望 |

**Seedance 写法**：在提示词中直接指定色调，如 `ice blue tint, desaturated` 或 `warm amber lighting`。

---

### 5.8 实用光源 Practical Light | ⭐⭐⭐

**定义**：场景中可见的光源——蜡烛、台灯、壁炉、手机屏幕、汽车灯。光源在画面中可见，照明效果更自然。

**Seedance 写法**：`Practical lighting from [光源: candle/desk lamp/fireplace], warm glow emanating from visible source in frame, natural fall-off`

**适用场景**：
- 旅馆房间的台灯（本项目第1集 P05）
- 教堂的蜡烛光
- 手机屏幕照亮角色的脸
- 汽车仪表盘灯光

**重要性**：在 AI 视频中指定实用光源比抽象的光影术语更有效——模型能理解"烛光照亮脸"比"low-key lighting"更准确。

---

### 5.9 伦勃朗光 Rembrandt Lighting | ⭐⭐⭐

**定义**：面部一侧被照亮，另一侧在阴影中，但在阴影侧的面颊上有一个倒三角光斑（以荷兰画家伦勃朗命名）。最经典的戏剧性人像光。

**Seedance 写法**：`Rembrandt lighting — triangular highlight on [角色]'s shadowed cheek, classic portrait lighting, dramatic`

**适用场景**：
- 角色特写/肖像镜头
- 戏剧性对话
- 角色内心的复杂性

---

### 5.10 边缘光 Rim Light / Kicker | ⭐⭐⭐

**定义**：从角色背后/侧后方打来的光，在角色边缘勾勒出发光轮廓线，将角色从背景中分离。

**Seedance 写法**：`Rim lighting — bright edge light outlining [角色]'s silhouette from behind, separating them from the dark background, hair and shoulders glowing`

**适用场景**：
- 角色在黑暗背景中需要突出
- 神秘/超自然场景（边缘发光=非人感）
- 逆光但保留轮廓信息

---

### 5.11 硬光 vs 软光 Hard Light vs Soft Light | ⭐⭐⭐

**定义**：
- **硬光**：直射、方向性强，产生锐利的阴影边缘。太阳直射、聚光灯。视觉上强硬、攻击性。
- **软光**：散射、方向性弱，阴影边缘模糊。阴天、柔光箱。视觉上柔和、亲密。

**Seedance 写法**：
- 硬光：`Hard direct light, sharp-edged shadows, harsh contrast, uncompromising`
- 软光：`Soft diffused light, gentle shadow transitions, wrapping around [角色], intimate`

**适用场景**：
- 硬光：审讯、对峙、暴露真相
- 软光：亲密对话、浪漫场景、角色脆弱时刻

---

### 5.12 混合光 Mixed Lighting | ⭐⭐

**定义**：场景中同时存在不同色温的光源（如冷色窗外光+暖色室内灯），制造视觉张力和自然感。

**Seedance 写法**：`Mixed lighting — cool blue [来源: window/moonlight] from [方向] contrasting with warm amber [来源: lamp/candle] from [另一方向], two-tone split`

**适用场景**：
- 夜晚室内场景（窗外冷光+室内暖灯）
- 角色在两个世界之间（物理/超自然）
- 写实感强的夜景

---

## 六、声音设计 Sound Design

### 6.1 画内音 Diegetic Sound | ⭐⭐⭐

**定义**：场景中角色也能听到的声音——对话、脚步声、门开关、暴风雪、环境音。

**Seedance 写法**：在音效部分描述，如 `Sound: blizzard howling, wooden floor creaking, distant footsteps`

**适用场景**：所有场景的基础声音层。

---

### 6.2 画外音 Non-diegetic Sound | ⭐⭐⭐

**定义**：只有观众听到的声音——配乐、旁白、内心独白、音效强化。

**Seedance 写法**：在音效部分标注，如 `Non-diegetic: low rumbling drone, heartbeat accelerating`

**适用场景**：
- 配乐/氛围音
- 角色内心独白（VO）
- 超自然力量的声音暗示

---

### 6.3 声音动机 Sound Motif | ⭐⭐⭐

**定义**：与特定角色、概念或力量关联的标志性声音。每次出现都暗示该元素的存在。

**本项目声音动机表**：

| 动机 | 声音 | 关联 |
|------|------|------|
| 烙印脉动 | 低频嗡鸣 + 心跳节奏 | 超自然觉醒、身份激活 |
| 狼人接近 | 骨骼碎裂 + 低吼 | 狼人变形或靠近 |
| 地下室 | 沉闷的轰鸣 + 脉动 | 地下空间、被囚者 |
| 暴风雪 | 呼啸风声 + 击窗声 | 孤立、封锁、外界威胁 |

**Seedance 写法**：`Sound: brand pulsing with low-frequency hum, synchronized heartbeat rhythm`

---

### 6.4 寂静 Silence | ⭐⭐⭐

**定义**：所有声音突然消失。在恐怖/悬疑中，寂静比任何声音都更恐怖。

**Seedance 写法**：
```
[时间点]: All sound suddenly stops. Absolute dead silence. [持续时长] of pure silence.
```

**适用场景**：
- 尖叫后的戛然而止（本项目第2集 P04）
- 威胁消失后确认"真的消失了吗"的不确定
- 角色死亡/失去意识的瞬间
- 超自然力量暂停的诡异瞬间

**关键原则**：声音消失比声音出现更恐怖。观众的大脑会自行填补恐惧。

---

### 6.5 声音桥 Sound Bridge | ⭐⭐

**定义**：下一个场景的声音在当前画面中提前出现（音频 J-cut），或当前场景的声音延续到下一个画面（音频 L-cut）。

**Seedance 写法**：
```
7-8s: Sound bridge — [下一场景的声音] begins playing over current scene, transitioning the viewer to the next location.
```

**适用场景**：
- 场景之间的平滑过渡
- 用声音暗示即将出现的场景
- 保持叙事连贯性

---

### 6.6 低频嗡鸣 Low-frequency Drone | ⭐⭐⭐

**定义**：持续的、不愉快的低频声音，制造不安和恐惧。

**Seedance 写法**：`Sound: persistent low-frequency drone, unsettling, sub-bass vibration`

**适用场景**：
- 超自然存在
- 烙印反应
- 未知威胁的暗示

---

### 6.7 心跳/呼吸 Heartbeat/Breathing | ⭐⭐⭐

**定义**：放大的生理声音，将观众代入角色的紧张/恐惧。

**Seedance 写法**：`Sound: heartbeat accelerating from 60bpm to 120bpm, breathing becomes rapid and shallow`

**适用场景**：
- 角色恐惧/紧张
- 追逐/危险场景
- 觉醒/发现的瞬间

---

### 6.8 混响/回声 Reverb / Echo | ⭐⭐⭐

**定义**：声音的反射效果。大空间（教堂、洞穴）有长混响，小空间（衣柜、车内）几乎没有。混响暗示空间的尺度和材质。

**Seedance 写法**：
```
Sound: voice echoing in [大空间: cathedral hallway], long reverb tail, each word bouncing off stone walls
```
或
```
Sound: muffled, almost no reverb, confined [小空间: closet space], claustrophobic
```

**适用场景**：
- 教堂场景（长回声增加庄严/不安感）
- 洞穴/地下室（回声暗示空旷的地下空间）
- 密闭空间（无回声=幽闭恐惧）

---

### 6.9 声音透视 Sound Perspective | ⭐⭐⭐

**定义**：声音的远近感——远处的声音低沉模糊，近处的声音清晰明亮。声音与画面中声源的距离匹配。

**Seedance 写法**：
```
Sound: distant [声音: footsteps/screaming] from far end of corridor, muffled and echoing, gradually getting louder and clearer as [声源] approaches
```

**适用场景**：
- 脚步声从远处逼近（本项目第2集 P05 军人脚步）
- 远处的尖叫声（第2集 P04）
- 角色通过声音判断威胁距离

---

### 6.10 音乐刺点 Music Stinger / Sting | ⭐⭐⭐

**定义**：突然的、短促的音乐或音效冲击，用于惊吓、揭示或强调关键时刻。通常1-2秒。

**Seedance 写法**：
```
[时间点]: Music stinger — sharp orchestral hit / sudden dissonant chord at the moment of [揭示/惊吓].
```

**适用场景**：
- 恐怖揭示（看到尸体、怪物现身）
- 关键信息的发现
- 情节反转的音效强调

---

### 6.11 环境群声 Walla / Room Tone | ⭐⭐⭐

**定义**：背景中人群的低语、环境的持续低音、空间的"底噪"。不清晰的对话声，只有模糊的人声质感。

**Seedance 写法**：
```
Sound: muffled walla — indistinct crowd murmuring in [空间: church hallway], background chatter, then suddenly falls silent
```

**适用场景**：
- 教堂集会前的低声议论（本项目第2集 P06）
- 酒吧/餐厅的环境音
- 人群突然安静=紧张时刻

---

### 6.12 白噪音/粉噪音 Noise Bed | ⭐⭐⭐

**定义**：持续的环境背景音——雨声、风声、电流嗡鸣、暖气管道声。作为声音的"基底"，让场景更真实。

**Seedance 写法**：
```
Sound bed: persistent [白噪音: rain on windows/wind through cracks/electrical hum], underlying all other sounds, continuous
```

**适用场景**：
- 暴风雪场景的持续风声（本项目贯穿第1-2集）
- 旅馆的暖气管道声
- 雨夜的持续性氛围

---

## 七、场面调度 Mise-en-scène

### 7.1 色彩编码 Color Coding | ⭐⭐⭐

**定义**：用不同颜色代表不同角色身份、力量阵营、或叙事状态。观众通过颜色直觉理解含义。

**本项目色彩编码**：

| 颜色 | 含义 | 首次出现 |
|------|------|---------|
| 暗红 crimson | 狼人/危险/烙印 | 第2集 P03（走廊红光） |
| 银白 silver | 先知/神圣 | 第2集 P03（走廊白光） |
| 暗金 gold | 守卫/保护 | 第2集 P03（走廊金光） |
| 翠绿 green | 女巫/自然 | 第2集 P03（走廊绿光） |
| 暖琥珀 amber | 安全/旅馆/当下 | 第1集 P02（车内灯光） |
| 过曝暖黄 warm yellow | 回忆/丹尼尔 | 第1集 P02（闪回） |

**Seedance 写法**：在描述光/色彩时直接使用编码颜色，如 `dark red glow from beneath the door`。

---

### 7.2 权力站位 Power Positioning | ⭐⭐⭐

**定义**：角色在场景中的位置暗示权力关系——高处=支配，前方=领导，边缘=弱势。

**本项目已用示例**：
- 第2集 P06：马库斯站在教堂前方（支配者），其他人坐在长椅上（被支配者），艾拉拉坐在后方（观察者）

**Seedance 写法**：在场景描述中明确站位，如 `[角色A] standing at the front of the room, dominant position, while [角色B] sits in the back pew, observer position`

---

### 7.3 道具象征 Prop Symbolism | ⭐⭐⭐

**定义**：特定物品承载象征意义，反复出现强化主题。

**本项目道具象征**：
- 登记簿 → 进入游戏/不可逆的签名
- 烙印 → 身份标识/游戏参与者的标记
- 手机录音 → 记者本能/致命弱点
- 彩色玻璃窗"群狼与月亮" → 艾拉拉被狼人包围的视觉隐喻

**Seedance 写法**：在特写镜头中强调道具，如 `Close-up of the phone's recording app — red recording indicator glowing like a warning`

---

### 7.4 镜像/倒影 Mirror/Reflection | ⭐⭐

**定义**：用镜子、水面、玻璃等反射面展示角色的另一面。

**Seedance 写法**：
```
[角色] seen through reflection in [镜面/水面/玻璃], their mirror image showing a different expression than their real face.
```

**适用场景**：
- 角色的双重身份（人/狼）
- 角色看到自己的变化（发现烙印）
- 暗示隐藏的真相

---

### 7.5 门框构图 Doorway/Window Framing | ⭐⭐⭐

**定义**：用门框、窗户、走廊的线条将角色"框住"，暗示禁锢、选择、或阈值。

**Seedance 写法**：
```
[角色] framed by the rectangular doorway, [外部世界] visible beyond, threshold between [两个空间].
```

**适用场景**：
- 角色面临选择（开门或不开）
- 内外世界的分隔（安全vs危险）
- 被困/禁锢（本项目第2集 P03、P04：艾拉拉始终在门后）

---

### 7.6 色彩饱和度转换 Saturation Shift | ⭐⭐

**定义**：回忆场景色彩饱和度高（鲜艳温暖），现实场景色彩去饱和（灰蓝冷调），通过饱和度变化区分时空。

**Seedance 写法**：
```
FLASHBACK — high saturation warm tones, vivid colors of memory. Then cut back to present — desaturated cold reality, muted blues and grays.
```

---

### 7.7 走位设计 Blocking | ⭐⭐⭐

**定义**：角色在场景中的移动路径和位置安排。角色向谁移动、远离谁、站在谁旁边——都传递关系信息。

**走位语言**：

| 走位 | 含义 |
|------|------|
| 角色A向B移动 | A对B有兴趣/威胁/需求 |
| 角色A远离B | A在逃避/排斥/恐惧 |
| 两人在同一轴线上对峙 | 直接对抗 |
| 两人成90度角站立 | 旁观/不参与 |
| 角色绕着对方走 | 试探/评估/威胁 |

**Seedance 写法**：在场景描述中明确走位，如 `[角色A] walks toward [角色B] who steps back, maintaining distance, circling each other`

**适用场景**：
- 对峙场景（谁在进，谁在退）
- 权力关系的动态变化
- 角色关系的视觉化

---

### 7.8 服装叙事 Costuming | ⭐⭐⭐

**定义**：角色的服装变化传递叙事信息——从外在到内心的转变。

**服装叙事手法**：

| 变化 | 含义 |
|------|------|
| 服装颜色变化 | 角色"阵营"或状态改变 |
| 脱掉外层 | 暴露真实自我/脆弱 |
| 穿上制服 | 接受新身份/加入组织 |
| 服装破损 | 经历战斗/磨难 |
| 与他人交换衣物 | 关系变化/身份互换 |

**Seedance 写法**：在角色描述中明确服装状态，如 `wearing [服装描述], [破损/整洁/不完整]`

---

### 7.9 场景布置 Set Dressing | ⭐⭐⭐

**定义**：场景中的物品摆放传递角色信息——照片、书籍、垃圾、武器、宗教物品等都在"说话"。

**Seedance 写法**：在环境描述中指定关键布景元素，如 `[场景] with [关键布景: family photos on wall / scattered books / religious icons]`

**适用场景**：
- 新场景首次建立时（用布景交代角色/空间信息）
- 场景变化时（物品被移动=有人来过）
- 隐藏线索（背景中的照片可能揭示关系）

---

### 7.10 动物/自然象征 Animal & Nature Symbolism | ⭐⭐

**定义**：用动物、天气、自然现象作为叙事隐喻。

**常见象征**：

| 元素 | 象征 | 本项目示例 |
|------|------|-----------|
| 狼 | 野性、威胁、猎食者 | 彩色玻璃窗的群狼图案 |
| 暴风雪 | 孤立、封锁、不可逃脱 | 贯穿第1-2集的暴风雪 |
| 月亮 | 循环、女性力量、疯狂 | 第1集 P08 血月升起 |
| 火/光 | 觉醒、力量、毁灭 | 第2集 P01 梦中之火 |
| 黑暗 | 未知、恐惧、潜意识 | 旅馆走廊的黑暗 |

**Seedance 写法**：在场景中自然地出现象征元素，如 `wolf motif visible in [stained glass/shadow/scratches on wall]`

---

### 7.11 单帧力量镜头 Single Frame Power Shot | ⭐⭐⭐

**定义**：一个单独的画面/帧承载大量叙事信息，观众一眼就能"读到"整个故事。张艺谋常用。

**Seedance 写法**：在描述定格/特写时强调画面的象征密度，如 `Single powerful frame — [角色] framed by [象征元素], [光影/色彩] creating [情绪], entire story visible in one shot`

**适用场景**：
- 角色被"狼"的剪影包围（本项目第2集 P08）
- 角色站在十字路口（选择）
- 角色在破碎的镜子前（破碎的自我）

---

## 八、场景→技巧匹配速查表

按常见场景类型快速查找最适配的影视技巧组合。

| 场景类型 | 推荐技巧 | 说明 |
|---------|---------|------|
| 角色回忆过去 | 闪回 + 过曝暖黄 + 叠化转场 | VO提到过去时必须闪回 |
| 角色发现秘密 | 推镜头 + ECU + 心跳加速 | 从中景推到特写，聚焦反应 |
| 恐怖/超自然出现 | 荷兰角 + 低调照明 + 低频嗡鸣 | 不安的视觉+声音 |
| 尖叫后 | 寂静 + 固定镜头 + 角色瘫软 | 声音消失比声音更恐怖 |
| 群像展示 | 横摇 + 权力站位 + 中景 | 一镜扫过所有人 |
| 时间流逝 | 时间压缩蒙太奇 + 色温变化 | 光线从暗到亮 |
| 角色内心冲突 | 明暗对比 + 侧光 + ECU眼睛 | 光影外化内心 |
| 被困/禁锢 | 门框构图 + 留白 + 逆光剪影 | 空间压迫感 |
| 角色觉醒/变身 | 环绕镜头 + 色彩编码 + 升降镜头 | 环绕展示变化 |
| 两人对话 | 过肩镜头 + 中景 + J/L-cut | 经典对话拍摄 |
| 噩梦场景 | 手持 + 底光 + 过饱和 + smash cut醒来 | 噩梦视觉语言 |
| 角色独白/观察 | 跟拍 + 画中画 + VO | 角色边走边思考 |
| 角色对峙 | 低角度仰拍反派 + 高角度俯拍主角 | 权力关系的视觉化 |
| 结尾悬念 | 拉镜头 + 淡出黑屏 + 声音渐弱 | 留下悬念收束 |
| 角色被追踪 | POV + 手持 + 快速横摇回看 | 紧张的追踪视角 |
| 发现隐藏线索 | 拉焦 + 插入镜头ECU + 心跳 | 先模糊后清晰的揭示 |
| 角色亮相 | 纵摇（脚到头）+ 低角度仰拍 | 从下到上展示角色全貌 |
| 梦境/幻觉 | 斯坦尼康 + 过饱和 + 慢动作 | 流畅但超现实的移动 |
| 场景转换（动态） | 快速摇摄 Whip Pan | 运动模糊中切换场景 |
| 角色审视环境 | 跟拍 + 引导线构图 + 前景遮挡 | 角色边走边发现线索 |
| 亲密对话 | 软光 + OTS + 浅景深 | 温柔聚焦于两人 |
| 暴力/冲击瞬间 | 慢动作 + 速度渐变 + 音乐刺点 | 关键瞬间的仪式感 |
| 角色双重身份 | 镜像/倒影 + 混合光 + 走位绕圈 | 视觉上的"两面" |
| 群体反应 | 横摇 + 环境群声 + 深度分层 | 一镜展示所有人的态度 |

---

## 九、AI 视频适配指南

### 9.1 Seedance 高适配技巧（直接描述即可）

这些技巧在单条 Seedance 提示词中可直接实现：

- **景别切换**：在分时段描述中指定景别（`medium shot`, `close-up`, `ECU`）
- **推拉镜头**：描述相机运动（`camera pushes in`, `camera pulls back`）
- **色彩编码**：直接指定颜色和色调
- **声音设计**：在音效部分描述（Seedance 会理解声音意图）
- **过曝闪回**：用 `overexposed warm yellow` 标记
- **光影**：指定 `low-key lighting`, `chiaroscuro` 等
- **构图**：指定 `symmetrical`, `Dutch angle`, `negative space`

### 9.2 Seedance 中适配技巧（需特殊处理）

- **叠化**：描述画面融合（`scene slowly dissolves into...`）
- **匹配剪辑**：描述形状相似性（`matching the shape of...`）
- **闪回**：用过曝标记 + 明确的时间点
- **手持**：添加 `handheld camera, slight shake`
- **声音桥**：在音效中描述过渡

### 9.3 Seedance 低适配技巧（需后期剪辑）

这些技巧单条视频无法实现，需要生成多条视频后人工拼接：

- **交叉剪辑**：生成两条视频 → 剪辑软件中交替拼接
- **跳切**：生成同一场景的不同状态 → 剪辑中跳切
- **J-cut / L-cut**：在剪辑软件中调整音画对齐
- **分屏**：生成两条视频 → 剪辑中分屏排列

### 9.4 真人检测注意事项

当使用包含真人面孔的参考图时，Seedance 会触发真人检测。解决方法：
1. 用 API 的图生图端点给故事板人物眼睛加白色遮挡条
2. 用遮眼版提交视频生成
3. 在提示词中写明正确瞳色，视频模型会恢复眼睛

---

## 十、短剧特殊技巧

短剧（1-3分钟/集）有独特的节奏需求，以下技巧在短剧中尤为重要：

### 10.1 每集必用技巧清单

| 集内位置 | 推荐技巧 | 目的 |
|---------|---------|------|
| 开场 0-3s | 倒叙开场 或 航拍建立 | 3秒内抓住注意力 |
| 中段节奏点 | 匹配剪辑 / 叠化 | 场景转换不拖沓 |
| 情绪高潮 | 特写 + 推镜头 + 寂静 | 放大关键瞬间 |
| VO段落 | 闪回（当VO提到过去时） | 声画一致性 |
| 结尾悬念 | 拉镜头 + 淡出 + 声音桥 | 留悬念，引向下一集 |

### 10.2 节奏与技巧的对应

| 节奏 | 技巧 | 说明 |
|------|------|------|
| 慢（铺垫） | 中景、固定镜头、环境音 | 建立氛围 |
| 中（推进） | 跟拍、横摇、对话OTS | 推进叙事 |
| 快（高潮） | 特写、推镜头、手持、寂静 | 放大情绪 |
| 停（转折） | 寂静、固定镜头、黑屏 | 暂停，让观众消化 |
| 起（新节奏） | Smash cut、航拍、过曝闪回 | 打破当前节奏 |
