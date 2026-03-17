---
name: learn
description: 学习指定分类的知识
menu-code: L
---

# Learn - 学习知识

从指定来源学习新知识并存储到对应分类。

## 输入参数

- **category**: 知识分类 (business/data/planning/tech/market)
- **source**: 学习来源 (URL/文件路径/文本内容)
- **source_type**: 来源类型 (url/file/text)

## 输入要求

- **source_url 应为具体文章 URL**，而非主页或列表页
- 如果接收到主页 URL，应先提取具体文章链接再进行学习
- 文档来源字段必须记录完整文章 URL

## 处理流程

1. **获取内容**
   - 如果 source_type=url: 使用 WebFetch 获取内容
   - 如果 source_type=file: 读取指定文件
   - 如果 source_type=text: 直接使用文本内容

2. **处理内容**
   - 使用 bmad-distillator 压缩提取关键要点
   - 提取核心概念、关键洞察、行动项

2.5 **校验内容**
   - 调用 bmad-review-adversarial-general 对压缩后的内容进行审查
   - 检查内容完整性、逻辑性、表述准确性
   - 如有问题，根据反馈修正内容
   - 校验通过后再进行存储

3. **存储到对应分类**
   - 根据内容主题选择合适的存储位置
   - 优先使用现有子目录结构
   - 如无匹配子目录则存放到分类根目录
   - 使用 bmad-index-docs 更新索引

4. **更新记忆**
   - 记录最新学习内容到 memory

## 输出格式

返回学习结果摘要，包括：
- 获取的内容概要
- 提取的关键要点
- 存储位置
- **文章标题**（用于 Git 提交）

## 文档元数据格式

生成的知识文档必须包含以下元数据：

```markdown
# [文章标题]

> 来源: [文章标题](具体文章URL)
> 获取日期: YYYY-MM-DD (使用当前日期)
> 原始发布日期: YYYY-MM-DD (如果可从文章中获取)

## 内容摘要
...
```
