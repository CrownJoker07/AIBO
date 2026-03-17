#!/usr/bin/env bash

set -euo pipefail

# ============================================
# BMAD Auto Learning Loop Script
# 自动从配置的学习源获取知识并存储
#
# 使用方式:
#   ./bmad-learn-loop.sh [max_rounds] [category]
#
# 示例:
#   ./bmad-learn-loop.sh 100           # 学习所有分类
#   ./bmad-learn-loop.sh 100 business  # 只学习 business 分类
#   ./bmad-learn-loop.sh 50 tech       # 只学习 tech 分类
# ============================================

OUTPUT_FILE="docs/knowledge/autonomous-log.md"
SOURCES_FILE="scripts/learning-sources.txt"
LEARNED_FILE="docs/knowledge/.learned-urls.txt"
COUNT=0
MAX_ROUNDS=${1:-100}
CATEGORY_FILTER=${2:-}  # 可选：指定分类过滤
SLEEP_INTERVAL=${SLEEP_INTERVAL:-5}

trap "echo '🛑 Learning loop stopped'; kill 0; exit 0" SIGINT SIGTERM

echo "📚 BMAD Learn Loop Started"
echo "Output: $OUTPUT_FILE"
echo "Sources: $SOURCES_FILE"
echo "Max rounds: $MAX_ROUNDS"
echo "Category filter: ${CATEGORY_FILTER:-all}"

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

