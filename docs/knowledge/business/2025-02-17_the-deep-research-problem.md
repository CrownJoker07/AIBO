# The Deep Research Problem

## 元数据
- **作者**: Benedict Evans
- **来源**: https://www.ben-evans.com/benedictevans/2025/2/17/the-deep-research-problem
- **发布日期**: 2025-02-18
- **获取日期**: 2026-03-17
- **分类**: Business / AI Strategy
- **标签**: #AI #DeepResearch #LLM #ErrorRate #ProductMarketFit

---

## 核心观点

OpenAI 的 Deep Research 产品展示了 LLM 的核心矛盾：**它能处理复杂的研究问题，但无法提供可信赖的精确数据**。这是一个"实习生级别"的问题——输出看起来很专业，但需要专家验证每个数字。

---

## 关键洞察

### 1. LLM 不是数据库
- LLM 不做精确、确定性、可预测的数据检索
- 它是概率性系统，告诉你"一个好的答案大概长什么样"
- 用 LLM 做 SQL 式的精确查询是原则性错误

### 2. Deep Research 的具体失败案例
Benedict Evans 用 OpenAI 自己的产品页面示例进行验证：
- **问题**: 日本智能手机市场份额
- **声称来源**: Statista 和 Statcounter
- **实际问题**:
  - Statcounter 测量的是流量而非装机量，iPhone 用户使用频率更高
  - Statista 实际来源是 Kantar Worldpanel，数字与 Deep Research 声称的相反
  - 日本监管机构的官方数据显示：Android 53%，iOS 47%（而非 Deep Research 声称的 iOS 69%）

### 3. 概率性问题 vs 确定性答案
- **问题类型一**: "采用率是多少？" → 这是什么意思？销量？装机量？使用份额？应用支出份额？
- **问题类型二**: "哪个数据源更可靠？" → 需要专业判断
- **核心矛盾**: 我们从概率性问题中寻求确定性答案

### 4. "85% 正确"没有意义
> "如果表格中有错误，错误数量并不重要——我无法信任它。"

- 85% 正确 vs 91% 正确的区别对专业用户无意义
- 需要的是从"有时错误"到"总是正确"的二元转变
- 这不是渐进改进，而是系统本质的质变

### 5. 有用但不可靠
Deep Research 的实际价值：
- ✅ 将几天的工作压缩到几小时
- ✅ 领域专家可以快速修复错误
- ✅ "无限的实习生" + "大脑的自行车"
- ❌ 不能独立完成需要精确数据的任务

---

## 战略思考

### Foundation Model 的困境
1. **没有护城河**: 除了资本获取能力
2. **没有产品市场契合**: 除了编程和营销领域
3. **没有真正的产品**: 只有文本框和 API

### 两种可能的产品方向
1. **假设模型会犯错**: 构建能够管理错误率的产品
2. **假设模型将完美**: 构建可以独立依赖模型的产品

> "我们不知道错误率是否会消失，因此我们不知道应该构建哪种产品。"

### LLM 的本质定位
- LLM 擅长计算机不擅长的事（理解意图）
- LLM 不擅长计算机擅长的事（精确检索）
- 最佳实践：将 LLM 作为 API 调用嵌入到能够管理它的软件中

---

## 引用金句

> "LLMs are not databases: they do not do precise, deterministic, predictable data retrieval."

> "If there are mistakes in the table, it doesn't matter how many there are - I can't trust it."

> "A computer is 'a bicycle for the mind' - it lets you go further and faster for much less effort, but it can't go anywhere by itself."

---

## 延伸思考

- 如何设计能够优雅处理 LLM 错误率的产品 UX？
- "Deep Research"类产品的正确应用场景是什么？
- 错误率是 LLM 的本质属性还是可以通过工程解决的问题？
