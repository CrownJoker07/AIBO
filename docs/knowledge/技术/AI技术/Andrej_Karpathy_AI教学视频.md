# Andrej Karpathy AI 教学视频

> 从零构建神经网络的顶级教程系列
> 来源: https://www.youtube.com/@AndrejKarpathy
> 获取日期: 2026-03-18
> 最后更新: 2026-03-19

---

## 人物背景

### 基本信息

| 属性 | 内容 |
|------|------|
| **姓名** | Andrej Karpathy |
| **出生** | 1986年10月23日，捷克斯洛伐克布拉迪斯拉发（现斯洛伐克） |
| **教育** | 多伦多大学(学士) → UBC(硕士) → 斯坦福大学(博士) |
| **博士导师** | Fei-Fei Li |
| **博士论文** | 《Connecting Images and Natural Language》(2016) |
| **研究领域** | 深度学习、计算机视觉、自然语言处理 |

### 职业生涯

```
2006 ─── YouTube频道(badmephisto)发布魔方教程
  │
2015 ─── OpenAI 创始成员
  │
2015 ─── Stanford CS231n 课程主讲
  │      └─ 150→750 学生(2015-2017)
  │
2017 ─── Tesla AI总监 & Autopilot Vision负责人
  │
2022 ─── 离开 Tesla
  │
2023 ─── 回归 OpenAI
  │
2024 ─── 离开 OpenAI，创办 Eureka Labs
  │
2025 ─── 提出 "vibe coding" 概念
```

### 荣誉

- MIT Technology Review Innovators Under 35 (2020)
- TIME100 Most Influential People in AI (2024)

---

## YouTube 教学系列

### Neural Networks: Zero to Hero

这是 Karpathy 最著名的教程系列，从零开始构建神经网络，所有代码使用纯 Python/numpy。

| 视频主题 | 核心内容 | 项目 |
|----------|----------|------|
| **micrograd** | 自动微分引擎、反向传播 | 构建类 PyTorch 的 autograd |
| **micrograd** (续) | 理解 PyTorch 底层原理 | Value 类实现链式求导 |
| **makemore Part 1** | 字符级语言模型、Bigram | 统计方法生成名字 |
| **makemore Part 2** | MLP 实现 | Bengio 2003 论文复现 |
| **makemore Part 3** | 激活函数、梯度流 | 解决梯度消失/爆炸 |
| **makemore Part 4** | BatchNorm、训练技巧 | 批归一化原理与实现 |
| **makemore Part 5** | WaveNet 架构 | 扩张卷积实现 |
| **Let's build GPT** | Transformer 完整实现 | 从零实现 GPT-2 |
| **Backpropagation** | 梯度计算原理 | 手动推导反向传播 |
| **GPT tokenizer** | BPE 分词算法 | 最小化 tokenizer 实现 |
| **Let's reproduce GPT-2** | 完整训练流程 | 复现 GPT-2 (124M) |

### 教学特点

1. **从零构建**：不依赖深度学习框架，用 numpy 手写所有算法
2. **代码优先**：边写代码边解释，而非先理论后实践
3. **可视化强**：大量图示帮助理解抽象概念
4. **循序渐进**：从简单到复杂，每一步都清晰可理解

### 视频系列详细知识点

#### micrograd 系列
- **自动微分核心**：构建 Value 类，实现 `+`, `*`, `tanh` 等操作
- **反向传播**：`backward()` 方法递归计算梯度
- **拓扑排序**：确保计算顺序正确
- **PyTorch 对照**：验证实现与 PyTorch 结果一致

#### makemore 系列 (5 parts)
```
Part 1: Bigram → 统计语言模型
Part 2: MLP  → 多层感知机 (Bengio 2003)
Part 3: 激活  → Kaiming 初始化、梯度流分析
Part 4: BN   → BatchNorm 原理与实现
Part 5: WNet → WaveNet 扩张卷积
```

#### GPT 系列
- **Tokenizer**：BPE (Byte Pair Encoding) 从零实现
- **Attention**：自注意力机制、多头注意力
- **Transformer Block**：LayerNorm、MLP、残差连接
- **训练复现**：完整复现 GPT-2 (124M 参数)

---

## 开源项目

### GitHub 热门仓库

