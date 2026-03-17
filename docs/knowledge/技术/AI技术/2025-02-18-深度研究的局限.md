# The Deep Research Problem：深度研究的局限

## 元数据

- **来源**: https://www.ben-evans.com/benedictevans/2025/2/17/the-deep-research-problem
- **作者**: Benedict Evans
- **发布日期**: 2025-02-18
- **获取日期**: 2026-03-17
- **分类**: AI商业策略、LLM局限性、研究分析

## 核心要点

OpenAI 的 Deep Research 看起来是为分析师量身定制的，但实际使用中发现严重问题。它是一个"惊人的演示，直到它崩溃"，但它崩溃的方式非常有趣。

## 测试案例：智能手机市场份额

### OpenAI 自己的示例报告

Deep Research 生成的日本智能手机市场数据表：
- iOS: 69%
- Android: 31%

**来源声称**：Statista 和 Statcounter

### 事实核查

| 来源 | Deep Research 声称 | 实际数据 |
|------|-------------------|----------|
| Statcounter | 69% iOS | 超过一年没有这个数据 |
| Statista (实际来源: Kantar) | 69% iOS | **63% Android, 36% iOS** |
| 日本监管机构调查 | - | **53% Android, 47% iOS** |

### 数据质量问题

**Statcounter 问题**：
- 测量的是**流量**，不是采用率
- 高端设备使用更多
- iPhone 偏向高端，过度代表

**Statista 问题**：
- 聚合他人数据
- SEO 优化优先
- 付费墙限制查看
- 像说"来源是 Google 搜索结果"

**Kantar 问题**：
- 数据月波动达 20 个百分点
- 不符合硬件安装基数正常行为

## 核心问题分析

### 两层问题

**第一层：问题定义**
- "采用率"是什么意思？
- 单位销售？安装基数？使用份额？应用支出？
- 这些是不同的东西

**第二层：来源选择**
- 没有单一来源
- 需要判断力和专业知识
- Statcounter vs Statista vs Kantar vs 其他？

### 概率问题 vs 确定性答案

> "We're asking for a deterministic answer from a probabilistic question, and there it looks like the model really is failing on its own terms."

LLM 擅长：
- 理解你可能**大概**想要什么

LLM 不擅长：
- 高度具体的信息检索

## LLM 的本质矛盾

### "LLMs are good at the things computers are bad at, and bad at the things computers are good at"

| 计算机擅长 | LLM 擅长 |
|-----------|----------|
| 精确信息检索 | 理解模糊意图 |
| 确定性操作 | 概率性推理 |

OpenAI 试图让模型：
1. 弄清楚你**大概**想要什么（LLM 擅长）
2. 做高度具体的信息检索（LLM 不擅长）

**结果**：不完全工作。

## 错误率的本质

### "更好"不是解决方案

> "Are you telling me that today's model gets this table 85% right and the next version will get it 85.5 or 91% correct? That doesn't help me. If there are mistakes in the table, it doesn't matter how many there are - I can't trust it."

**关键洞察**：
- 85% → 85.5% 准确率没有帮助
- 如果有错误，不能信任整个表格
- 100% 正确是**二元变化**，不是百分比变化
- 我们不知道这是否可能

### 文本报告的同样问题

不只是数字表格：
- 十页文本报告同样"大部分正确，但只是大部分"
- 同样的概念问题适用

## 实际价值

### 仍然有用的场景

**如果你有深度领域专业知识**：
- 需要生成 20 页报告
- 但没有现成的 20 页文档
- 将几天工作变成几小时
- 你可以修复所有错误

### "无限实习生" + "思维自行车"

> "I always call AI 'infinite interns'... but there's also Steve Jobs' line that a computer is 'a bicycle for the mind' - it lets you go further and faster for much less effort, but it can't go anywhere by itself."

## 两个根本问题

### 问题 1：错误率会消失吗？

| 假设 | 产品方向 |
|------|----------|
| 模型会出错 | 构建管理错误的产品 |
| 模型将完美 | 构建依赖模型的产品 |

我们不知道哪个是对的。

### 问题 2：基础模型公司的困境

**缺乏护城河**：
- 只有资本获取能力
- 编码和营销之外没有产品市场契合度
- 没有真正产品，只有文本框

**Deep Research 的意义**：
- 尝试创建有粘性的产品
- 实例化一个用例

**但**：
- Perplexity 几天后声称推出同样东西
- 管理错误率的最好方式是将 LLM 抽象为 API 调用
- 这使基础模型更商品化

## 战略启示

1. **不要信任，要验证**：如果需要检查每个数字，不如自己做
2. **领域专业知识仍然关键**：需要知道什么是对错
3. **LLM 是工具，不是解决方案**：需要人类专家使用
4. **产品化方向不确定**：我们不知道错误率问题是否会解决

## 延伸阅读

- [Better Models 问题](./benedict-evans-better-models.md)
- [The AI Summer](./benedict-evans-ai-summer.md)
- Benedict Evans 博客: https://www.ben-evans.com
