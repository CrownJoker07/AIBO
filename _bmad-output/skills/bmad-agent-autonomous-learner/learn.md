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

## 处理流程

1. **获取内容**
   - 如果 source_type=url: 使用 WebFetch 获取内容
   - 如果 source_type=file: 读取指定文件
   - 如果 source_type=text: 直接使用文本内容

2. **处理内容**
   - 使用 bmad-distillator 压缩提取关键要点
   - 提取核心概念、关键洞察、行动项

3. **存储到对应分类**
   - 原始内容: `docs/knowledge/{category}/raw/`
   - 处理后: `docs/knowledge/{category}/processed/`
   - 更新索引

4. **更新记忆**
   - 记录最新学习内容到 memory

## 输出

返回学习结果摘要，包括：
- 获取的内容概要
- 提取的关键要点
- 存储位置
