# Tenjin Best Practices 最佳实践汇总

> 移动广告ROI与归因分析最佳实践
> 来源: https://tenjin.com/blog/category/best-practices/
> 获取日期: 2026-03-18

---

## 文章目录

| 文章标题 | 发布日期 | 核心主题 |
|----------|----------|----------|
| Unit Economics For F2P Games | 2026-03-12 | F2P单位经济学 |
| How to Calculate Revenue for IAA | 2026-02-27 | IAA收入计算框架 |
| Mobile Gaming in India | 2026-02-19 | 印度市场本地化 |
| ComfyUI Workflow | 2026-02-17 | AI创意工作流 |
| Ad Creatives in 2026 | 2026-02-16 | AI创意趋势 |
| IAA & IAP Attribution | 2025-12-08 | 归因差异 |
| App Retention Strategies | 2025-11-19 | 留存策略 |
| Python for Mobile Marketing | 2025-07-30 | 营销自动化 |
| PSV Game Studio | 2025-07-01 | 案例研究 |
| TikTok Ads Best Practices | 2025-05-28 | TikTok广告 |

---

## 一、F2P 游戏单位经济学

**原文链接**: https://tenjin.com/blog/unit-economics-for-f2p-games/
**发布日期**: 2026-03-12
**作者**: Tara Meyer
**嘉宾**: Michal Tomčány（斯洛伐克游戏设计师，10年F2P经验）

### 核心定义

**Unit Economics（单位经济学）**：衡量获取和变现单个用户盈利能力的商业框架。

> "Unit economics is a business model. If you do game dev as a business, or if you want your game to generate revenue, and you want to make a living...you have to treat it as a business."
> — Michal Tomčány

### F2P 含义

**F2P (Free-to-Play)**：游戏免费下载和游玩，通过内购(IAP)和/或应用内广告(IAA)产生收入的商业模式。

- 2025年F2P模式占移动游戏收入 **70%以上**
- 允许玩家通过可选IAP增强游戏体验，而非预付费

### 爱好者 vs 专业框架

| 类型 | 特征 | 目标 |
|------|------|------|
| **爱好者** | 专注于创造乐趣，变现次要 | 快乐优先 |
| **专业** | 从收入目标开始建模 | 可持续商业 |

### 收入预测：预测分析的力量

#### 核心步骤

```
Step 1: 设定收入目标 → 从目标反向建模
Step 2: 使用LTV计算器 → 预测关键指标
Step 3: 计算付费用户支出 → 确定定价策略
```

#### LTV计算示例

| 指标 | 假设值 |
|------|--------|
| 转化率 | 5% |
| LTV (45天) | $12.60 |
| UA支出 | $5.00/用户 |
| 45天ROAS | 251% |

### 产品市场匹配：模型与现实

#### 常见错位问题

- **定价与模型不同步**：$3.99去广告仍无法达到目标
- **UA与产品团队不同步**：各自为政导致失败

> "What your UA team does and what your product team does needs to be synchronous. That's what distinguishes success versus not success."
> — Michal Tomčány

### 关键成功原则

| 原则 | 描述 |
|------|------|
| **1. 从高开始，向下调整** | 不要因恐惧而低估IAP价格 |
| **2. 用数据消除假设** | 用现有数据替代假设 |
| **3. 区分商业与爱好** | 知道何时在做商业vs爱好 |

### 何时建立单位经济学模型

- **专业开发者**：始终在开始前建模
- **爱好者转型**：分析现有指标，识别差距

---

## 二、IAA 收入计算框架

**原文链接**: https://tenjin.com/blog/how-to-calculate-revenue-for-in-app-advertising-iaa/
**发布日期**: 2026-02-27
**作者**: Tara Meyer
**专家**: Anurag Mohan (Tenjin高级客户成功经理)

### 核心挑战

> 一个仪表板显示$50,000广告收入，另一个显示$48,000。当差异达到10-20%时，如何做出决策？

### 为什么Tenjin使用两个收入源

