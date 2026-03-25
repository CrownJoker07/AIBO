---
name: summarize
description: 按分类生成知识汇总
menu-code: S
---

# Summarize - 生成知识汇总

按指定分类或全部分类生成知识汇总报告。

## 输入参数

- **category**: 可选。要汇总的分类 (产品/运营/商业化/数据/技术/质量/商务/行业/all)
- **period**: 可选。汇总周期 (weekly/monthly/custom)

## 处理流程

1. **收集知识**
   - 如果 category=all: 遍历所有分类
   - 否则只处理指定分类
   - 读取 processed 和 raw 目录内容

2. **生成汇总**
   - 提炼跨类别洞察
   - 识别知识关联
   - 总结趋势和模式

3. **存储汇总**
   - 保存到: `docs/knowledge/{category}/summaries/`
   - 文件命名: `summary-{date}.md`

4. **更新记忆**
   - 记录汇总生成时间和内容

## 输出

返回汇总报告，包括：
- 各分类知识概览
- 关键洞察
- 知识缺口建议
