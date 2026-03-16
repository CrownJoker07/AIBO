---
name: save-memory
description: 显式保存当前会话到记忆
menu-code: SM
---

# Save Memory

立即将当前会话上下文保存到记忆系统。

## Process

1. **读取当前 index.md** — 加载现有上下文

2. **更新当前会话:**
   - 正在进行的工作
   - 当前状态/进度
   - 发现的新偏好或模式
   - 继续下一步

3. **写入更新后的 index.md** — 替换为简洁的当前版本

4. **检查点其他文件（如需要）:**
   - `patterns.md` — 添加发现的新模式
   - `chronology.md` — 添加会话摘要（如果重要）

## Output

确认保存并简要总结: "Memory saved. {简要总结更新的内容}"