# 发现具体文章链接
# 参数: homepage_url selector max_articles
discover_articles() {
    local homepage_url=$1
    local selector=$2
    local max_articles=${3:-5}

    # 如果没有选择器，返回主页 URL（直接学习该页面）
    if [ -z "$selector" ]; then
        echo "$homepage_url"
        return
    fi

    echo "🔍 Discovering articles from $homepage_url..." >&2

    # 使用 curl 获取页面 HTML
    local html
    html=$(curl -sL -A "Mozilla/5.0 (compatible; AIBO-Learner/1.0)" \
        --connect-timeout 10 \
        --max-time 30 \
        "$homepage_url" 2>/dev/null)

    if [ -z "$html" ]; then
        echo "⚠️ Failed to fetch page content" >&2
        return
    fi

    # 提取选择器中的 URL 模式
    # 支持格式: "href*='/news/'" 或 "a[href*='/blog/']"
    local url_pattern
    url_pattern=$(echo "$selector" | grep -oE "href\*='[^']+'" | sed "s/href\*='//;s/'//" || echo "")

    # 如果没有提取到模式，尝试从选择器中获取通用链接
    if [ -z "$url_pattern" ]; then
        url_pattern="/"
    fi

    # 提取匹配的链接
    local articles
    articles=$(echo "$html" | grep -oE "href=\"[^\"]*${url_pattern}[^\"]*\"" | \
        sed 's/href="//;s/"//' | \
        sort -u | \
        head -n "$max_articles")

    # 处理相对路径，转换为绝对路径
    local base_url
    base_url=$(echo "$homepage_url" | sed 's|/[^/]*$||')

    local result=""
    while IFS= read -r article_url; do
        # 跳过空行
        [ -z "$article_url" ] && continue

        # 转换相对路径为绝对路径
        if [[ "$article_url" == /* ]]; then
            article_url="${base_url}${article_url}"
        elif [[ "$article_url" != http* ]]; then
            article_url="${base_url}/${article_url}"
        fi

        # 去除 URL 片段
        article_url=$(echo "$article_url" | sed 's/#.*//')

        # 添加到结果
        if [ -n "$result" ]; then
            result="${result}"$'\n'"${article_url}"
        else
            result="$article_url"
        fi
    done <<< "$articles"

    echo "$result"
}

# 自动提交学习结果
git_commit_learning() {
    local category=$1
    local article_url=$2

    # 检查是否在 git 仓库中
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return
    fi

    # 检查是否有变更（包括未跟踪的文件）
    local has_changes=false

    if ! git diff --quiet --exit-code 2>/dev/null; then
        has_changes=true
    fi

    if ! git diff --cached --quiet --exit-code 2>/dev/null; then
        has_changes=true
    fi

    if [ -n "$(git ls-files --others --exclude-standard docs/knowledge/ 2>/dev/null)" ]; then
        has_changes=true
    fi

    if [ "$has_changes" = false ]; then
        echo "📝 No changes to commit"
        return
    fi

    # 提取文章标题（从 URL）
    local article_title
    article_title=$(echo "$article_url" | sed 's|.*/||;s|-| |g;s|\.html||;s|_||g')

    # 添加变更文件
    git add docs/knowledge/

    # 生成提交信息
    local commit_msg
    commit_msg="docs(knowledge): 自动学习 - ${category} - ${article_title}

来源: ${article_url}

Co-Authored-By: AIBO Auto-Learner <aibo@aibo.dev>"

    # 执行提交
    git commit -m "$commit_msg" --no-verify 2>/dev/null
    echo "✅ Git commit created for: $article_url"
}

# 读取学习源并过滤已学习的
# 新格式: 分类|URL|描述|文章选择器|更新频率
get_pending_sources() {
    while IFS='|' read -r category url description selector frequency || [ -n "$category" ]; do
        # 跳过空行和注释
        [[ -z "$category" || "$category" =~ ^[[:space:]]*# ]] && continue

        # 如果指定了分类过滤，只匹配该分类
        if [ -n "$CATEGORY_FILTER" ] && [ "$category" != "$CATEGORY_FILTER" ]; then
            continue
        fi

        # 跳过已学习的主页 URL
        if ! is_url_learned "$url"; then
            echo "$category|$url|$description|$selector|$frequency"
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
    SELECTOR=$(echo "$CURRENT_SOURCE" | cut -d'|' -f4)
    FREQUENCY=$(echo "$CURRENT_SOURCE" | cut -d'|' -f5)

    echo ""
    echo "====================================="
    echo "📖 Learn Round: $COUNT / $MAX_ROUNDS"
    echo "====================================="
    echo "分类: $CATEGORY"
    echo "主页: $URL"
    echo "描述: $DESCRIPTION"
    echo "选择器: ${SELECTOR:-无}"
    echo "频率: ${FREQUENCY:-once}"
    echo ""

    # 发现具体文章
    ARTICLE_URLS=$(discover_articles "$URL" "$SELECTOR" 5)

    if [ -z "$ARTICLE_URLS" ]; then
        echo "⚠️ No articles found, skipping..."
        # 标记主页为已学习，避免重复处理
        mark_url_learned "$URL"
        continue
    fi

    # 统计本轮文章数
    ARTICLE_COUNT=$(echo "$ARTICLE_URLS" | wc -l | tr -d ' ')
    echo "📰 Found $ARTICLE_COUNT article(s) to process"

    # 处理每篇文章
    ARTICLES_LEARNED=0
    while IFS= read -r ARTICLE_URL; do
        # 跳过空行
        [ -z "$ARTICLE_URL" ] && continue

        # 跳过已学习的文章
        if is_url_learned "$ARTICLE_URL"; then
            echo "⏭️ Already learned: $ARTICLE_URL"
            continue
        fi

        echo ""
        echo "---"
        echo "📄 Processing article: $ARTICLE_URL"

        # 构建学习 prompt
        BMAD_PROMPT="/bmad-agent-autonomous-learner

执行学习任务：
- 分类: $CATEGORY
- 来源: $ARTICLE_URL
- 主页: $URL
- 描述: $DESCRIPTION

请使用 Learn 能力从该具体文章 URL 学习知识并存储到 docs/knowledge/$CATEGORY/ 目录。

重要要求：
1. 文档来源字段必须记录完整文章 URL: $ARTICLE_URL
2. 使用当前日期 (2026年) 作为获取日期
3. 如果文章中有原始发布日期，也要记录

处理流程：
1. 获取 URL 内容
2. 提取关键知识点
3. 存储到对应分类目录
4. 返回学习结果摘要（包含文章标题）"

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
            echo "**来源**: $ARTICLE_URL"
            echo "**主页**: $URL"
            echo "**描述**: $DESCRIPTION"
            echo ""
            echo "**学习结果**:"
            echo '```'
            echo "$ROUND_OUTPUT"
            echo '```'
            echo ""
        } >> "$OUTPUT_FILE"

        # 标记文章为已学习
        mark_url_learned "$ARTICLE_URL"
        ARTICLES_LEARNED=$((ARTICLES_LEARNED + 1))

        echo "✅ Article learned: $ARTICLE_URL"

        # 每篇文章学习后自动提交
        git_commit_learning "$CATEGORY" "$ARTICLE_URL"

        sleep "$SLEEP_INTERVAL"
    done <<< "$ARTICLE_URLS"

    # 如果有文章被学习，标记主页为已处理
    if [ $ARTICLES_LEARNED -gt 0 ]; then
        mark_url_learned "$URL"
        echo ""
        echo "✅ Round $COUNT finished: $ARTICLES_LEARNED article(s) learned"
    else
        echo ""
        echo "ℹ️ Round $COUNT: No new articles to learn"
    fi
done

echo ""
echo "🎉 Learning loop completed!"
echo "📄 Log saved to: $OUTPUT_FILE"
echo "📊 Total rounds: $COUNT"

# 显示统计
TOTAL_LEARNED=$(wc -l < "$LEARNED_FILE" | tr -d ' ')
echo "📚 Total sources learned: $TOTAL_LEARNED"