| 收入源 | 数据来源 | 计算方式 |
|--------|----------|----------|
| **Ad Mediation Revenue** | SDK实时获取 | 基于展示级(ILRD) |
| **Ad Revenue via Channels API** | 广告网络API | 基于会话分配 |

### 两种收入计算方法

#### 方法1：通过Mediation计算

```
Tenjin SDK → 从Mediation SDK获取ILRD → 分配给用户 → 聚合到Campaign/App级别
```

- 包含：a) 收入值 b) 用户ID c) 时间戳 d) 位置详情
- 实时性高，基于展示级别

#### 方法2：通过Channels API计算

```
Tenjin → 调用广告网络API → 获取聚合收入 → 基于会话分配到Campaign
```

- 数据来自Google AdMob、Unity Ads、ironSource等
- 基于会话数分配

### 为什么报告两个IAA收入源

#### 1. 广告收入归因

| LTV类型 | 来源 | 用途 |
|---------|------|------|
| **Ad Mediation LTV** | 展示级数据 | 精确用户级归因 |
| **Ad Revenue via Channels LTV** | 会话分配 | 聚合级分析 |

#### 2. 检测无效广告请求

**欺诈信号**：
- Mediation收入远高于Channels API收入
- 可能存在虚假展示

> "If there's an inflated number of ad impressions that a fraudulent user generated, your Ad Mediation Revenue is going to look inflated. But the Ad Revenue via Channels API... is not going to be inflated because that's the actual revenue."
> — Anurag Mohan

#### 3. 计算逻辑差异

| 差异原因 | 说明 |
|----------|------|
| 时区差异 | Mediation vs 广告网络 |
| API延迟 | 报告延迟 |
| 货币转换 | 不同时间点汇率 |
| **正常范围** | <15%差异正常 |
| **异常范围** | >15-20%需调查 |

#### 4. 全局可见性

- 某些广告网络可能在Mediation栈外
- Channels API确保捕获所有收入来源

---

## 三、印度移动游戏本地化策略

**原文链接**: https://tenjin.com/blog/mobile-gaming-in-india-mobile-app-localization-strategies/
**发布日期**: 2026-02-19
**作者**: Tara Meyer
**嘉宾**: Joseph Kim (GameMakers创始人，20年游戏高管经验)

### 市场机会

| 指标 | 数据 |
|------|------|
| **数字游戏收入CAGR** | 31%（2023年起） |
| **2030年市场规模** | $44亿 |
| **用户支出增长** | 9倍（过去5年） |
| **ARPPU增长** | $3(2020) → $27(2025) |

> "From a market perspective, it is the fastest growing market in the world... Just in terms of the digital gaming revenue, we're seeing that there's been significant growth at a 31% CAGR."
> — Joseph Kim

### 移动优先基础设施

- **移动渗透率**: 80%+
- **PC渗透率**: 仅10-15%
- **特征**: 信息和娱乐消费本质上是移动优先

### 双重机会模式

| 模式 | 描述 | 优势 |
|------|------|------|
| **Global to Local** | 印度人才为全球市场开发，再本地化 | 成本效益、文化理解、本地测试 |
| **India-first** | 专为印度市场开发 | 精准匹配本地偏好 |

### BGMI案例研究：终极本地化案例

#### 背景
- 2020年中国应用禁令
- PUBG Mobile（33M DAU）被移除

#### 解决方案
Krafton与印度公司合作，推出Battlegrounds Mobile India (BGMI)

#### 关键本地化元素

| 元素 | 实施 |
|------|------|
| **本地合作结构** | 与印度公司合作 |
| **文化定制** | 血液颜色从红变绿、家长同意条款 |
| **监管合规** | 符合印度法规 |

#### 成果
- 首月 **3400万下载**
- 峰值 **1800万DAU**（50%恢复率）

### 市场进入策略

