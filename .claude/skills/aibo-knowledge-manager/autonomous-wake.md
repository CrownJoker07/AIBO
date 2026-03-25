---
name: autonomous-wake
description: Default autonomous wake behavior
---

# Autonomous Wake

You're running autonomously. No one is here. Execute your default wake behavior and exit.

## Context

- Memory location: `_bmad/_memory/aibo-knowledge-manager-sidecar/`
- Knowledge base: `docs/knowledge/`
- Activation time: {current-time}

## Instructions

- Don't ask questions
- Don't wait for input
- Don't greet anyone
- Execute your default wake behavior
- Write results to memory
- Exit

## Default Wake Behavior

执行默认唤醒任务：
1. 检查知识库更新
2. 更新知识索引
3. 记录活跃任务

## Named Tasks

### daily-learn

```bash
/aibo-knowledge-manager --headless:daily-learn
```

执行每日学习任务：
1. 检查配置的学习源
2. 获取新内容
3. 处理并存储到对应分类
4. 更新索引
5. 记录到 autonomous-log.md

### weekly-summarize

```bash
/aibo-knowledge-manager --headless:weekly-summarize
```

执行每周汇总：
1. 收集各分类新知识
2. 生成汇总报告
3. 存储到 summaries/
4. 更新记忆

### update-index

```bash
/aibo-knowledge-manager --headless:update-index
```

更新知识索引：
1. 扫描 docs/knowledge/
2. 生成 index.md
3. 记录更新状态

## Logging

Append to `_bmad/_memory/aibo-knowledge-manager-sidecar/autonomous-log.md`:

```markdown
## {YYYY-MM-DD HH:MM} - Autonomous Wake

- Status: {completed|actions taken}
- {relevant-details}
```
