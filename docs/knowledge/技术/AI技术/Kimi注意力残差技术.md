# Kimi 注意力残差技术 (Attention Residuals)

## 基本信息

- **来源**: 月之暗面 (Moonshot AI)
- **文档来源**: https://mp.weixin.qq.com/s/3UUCWUzZyiHJC1MHk7-kDg
- **论文地址**: https://github.com/MoonshotAI/Attention-Residuals/blob/master/Attention_Residuals.pdf
- **获取日期**: 2026-03-17
- **发布时间**: 2026年3月

## 背景知识

### 传统残差连接 (ResNet, 2015)

何恺明 2015 年提出的残差连接：

```python
h = h + f(h)
```

- 把上一层的输出原封不动地加到这一层的结果上
- 过去十年几乎所有大模型都在使用
- **问题**：等权累加，第 1 层和第 50 层的输出权重一样，层数越深，浅层信息被冲淡

### 相关技术演进

| 时间 | 团队 | 技术 | 思路 |
|------|------|------|------|
| 2015 | 何恺明 | ResNet | 一条直通车 |
| 2024 | 字节豆包 | 超连接 | 加三条车道 |
| 2025底 | DeepSeek | mHC (modified Hyper-Connection) | 装限速器 |
| 2026.3 | Kimi | Attention Residuals | 换发动机 |

## 核心技术：注意力残差 (Attention Residuals)

### 设计思想

将 Transformer 中用于"时间"维度的注意力机制，旋转 90 度用于"深度"维度：

- **传统方式**：第 50 层只能接收前面 49 层输出的等权累加
- **注意力残差**：第 50 层用注意力回头看前面所有层，自己决定该重点关注哪层

### Block AttnRes

**问题**：上百层模型，每层都回头看所有层，显存扛不住

**解决方案**：
- 把模型分成块
- 块内：传统累加
- 块间：用注意力选择

## 实验结果

### Scaling Law 实验

结论：使用注意力残差的模型始终比传统残差表现更好

**算力等效**：Block AttnRes 相当于 **白送 1.25 倍算力**

### 最大模型规格

- 架构：Kimi Linear
- 总参数：480 亿
- 激活参数：30 亿
- 训练数据：1.4 万亿 token

### 基准测试提升

| 测试 | 提升 |
|------|------|
| GPQA-Diamond (博士级科学问答) | +7.5% |
| Minerva Math (数学推理) | +3.6% |
| HumanEval (代码生成) | +3.1% |

**规律**：越难的任务，提升越大

### 与 mHC 对比

- 性能：几乎一样
- 显存开销：AttnRes **低六倍**
- 设计思路：mHC 是加车道装限速器；AttnRes 是换发动机

## 关键人物

- **杨植麟、吴育昕、周昕宇**：月之暗面联合创始人
- **苏剑林**：RoPE 位置编码提出者
- **Guangyu Chen (一作)**：17 岁高三学生，2025 年 3 月开始接触机器学习

## 技术启示

1. **注意力机制的普适性**：从时间维度扩展到深度维度
2. **动态权重优于静态权重**：让模型自己学习层间信息流动
3. **架构创新的价值**：十年不变的基础组件仍有改进空间
4. **显存效率**：Block AttnRes 在保持性能的同时大幅降低显存需求

## 参考链接

- Kimi「Attention Residuals」：https://github.com/MoonshotAI/Attention-Residuals/blob/master/Attention_Residuals.pdf
- DeepSeek「mHC」：https://arxiv.org/abs/2512.24880
- 字节「超连接」：https://arxiv.org/abs/2409.19606
- 何恺明「ResNet」：https://arxiv.org/abs/1512.03385
