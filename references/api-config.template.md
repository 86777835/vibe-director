# API 配置模板

> 把这份模板**复制到本地**，填好值后**粘贴回 agent**，agent 自动解析并写入 `wiki/api-config.md`。
> 也可以删除不需要的板块，agent 会根据你给的内容推断你的制作范围。

---

## 怎么用

1. 复制下方"配置模板"代码块
2. 填值（删除占位符 `<...>` 替换为真实值）
3. 粘贴回 agent，说"这是我的配置"
4. agent 解析 + 写入 `wiki/api-config.md` + 报告"X 配置已生效"

---

## 配置模板

```yaml
---
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 【板块 1】图片生成 API（故事板 + 角色/场景参考图）
# 制作范围 ②③ 必填
# 兼容：GPT-image-2 / OpenAI Images API 兼容服务
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

img_api_edit: "<图生图端点 URL>"
# 例：https://api.example.com/v1/images/edits

img_api_gen: "<文生图端点 URL，可选；如与上面相同可省略>"
# 例：https://api.example.com/v1/images/generations

img_api_key: "<sk-xxxxx>"
# 你的 API Key（保密！）

img_api_model: "gpt-image-2"
# 默认值，可改为其他兼容模型名

img_size_storyboard: "1792x1024"
# 故事板尺寸，16:9 横屏

img_size_character: "1024x1024"
# 角色/场景参考图尺寸，1:1


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 【板块 2】视频生成 API（Seedance）
# 制作范围 ③ 必填，仅范围 ②② 可不填
# 当前支持：Doubao Seedance 2.0
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

vid_api: "<视频生成端点 URL>"
# 例：https://api-direct.example.com/v1/videos

vid_api_key: "<sk-xxxxx>"
# 视频 API Key（可能与图片 API 不同）

vid_model: "doubao-seedance-2-0-260128"
# 默认 Seedance 2.0


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 【板块 3】对象存储（TOS / S3 / OSS）
# 制作范围 ③ 必填（视频生成需要图片公开 URL）
# 常用：火山引擎 TOS / AWS S3 / 阿里云 OSS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tos_endpoint: "<endpoint>"
# 例：tos-cn-beijing.volces.com

tos_region: "<region>"
# 例：cn-beijing

tos_bucket: "<bucket-name>"
# 你创建的存储桶名

tos_ak: "<AKLT...>"
# Access Key

tos_sk: "<base64 encoded SK>"
# Secret Key

tos_base_url: "<https://bucket.endpoint/>"
# 可选；公开 URL 前缀，如 https://drama-production.tos-cn-beijing.volces.com/
# 不填则 agent 自动拼

---
<!-- API 配置 — vibe-director 技能使用 -->
```

---

## 范围速查

| 我只想 | 需要填的板块 |
|--------|------------|
| 写剧本（纯文字） | 一个都不用，整段删掉即可 |
| + 故事板 | 板块 1 |
| + 视频 | 板块 1 + 2 + 3 |

---

## 示例（已脱敏，供参考格式）

```yaml
---
img_api_edit: "https://api.example.com/v1/images/edits"
img_api_key: "sk-REDACTED-YOUR-IMAGE-API-KEY"
img_api_model: "gpt-image-2"
img_size_storyboard: "1792x1024"
img_size_character: "1024x1024"

vid_api: "https://api.example.com/v1/video/generations"
vid_api_key: "sk-REDACTED-YOUR-VIDEO-API-KEY"
vid_model: "doubao-seedance-2-0-260128"

tos_endpoint: "tos-cn-beijing.volces.com"
tos_region: "cn-beijing"
tos_bucket: "your-bucket-name"
tos_ak: "AKLT-REDACTED-YOUR-ACCESS-KEY"
tos_sk: "REDACTED-YOUR-SECRET-KEY-BASE64"
tos_base_url: "https://your-bucket-name.tos-cn-beijing.volces.com/"
---
```

> ⚠️ 这只是**格式示范**。真实 key 请通过私密渠道获取，**不要**复制此处的占位符。

---

## 推荐的 API 服务商

> 这些是社区常用，**非官方推荐**。自行评估隐私/合规。

### 图片 API（GPT-image-2 兼容）
| 服务商 | 端点示例 | 备注 |
|--------|---------|------|
| OpenAI 官方 | `https://api.openai.com/v1/images/edits` | 海外信用卡 |
| Sumone | `https://sumone.hk/v1/images/edits` | 国内可达，价格透明 |
| AI Proxy | `https://api.aiproxy.io/v1/images/edits` | 国内中转 |

### 视频 API（Seedance）
| 服务商 | 端点示例 | 备注 |
|--------|---------|------|
| 火山引擎官方 | 见火山引擎控制台 | 需企业认证 |
| AI Router | `http://airouter.guiyi.cn/v1/video/generations` | 中转服务 |

### 对象存储
| 服务商 | endpoint 格式 | 备注 |
|--------|--------------|------|
| 火山引擎 TOS | `tos-{region}.volces.com` | 与 Seedance 同源，最方便 |
| 阿里云 OSS | `oss-{region}.aliyuncs.com` | 兼容 S3 |
| AWS S3 | `s3.{region}.amazonaws.com` | 海外 |

---

## 自由格式也行

不愿意用模板？直接说：

> "我的图片 API endpoint 是 X，key 是 Y。视频 API endpoint 是 Z..."

Agent 也会解析。模板只是**让你少打字**的工具。

---

## 安全提醒

- ⚠️ `api-config.md` 含敏感 key，**不要提交到公开 git 仓库**
- 项目根加 `.gitignore` 排除 `wiki/api-config.md`
- 团队协作时通过私密渠道分享 key，不要走聊天工具

agent 在 `/导入 --replace` 等危险操作时会自动备份 `api-config.md`，不会丢失。