| 策略 | 描述 |
|------|------|
| **1. 从小开始测试** | 软启动、测量参与度、验证PMF |
| **2. 聘请本地PM** | 理解文化细微差别 |
| **3. 超越翻译的本地化** | UA、留存、支付、设计全链路 |
| **4. 理解监管环境** | 年龄验证、数据本地化、合规 |
| **5. 优化低端设备** | 小安装包、低内存、省电 |
| **6. 适应变现策略** | 本地支付(Paytm、UPI)、合理价格 |

### 类型机会

> "Outside of BGMI and Free Fire and maybe Call of Duty Mobile, there aren't a lot of other titles that have meaningfully penetrated the top grossing charts."
> — Joseph Kim

- Battle Royale主导，但其他类型机会巨大
- RMG（真钱游戏）2025年底被禁，释放消费支出

---

## 四、ComfyUI AI工作流

**原文链接**: https://tenjin.com/blog/comfyui-workflow-free-ai-tools-to-grow-your-mobile-game/
**发布日期**: 2026-02-17
**作者**: Tara Meyer
**嘉宾**: Jakub (Two & a Half Gamers)

### 2026年预测

> "By the end of 2026, there will be around 50% of all UA creatives either having AI hooks or completely done by AI."
> — Jakub

### 开源AI vs 黑盒工具

| 特征 | 西方黑盒工具 | 中国开源AI |
|------|--------------|------------|
| **成本模式** | 月订阅 | 初始设置后免费 |
| **定制性** | 有限提示词 | 完全可定制 |
| **生态系统** | 封闭 | 类似Skyrim模组社区 |
| **示例** | OpenAI, Midjourney | ComfyUI, CivitAI模型 |

### 为什么开源AI胜出

> "Open-source AI generation is not confined only to images and video. You can generate whatever you want... You can do audio, 3D assets, 2D assets, 2D sprites—like, you can generate whatever you want."
> — Jakub

### 硬件要求

| 配置 | 最低要求 | 推荐配置 |
|------|----------|----------|
| **GPU VRAM** | 8-10GB | 12-24GB |
| **GPU类型** | NVIDIA CUDA | NVIDIA RTX系列 |
| **成本** | - | $1,500-$3,000 |
| **ROI** | - | 6-16个月回本 |

### 软件栈（全部免费）

- **ComfyUI**: 核心工作流引擎
- **CivitAI**: 模型下载源
- **Stable Diffusion**: 图像生成
- **各种开源模型**: 社区贡献

### ComfyUI vs 替代方案

| 工具 | 适用场景 | 优势 |
|------|----------|------|
| **ComfyUI** | 每周50+创意变体 | 无限生成、完全控制 |
| **Midjourney** | 少量高质量图像 | 简单易用 |
| **Runway** | 视频生成 | 专业视频工具 |

### 图像到视频工作流

> "The key to video generation, anything, is image generation. That's the number one rule."
> — Jakub

#### 为什么文本到视频不能规模化

- **缺乏控制**: 无法控制角色外观、环境
- **不可重复**: 每次生成不同结果
- **A/B测试困难**: 无法隔离变量

#### 正确工作流

```
文本 → 图像生成（控制外观） → 图像到视频 → 批量变体
```

---

## 五、IAA vs IAP 归因差异

**原文链接**: https://tenjin.com/blog/iaa-iap-differences-in-ad-revenue-attribution/
**发布日期**: 2025-12-08
**作者**: Tara Meyer
**嘉宾**: Mariusz Gąsiewski (Google)

### 核心定义

#### IAP（内购）

- 用户直接购买虚拟商品
- 转化率: 2-5%
- 付费用户价值显著高于广告用户

#### IAA（应用内广告）

- 通过展示广告产生收入
- 100%用户可贡献收入
- 广告质量影响留存

### 核心差异

| 维度 | IAP | IAA |
|------|-----|-----|
| **转化率** | 2-5% | ~100% |
| **归因方式** | 事件驱动 | 展示/会话分配 |
| **数据延迟** | 实时 | 24-48小时 |
| **收入分配** | 精确 | 估算 |

### 混合变现崛起

