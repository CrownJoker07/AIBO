---
name: research
description: 主动调研特定领域
menu-code: R
---

# Research - 主动调研

主动调研特定领域并生成调研报告。

## 输入参数

- **topic**: 调研主题
- **scope**: 调研范围 (brief/deep)
- **category**: 知识分类 (business/data/planning/tech/market)

## 处理流程

1. **信息收集**
   - 网络搜索相关主题
   - 收集相关文档和资料
   - 分析现有知识库相关内容

2. **分析整理**
   - 提炼关键信息
   - 识别知识缺口
   - 生成洞察和建议

3. **存储结果**
   - 原始调研: `docs/knowledge/{category}/raw/research-{topic}.md`
   - 处理后: `docs/knowledge/{category}/processed/`
   - 调研报告: `docs/knowledge/{category}/summaries/`

4. **更新索引和记忆**

## 输出

返回调研报告，包括：
- 主题概述
- 关键发现
- 建议行动项
- 相关知识链接