| 项目 | Stars | 描述 |
|------|-------|------|
| **[nanoGPT](https://github.com/karpathy/nanoGPT)** | 55k | 最简单的 GPT 训练/微调仓库 |
| **[llm.c](https://github.com/karpathy/llm.c)** | 29.2k | 纯 C/CUDA 实现 LLM 训练 |
| **[llama2.c](https://github.com/karpathy/llama2.c)** | 19.3k | 单文件纯 C 实现 Llama 2 推理 |
| **[micrograd](https://github.com/karpathy/micrograd)** | 15.1k | 微型自动微分引擎 |

### nanoGPT 特点

```python
# 训练一个 GPT-2 的最简代码
python train.py config/train_gpt2.py
```

- 代码简洁：核心代码 ~600 行
- 复现性强：可训练 GPT-2、复现 NanoGPT 论文结果
- 教育价值：理解 GPT 训练的完整流程

### micrograd 核心概念

```python
# 自动微分示例
x = Value(2.0)
y = Value(3.0)
z = x * y + x  # 2*3 + 2 = 8
z.backward()
print(x.grad)  # 4 (dz/dx = y + 1)
print(y.grad)  # 2 (dz/dy = x)
```

---

## Eureka Labs

### 公司定位

2024年7月创办的 AI+教育公司，核心理念：**利用 AI 助教辅助人类教师**。

### 首门课程：LLM101n

- **全称**：Let's Build A Storyteller
- **目标**：从零构建一个大语言模型
- **特点**：结合 AI 助教，个性化学习体验

### 教育理念

```
传统教育: 教师 → 学生 (单向)
AI教育:   教师 ↔ AI助教 ↔ 学生 (多向互动)
```

---

## 关键概念：Vibe Coding

2025年2月，Karpathy 提出的新概念：

> **"Vibe coding"** - AI 工具让非程序员只需通过提示词就能构建应用和网站

### 核心观点

1. **编程门槛降低**：从"写代码"变为"描述想法"
2. **创意 > 语法**：重点在于想做什么，而非怎么写
3. **AI 作为翻译器**：将自然语言意图转化为代码实现

---

## 学习路径推荐

### 初学者路线

```
1. micrograd 视频 → 理解自动微分和反向传播
        ↓
2. makemore 系列 → 学习语言模型基础
        ↓
3. Let's build GPT → 掌握 Transformer 架构
        ↓
4. nanoGPT 实践 → 训练自己的 GPT
```

### 进阶路线

```
1. llm.c 源码 → 理解底层 CUDA 优化
        ↓
2. llama2.c → 学习高效推理实现
        ↓
3. LLM101n 课程 → 系统化 LLM 知识
```

---

## 核心教学哲学

### 1. 第一性原理

> "我不喜欢黑盒。理解每个组件如何工作，才能真正掌握它。"

- 不满足于调用 API
- 追问"为什么这样设计"
- 从数学原理出发

### 2. 渐进式复杂度

```
单变量 → 多变量 → 向量 → 矩阵 → 张量
  ↓
简单网络 → 多层网络 → 卷积网络 → Transformer
```

### 3. 代码即文档

- 每行代码都有明确目的
- 变量命名揭示意图
- 注释解释"为什么"而非"是什么"

---

## 资源链接

| 资源 | 链接 |
|------|------|
| YouTube 频道 | https://www.youtube.com/@AndrejKarpathy |
| GitHub | https://github.com/karpathy |
| 个人网站 | https://karpathy.ai |
| Eureka Labs | https://eurekalabs.ai |
| Zero to Hero 课程 | https://karpathy.ai/zero-to-hero.html |

---

## 关键洞察

1. **深度学习本质是数学 + 工程的平衡**
   - 数学提供理论基础
   - 工程让理论落地

2. **从简单开始的价值**
   - 先理解 1 层网络，再理解 100 层
   - 先理解单变量，再理解高维张量

3. **教学是最好的学习**
   - Karpathy 通过教学深化理解
   - 每个视频都是他重新学习的过程

4. **开源的力量**
   - nanoGPT 让数万人学会训练 GPT
   - 代码比论文更有教育价值

5. **AI 教育的未来**
   - AI 助教可以个性化教学
   - 但人类教师不可替代

---