> "Believe it or not, the potential for IAA looks pretty bright."
> — Mariusz Gąsiewski

- 2025年最成功游戏不选择单一模式
- 混合变现(IAA+IAP)成为主流

### 从CPI到价值导向UA

| 阶段 | 策略 | 焦点 |
|------|------|------|
| **传统** | CPI | 安装成本 |
| **现代** | 价值导向 | 用户价值 |

### 三大预测

| 预测 | 描述 |
|------|------|
| **1. 持续增长** | IAA收入增长可能超过IAP |
| **2. 混合变现聚焦** | 开发者更注重优化组合策略 |
| **3. 新兴市场机会** | 增长在新兴市场更明显 |

---

## 六、应用留存策略

**原文链接**: https://tenjin.com/blog/app-retention-strategies/
**发布日期**: 2025-11-19
**作者**: Tara Meyer
**专家**: Roman (Tenjin营销总监), Jas (高级产品经理)

### 核心认知

> "Your app retention strategies are only as good as your measurement framework."
> — Tenjin

**问题**：多数发行商不知道测量方法论差异

### 留存的重要性

- **Day 1留存**: 最早的用户质量信号
- **影响决策**: UA预算分配、onboarding有效性、收入分成协议

### 绝对留存 vs 相对留存

| 类型 | 定义 | 计算方式 |
|------|------|----------|
| **绝对留存** | 日历边界法 | UTC午夜重置窗口 |
| **相对留存** | 24小时法 | 基于安装时间戳 |

#### 绝对留存示例

```
安装时间: 6 PM (Day 0)
返回时间: 8 PM (同一天)
结果: 被计为 Day 1 留存 ✓
```

#### 相对留存示例

```
安装时间: 1 PM
Day 1窗口: 1 PM → 次日 1 PM
返回时间: 必须在24小时内
结果: 真实返回行为 ✓
```

### 误报信号问题

> "This is sort of a false positive signal... I'm not sure if this user is really retained. They just came back in two minutes."
> — Roman

**绝对留存风险**：
- 11:59 PM安装，12:01 AM返回 = 留存
- 数字虚高，不反映真实参与

### 使用场景指南

| 场景 | 推荐方法 | 原因 |
|------|----------|------|
| **比较分析平台** | 绝对留存 | 与Firebase等对齐 |
| **UA活动优化** | 相对留存 | 更准确的用户质量 |
| **出版商谈判** | 对齐使用 | 确保公平比较 |

### 选择建议

> "In my opinion, it's better when the retention number is conservative. And, because the absolute is always higher than relative, I would always use relative retention."
> — Roman

**相对留存优势**：
- 时区无关
- 用户特定
- 无日历技巧
- 无误报

---

## 七、关键行动要点

### 单位经济学
- [ ] 从收入目标开始反向建模
- [ ] 确保UA与产品团队同步
- [ ] IAP定价从高开始

### IAA收入计算
- [ ] 使用双源验证
- [ ] 监控差异(>15%需调查)
- [ ] 理解两种LTV计算差异

### 印度市场
- [ ] 聘请本地产品经理
- [ ] 超越翻译的深度本地化
- [ ] 优化低端设备体验

### AI创意工作流
- [ ] 评估开源AI工具投资ROI
- [ ] 建立图像到视频工作流
- [ ] 每周50+创意测试目标

### 留存测量
- [ ] 选择合适的留存计算方法
- [ ] 与合作伙伴对齐方法论
- [ ] 使用相对留存做UA决策

---

## 相关资源

- [Tenjin Blog](https://tenjin.com/blog/)
- [Tenjin Case Studies](https://tenjin.com/blog/category/case-studies/)
- [Tenjin pLTV混合变现预测模型](./2026-03-18-Tenjin-LTV预测pLTV深度解析.md)
- [IAA与IAP广告收入归因差异](./2026-03-18-IAA与IAP广告收入归因差异.md)
- [AI创意工作流2026](../广告/2026-03-18-AI创意工作流2026-移动游戏广告.md)
