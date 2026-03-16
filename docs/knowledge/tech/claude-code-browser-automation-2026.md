# Claude Code 浏览器自动化方案对比（2026）

> 来源: https://www.heyuan110.com/zh/posts/ai/2026-01-28-claude-code-browser-automation/
> 作者: Bruce
> 日期: 2026-01-28

## 概述

本文对比了 5 套 Claude Code 浏览器自动化方案，帮助开发者根据场景选择最合适的工具。

## 五大方案对比

| 方案 | 开发者 | Token消耗 | 浏览器支持 | 核心优势 |
|------|--------|-----------|------------|----------|
| Browser-use | Browser-use团队 | 极低 | Chromium/真实Chrome/云端 | 多模式+会话持久+云端并行 |
| Agent Browser | Vercel Labs | 极低(减少93%) | Chromium | 快、省Token |
| Playwright CLI | Microsoft | 极低(减少75-99%) | Chrome/Firefox/WebKit | 省Token+跨浏览器 |
| Playwright MCP | Microsoft | 较高 | Chrome/Firefox/WebKit | 稳定、功能全 |
| DevTools MCP | Google | 中等 | 仅Chrome | 调试能力强 |

---

## 方案详解

### 1. Browser-use（AI Agent全能王）

**定位**: 专为AI Agent打造的浏览器自动化框架

**三种浏览器模式**:
```bash
# 隔离模式：快速、干净
browser-use -b chromium open https://example.com

# 真实浏览器：使用真实Chrome Profile
browser-use -b real --profile "Default" open https://example.com

# 云端浏览器：不占本地资源
browser-use -b remote open https://example.com
```

**核心机制**: State + Index（精简页面状态+索引操作）

**云端并行能力**:
```bash
# 同时启动多个任务
browser-use -b remote run "检查竞品A的定价" --session task-a
browser-use -b remote run "检查竞品B的定价" --session task-b
```

**适用场景**: 需要登录态、批量并行数据采集、反爬绕过

---

### 2. Agent Browser（轻骑兵）

**定位**: AI Agent专用轻量工具

**核心机制**: Snapshot + Refs
```
- button "登录" [ref=e1]
- input "用户名" [ref=e2]
- input "密码" [ref=e3]
```

**Token对比**:
- 打开中等复杂网页: ~15,000 tokens → ~1,000 tokens
- 填写表单: ~8,000 tokens → ~500 tokens
- 执行10步操作: ~100,000 tokens → ~7,000 tokens

**安装**:
```bash
npm install -g agent-browser
agent-browser install
agent-browser open https://example.com
```

---

### 3. Playwright CLI（特种部队）

**定位**: 2026年微软推荐的Token高效方案

**核心机制**: 数据存磁盘，不存上下文

**实测Token对比**:
- 单个页面快照: ~15,000 → ~200 tokens（节省98.7%）
- 10步操作: ~114,000 → ~27,000 tokens（节省76.3%）
- 含截图流程: ~150,000 → ~5,000 tokens（节省96.7%）

**工作流示例**:
```bash
playwright-cli open https://example.com --headed
playwright-cli snapshot
# 快照保存为YAML文件，每个元素有引用ID（如e8, e21）

playwright-cli fill e8 "test@example.com"
playwright-cli click e15
playwright-cli screenshot
```

**50+命令覆盖**: 导航、交互、快照、截图、状态、调试、会话

**安装**:
```bash
npm install -g @playwright/cli@latest
playwright-cli install
```

---

### 4. Playwright MCP（重装步兵）

**定位**: 通用浏览器自动化

**核心机制**: Accessibility Tree（可访问性树）

**优势**:
- 跨浏览器支持（Chromium/Firefox/WebKit）
- 自动等待、网络拦截、多标签页管理、视频录制

**配置**:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-server-playwright"]
    }
  }
}
```

---

### 5. DevTools MCP（侦察兵）

**定位**: Chrome调试协议封装

**核心机制**: Chrome DevTools Protocol (CDP)

**独特优势**: 调试能力无敌，可访问Console、Network、DOM、性能指标

**适用场景**: 查看Console报错、网络请求调试、性能分析、CSS/DOM检查

---

## 实战选择指南

| 场景 | 推荐方案 |
|------|----------|
| 快速浏览、截图、简单操作 | Agent Browser |
| 带登录态/并行采集/反爬绕过 | Browser-use |
| 测试和自动化（有Shell权限） | Playwright CLI |
| 沙盒环境中做浏览器自动化 | Playwright MCP |
| 调试排错、查看网络请求 | DevTools MCP |

## 总结口诀

- **看看、填表** → Agent Browser
- **登录态、并行、反爬** → Browser-use
- **测试、跑流程**（有Shell） → Playwright CLI
- **测试、跑流程**（沙盒） → Playwright MCP
- **调试、抓请求** → DevTools MCP

**2026年建议**:
- 首选 Browser-use（最全面）
- 侧重编程测试选 Playwright CLI
- 日常浏览体验加 Agent Browser
