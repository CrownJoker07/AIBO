---
name: index
description: 维护全局知识索引
menu-code: I
---

# Index - 维护知识索引

生成或更新知识库的全局索引。

## 处理流程

1. **扫描目录**
   - 遍历 `docs/knowledge/` 下所有分类
   - 统计各分类文件数量

2. **生成索引**
   - 按分类组织文件列表
   - 生成简要描述

3. **写入索引**
   - 更新 `docs/knowledge/index.md`
   - 使用 bmad-index-docs 确保格式规范

## 输出

返回索引更新结果：
- 各分类文件统计
- 最新更新的文件
- 索引位置
