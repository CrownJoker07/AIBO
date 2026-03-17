#!/usr/bin/env bash

set -euo pipefail

# ============================================
# BMAD Auto Learning Loop Script
# 自动从配置的学习源获取知识并存储
# ============================================

OUTPUT_FILE="docs/knowledge/autonomous-log.md"
SOURCES_FILE="scripts/learning-sources.txt"
LEARNED_FILE="docs/knowledge/.learned-urls.txt"
COUNT=0
MAX_ROUNDS=${1:-100}
SLEEP_INTERVAL=${SLEEP_INTERVAL:-5}

trap "echo '🛑 Learning loop stopped'; kill 0; exit 0" SIGINT SIGTERM

echo "📚 BMAD Learn Loop Started"
echo "Output: $OUTPUT_FILE"
echo "Sources: $SOURCES_FILE"
echo "Max rounds: $MAX_ROUNDS"

# 检查依赖
if ! command -v jq >/dev/null 2>&1; then
    echo "❌ Missing dependency: jq"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Install jq first, e.g. on macOS: brew install jq"
    else
        echo "Install jq first, e.g. on Linux: sudo apt-get install jq"
    fi
    exit 1
fi

# 检查学习源配置文件
if [ ! -f "$SOURCES_FILE" ]; then
    echo "❌ Missing sources file: $SOURCES_FILE"
    echo "Please create it with format: category|url|description"
    exit 1
fi

# 创建输出目录
mkdir -p "$(dirname "$OUTPUT_FILE")"
mkdir -p "$(dirname "$LEARNED_FILE")"

# 初始化输出文件（仅当文件不存在时）
if [ ! -f "$OUTPUT_FILE" ]; then
    cat > "$OUTPUT_FILE" <<'HEADER'
# 自动学习日志

> 由 bmad-learn-loop.sh 自动生成

---
最后更新：__TIMESTAMP__

---

HEADER
    # 替换时间戳占位符
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/__TIMESTAMP__/$(date '+%Y-%m-%d %H:%M:%S')/" "$OUTPUT_FILE"
    else
        sed -i "s/__TIMESTAMP__/$(date '+%Y-%m-%d %H:%M:%S')/" "$OUTPUT_FILE"
    fi
fi

# 初始化已学习 URL 列表
touch "$LEARNED_FILE"

# 读取已学习的 URL
read_learned_urls() {
    cat "$LEARNED_FILE" 2>/dev/null || echo ""
}

# 标记 URL 为已学习
mark_url_learned() {
    echo "$1" >> "$LEARNED_FILE"
}

# 检查 URL 是否已学习
is_url_learned() {
    grep -qF "$1" "$LEARNED_FILE" 2>/dev/null
}

# 读取学习源并过滤已学习的
get_pending_sources() {
    local learned_urls=$(read_learned_urls)
    while IFS='|' read -r category url description || [ -n "$category" ]; do
        # 跳过空行和注释
        [[ -z "$category" || "$category" =~ ^[[:space:]]*# ]] && continue
        # 跳过已学习的
        if ! is_url_learned "$url"; then
            echo "$category|$url|$description"
        fi
    done < "$SOURCES_FILE"
}

# 主循环
while [ $COUNT -lt $MAX_ROUNDS ]
do
    COUNT=$((COUNT+1))

    # 获取待学习源
    PENDING=$(get_pending_sources)

    if [ -z "$PENDING" ]; then
        echo ""
        echo "✅ All sources have been learned!"
        echo "Add more sources to $SOURCES_FILE or clear $LEARNED_FILE to re-learn"
        break
    fi

    # 选择本轮学习源（轮询方式）
    CURRENT_SOURCE=$(echo "$PENDING" | head -1)
    CATEGORY=$(echo "$CURRENT_SOURCE" | cut -d'|' -f1)
    URL=$(echo "$CURRENT_SOURCE" | cut -d'|' -f2)
    DESCRIPTION=$(echo "$CURRENT_SOURCE" | cut -d'|' -f3)

    echo ""
    echo "====================================="
    echo "📖 Learn Round: $COUNT / $MAX_ROUNDS"
    echo "====================================="
    echo "分类: $CATEGORY"
    echo "来源: $URL"
    echo "描述: $DESCRIPTION"
    echo ""

    # 构建学习 prompt
    BMAD_PROMPT="/bmad-agent-autonomous-learner

执行学习任务：
- 分类: $CATEGORY
- 来源: $URL
- 描述: $DESCRIPTION

请使用 Learn 能力从该 URL 学习知识并存储到 docs/knowledge/$CATEGORY/ 目录。

处理流程：
1. 获取 URL 内容
2. 提取关键知识点
3. 存储到对应分类目录
4. 返回学习结果摘要"

    # 调用 Claude 执行学习
    ROUND_OUTPUT=$(claude -p "$BMAD_PROMPT" \
        --no-session-persistence \
        --dangerously-skip-permissions \
        --output-format stream-json \
        --verbose \
        --include-partial-messages \
        | jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text' 2>/dev/null || echo "")

    if [ -z "$ROUND_OUTPUT" ]; then
        echo "⚠️ No output from Claude, skipping..."
        continue
    fi

    # 更新最后时间戳
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/最后更新：.*/最后更新：$(date '+%Y-%m-%d %H:%M:%S')/" "$OUTPUT_FILE"
    else
        sed -i "s/最后更新：.*/最后更新：$(date '+%Y-%m-%d %H:%M:%S')/" "$OUTPUT_FILE"
    fi

    # 追加到日志
    {
        echo "### 轮次 $COUNT - $CATEGORY"
        echo ""
        echo "**来源**: $URL"
        echo "**描述**: $DESCRIPTION"
        echo ""
        echo "**学习结果**:"
        echo '```'
        echo "$ROUND_OUTPUT"
        echo '```'
        echo ""
    } >> "$OUTPUT_FILE"

    # 标记为已学习
    mark_url_learned "$URL"

    echo "✅ Round $COUNT finished"
    echo "📄 Learned: $URL"

    sleep "$SLEEP_INTERVAL"
done

echo ""
echo "🎉 Learning loop completed!"
echo "📄 Log saved to: $OUTPUT_FILE"
echo "📊 Total rounds: $COUNT"

# 显示统计
TOTAL_LEARNED=$(wc -l < "$LEARNED_FILE" | tr -d ' ')
echo "📚 Total sources learned: $TOTAL_LEARNED"
