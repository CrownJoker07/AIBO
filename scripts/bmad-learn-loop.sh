#!/usr/bin/env bash

set -euo pipefail

# ============================================
# BMAD Auto Learning Loop Script
# 自动从配置的学习源获取知识并存储
#
# 使用方式:
#   ./bmad-learn-loop.sh [max_rounds] [filter]
#
# 示例:
#   ./bmad-learn-loop.sh 100              # 学习所有分类
#   ./bmad-learn-loop.sh 100 business     # 只学习 business 分类（固定分类）
#   ./bmad-learn-loop.sh 50 tech          # 只学习 tech 分类（固定分类）
#   ./bmad-learn-loop.sh 100 "留存优化"   # 智能匹配与留存优化相关的源
#   ./bmad-learn-loop.sh 100 "变现策略"   # 智能匹配与变现策略相关的源
# ============================================

OUTPUT_FILE="docs/knowledge/autonomous-log.md"
SOURCES_FILE="scripts/learning-sources.txt"
LEARNED_FILE="docs/knowledge/.learned-urls.txt"
COUNT=0
MAX_ROUNDS=${1:-100}
FILTER_INPUT=${2:-}  # 可选：分类名或自然语言提示词
SLEEP_INTERVAL=${SLEEP_INTERVAL:-5}
MAX_SOURCE_FAILURES=2  # 单个源最大连续失败次数，超过后切换到下一个源

# 失败计数文件（因为 macOS bash 不支持关联数组）
FAILURE_COUNT_FILE=".bmad-source-failures.txt"

# 获取源的失败次数
get_failure_count() {
    local url=$1
    grep "^${url}$" "$FAILURE_COUNT_FILE" 2>/dev/null | cut -d'|' -f2 || echo "0"
}

# 增加源的失败次数
increment_failure() {
    local url=$1
    local count=$(get_failure_count "$url")
    count=$((count + 1))
    # 删除旧记录
    grep -v "^${url}|" "$FAILURE_COUNT_FILE" 2>/dev/null > "${FAILURE_COUNT_FILE}.tmp" 2>/dev/null || true
    mv "${FAILURE_COUNT_FILE}.tmp" "$FAILURE_COUNT_FILE" 2>/dev/null || true
    # 添加新记录
    echo "${url}|${count}" >> "$FAILURE_COUNT_FILE"
}

# 重置源的失败次数
reset_failure() {
    local url=$1
    grep -v "^${url}|" "$FAILURE_COUNT_FILE" 2>/dev/null > "${FAILURE_COUNT_FILE}.tmp" 2>/dev/null || true
    mv "${FAILURE_COUNT_FILE}.tmp" "$FAILURE_COUNT_FILE" 2>/dev/null || true
}

# 初始化失败计数文件
touch "$FAILURE_COUNT_FILE"

# 当前源索引（用于轮询）
CURRENT_SOURCE_INDEX=0

# 智能过滤相关变量
FILTER_TYPE="all"
SMART_SOURCES_FILE=""

# 清理函数
cleanup() {
    [ -n "$SMART_SOURCES_FILE" ] && [ -f "$SMART_SOURCES_FILE" ] && rm -f "$SMART_SOURCES_FILE"
}

trap "cleanup; echo '🛑 Learning loop stopped'; kill 0; exit 0" SIGINT SIGTERM EXIT

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

# 判断是否为固定分类（2026年职能架构）
is_fixed_category() {
    case "$1" in
        产品|运营|商业化|数据|技术|质量|商务|行业) return 0 ;;
        *) return 1 ;;
    esac
}

# AI 判断子文件夹
# 参数: $1 = 内容描述 (description)
# 输出: 子文件夹名称，如果无匹配则返回空
ai_detect_subfolder() {
    local description=$1
    local result

    result=$(claude -p "根据以下内容描述，判断它应该归类到哪个子文件夹。
只返回子文件夹名称，不要其他内容。如果没有合适的返回空。

可用子文件夹：
- 游戏设计（游戏设计、玩法、超休闲）
- 变现（商业化、IAP、广告变现）
- 用户留存（用户留存、生命周期）
- 用户获取（增长、UA、ROAS）
- 数据分析（指标、数据分析）
- AI技术（LLM、人工智能）
- 广告（AdMob）
- 行业动态（市场趋势）
- 开发（工程技术）
- 算法（推荐系统）
- 移动归因（归因）

内容描述: $description

只返回最合适的子文件夹名称，如果没有合适的返回空。" \
        --no-session-persistence \
        --dangerously-skip-permissions \
        --output-format stream-json \
        2>/dev/null | jq -rj 'select(.type == "result") | .result' 2>/dev/null | tr -d '\n' || echo "")

    echo "$result"
}

# 智能过滤学习源
# 参数: $1 = 用户提示词
# 输出: 匹配的源列表（格式: category|url|description|selector|frequency）
smart_filter_sources() {
    local user_prompt=$1

    echo "🧠 正在分析学习源与 \"$user_prompt\" 的相关性..." >&2
    echo "" >&2

    # 1. 读取所有学习源并构建列表
    local sources_list=""
    local index=0
    while IFS='|' read -r category url description selector frequency || [ -n "$category" ]; do
        [[ -z "$category" || "$category" =~ ^[[:space:]]*# ]] && continue

        if [ -n "$sources_list" ]; then
            sources_list="${sources_list}"$'\n'
        fi
        sources_list="${sources_list}${index}|${category}|${url}|${description}"
        index=$((index + 1))
    done < "$SOURCES_FILE"

    # 2. 构建评估 prompt
    local eval_prompt
    eval_prompt="你是一个学习源筛选助手。根据用户的学习需求，从以下学习源中选择最相关的源。

用户学习需求：${user_prompt}

可用学习源列表（格式：索引|分类|URL|描述）：
${sources_list}

子目录分类参考（用于理解内容主题）：
- 变现/ - 变现策略、商业化、IAP、广告变现
- 用户留存/ - 用户留存、生命周期、留存优化
- 用户获取/ - 用户获取、增长、UA、ROAS
- 数据分析/ - 游戏数据分析、指标体系
- 游戏设计/ - 游戏设计、玩法、超休闲
- AI技术/ - AI 技术应用、LLM
- 行业动态/ - 行业动态、市场趋势

请分析每个学习源的描述，判断其与用户需求的相关性。
返回 JSON 格式：
{
  \"matched_indices\": [0, 2, 5],
  \"reasoning\": \"简要说明选择理由\"
}

只返回 JSON，不要其他内容。"

    # 3. 调用 Claude 进行批量评估
    local claude_response
    claude_response=$(claude -p "$eval_prompt" \
        --no-session-persistence \
        --dangerously-skip-permissions \
        --output-format stream-json \
        --verbose \
        2>/dev/null | jq -rj 'select(.type == "result") | .result' 2>/dev/null || echo "")

    # 4. 解析匹配结果
    if [ -z "$claude_response" ]; then
        echo "⚠️ Claude 评估失败，将使用所有源" >&2
        # 降级：返回所有源
        while IFS='|' read -r category url description selector frequency || [ -n "$category" ]; do
            [[ -z "$category" || "$category" =~ ^[[:space:]]*# ]] && continue
            echo "$category|$url|$description|$selector|$frequency"
        done < "$SOURCES_FILE"
        return
    fi

    # 提取 JSON（处理可能的 markdown 代码块）
    local matched_indices
    matched_indices=$(echo "$claude_response" | sed 's/```json//;s/```//g' | jq -r '.matched_indices[]' 2>/dev/null || echo "")

    if [ -z "$matched_indices" ]; then
        echo "⚠️ 解析匹配结果失败，将使用所有源" >&2
        while IFS='|' read -r category url description selector frequency || [ -n "$category" ]; do
            [[ -z "$category" || "$category" =~ ^[[:space:]]*# ]] && continue
            echo "$category|$url|$description|$selector|$frequency"
        done < "$SOURCES_FILE"
        return
    fi

    # 5. 根据匹配索引过滤源
    echo "📋 智能匹配结果：" >&2
    local current_index=0
    while IFS='|' read -r category url description selector frequency || [ -n "$category" ]; do
        [[ -z "$category" || "$category" =~ ^[[:space:]]*# ]] && continue

        if echo "$matched_indices" | grep -q "^${current_index}$"; then
            echo "  ✓ $description" >&2
            echo "$category|$url|$description|$selector|$frequency"
        fi
        current_index=$((current_index + 1))
    done < "$SOURCES_FILE"
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
    # 支持格式: "href*='/news/'" 或 "href*=\"/news/\"" 或 "data-url" 等
    local url_pattern
    url_pattern=$(echo "$selector" | grep -oE "href\*='[^']+'|href\*=\"[^\"]+\"|href='[^']+'|href=\"[^\"]+\"|data-url='[^']+'|data-url=\"[^\"]+\"" | \
        sed -E "s/href\*='([^']+)'/\1/;s/href\*=\"([^\"]+)\"/\1/;s/href='([^']+)'/\1/;s/href=\"([^\"]+)\"/\1/;s/data-url='([^']+)'/\1/;s/data-url=\"([^\"]+)\"/\1/" | head -1 || echo "")

    # 如果没有提取到模式，尝试从选择器中获取路径片段
    if [ -z "$url_pattern" ]; then
        # 从 CSS 选择器中提取路径模式，如 "a[href*='/blog/']" -> "/blog/"
        url_pattern=$(echo "$selector" | grep -oE "'[^']+'|\"[^\"]+\"" | tail -1 | sed "s/['\"]//g" || echo "")
    fi

    # 如果仍然没有模式，尝试从主页 URL 提取默认路径
    if [ -z "$url_pattern" ]; then
        # 从 URL 中提取路径，如 https://gameanalytics.com/blog/ -> /blog/
        url_pattern=$(echo "$homepage_url" | grep -oE '/[^/]+/?$' | sed 's|/.$||' || echo "")
        # 如果 URL 是根路径或提取失败，使用空模式
        [ -z "$url_pattern" ] && url_pattern=""
    fi

    # 提取匹配的链接 - 支持多种 href 格式
    local articles=""
    local raw_links

    echo "🔍 Using URL pattern: $url_pattern" >&2

    # 尝试多种匹配模式
    raw_links=$(echo "$html" | grep -oE "href=\"[^\"]*${url_pattern}[^\"]*\"|href='[^']*${url_pattern}[^']*'" | \
        sed -E 's/href="//;s/href=.//;s/"//g' | \
        sort -u)

    # 如果没有匹配到，尝试回退：提取所有带 href 的链接再过滤
    if [ -z "$raw_links" ] && [ -n "$url_pattern" ] && [ "$url_pattern" != "/" ]; then
        echo "⚠️ Pattern didn't match, trying fallback..." >&2
        raw_links=$(echo "$html" | grep -oE "href=\"[^\"]+\"|href='[^']+'" | \
            sed -E 's/href="//;s/href=.//;s/"//g' | \
            grep -v '^?' | grep -v '^#' | grep -v '^$' | grep -v '^/$' | \
            grep -E "${url_pattern}" | \
            sort -u)
    fi

    articles=$(echo "$raw_links" | head -n "$max_articles")

    # 显示发现的链接数量和样例
    local article_count
    article_count=$(echo "$articles" | grep -c . 2>/dev/null || echo "0")
    echo "🔍 Found $article_count link(s)" >&2
    if [ -n "$articles" ]; then
        echo "🔍 Sample links:" >&2
        echo "$articles" | head -3 | sed 's/^/   /' >&2
    fi

    # 处理相对路径，转换为绝对路径
    local base_url
    base_url=$(echo "$homepage_url" | sed 's|/[^/]*$||')

    # 提取主机部分（不含路径），用于处理绝对路径链接
    local host_url
    host_url=$(echo "$homepage_url" | grep -oE '^https?://[^/]+' || echo "")

    local result=""
    while IFS= read -r article_url; do
        # 跳过空行
        [ -z "$article_url" ] && continue

        # 跳过无效链接（查询参数、锚点、根路径、javascript 等）
        if [[ "$article_url" =~ ^\? ]] || [[ "$article_url" == "#"* ]] || \
           [[ "$article_url" == "/" ]] || [[ "$article_url" =~ ^javascript: ]] || \
           [ -z "$article_url" ]; then
            continue
        fi

        # 转换相对路径为绝对路径
        if [[ "$article_url" == /* ]]; then
            # 去除 article_url 前导的 /，避免与 base_url 路径重复
            article_url="${host_url}${article_url}"
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

# 根据关键词过滤文章
# AI 过滤文章
# 参数: $1 = 文章URL列表(换行分隔), $2 = 关键词
# 输出: 过滤后的文章URL列表
ai_filter_articles() {
    local article_urls=$1
    local keyword=$2

    # 如果没有关键词或关键词为空，不过滤
    [ -z "$keyword" ] && echo "$article_urls" && return

    echo "🔍 AI 正在分析文章与 \"$keyword\" 的相关性..." >&2

    # 将 URL 列表传给 AI，让 AI 批量获取标题并判断相关性
    local result
    result=$(claude -p "任务：判断以下 URL 列表中，哪些文章与主题 '$keyword' 相关。

URL 列表：
$article_urls

请：
1. 访问每个 URL 获取文章标题（最多 5 个）
2. 判断每篇文章是否与主题相关（语义相关性，不只是关键词匹配）
3. 只返回相关文章的 URL（每行一个，不要其他内容）

如果没有相关文章，返回空。" \
        --no-session-persistence \
        --dangerously-skip-permissions \
        --output-format stream-json \
        2>/dev/null | jq -rj 'select(.type == "result") | .result' 2>/dev/null || echo "")

    # 清理输出，只保留 URL（去除可能的 markdown 代码块标记）
    result=$(echo "$result" | sed 's/```json//;s/```//g' | grep -E '^https?://' || echo "")

    if [ -z "$result" ]; then
        echo "⚠️ 没有找到与 \"$keyword\" 相关的文章" >&2
    else
        local count
        count=$(echo "$result" | grep -c . 2>/dev/null || echo "0")
        echo "✅ AI 筛选出 $count 篇相关文章" >&2
    fi

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
    local source_file="${SMART_SOURCES_FILE:-$SOURCES_FILE}"

    while IFS='|' read -r category url description selector frequency || [ -n "$category" ]; do
        # 跳过空行和注释
        [[ -z "$category" || "$category" =~ ^[[:space:]]*# ]] && continue

        # 如果是固定分类过滤模式，只匹配该分类
        if [ "$FILTER_TYPE" = "category" ] && [ "$category" != "$FILTER_INPUT" ]; then
            continue
        fi

        # 智能过滤模式：从原始配置文件读取，返回所有匹配的源
        # 注意：不在这里预检查是否有新文章，由主循环处理
        if [ "$FILTER_TYPE" = "smart" ]; then
            # 从原始配置文件获取该源的完整信息（包含选择器）
            # 格式: 分类|URL|描述|选择器|频率
            while IFS='|' read -r orig_category orig_url orig_description orig_selector orig_frequency || [ -n "$orig_category" ]; do
                [[ -z "$orig_category" || "$orig_category" =~ ^[[:space:]]*# ]] && continue
                if [ "$orig_url" = "$url" ]; then
                    echo "$category|$url|$description|$orig_selector|$frequency"
                    break
                fi
            done < "$SOURCES_FILE"
            continue
        fi

        # 跳过已学习的主页 URL
        if ! is_url_learned "$url"; then
            echo "$category|$url|$description|$selector|$frequency"
        fi
    done < "$source_file"
}

# 判断过滤类型并执行智能过滤
if [ -n "$FILTER_INPUT" ]; then
    if is_fixed_category "$FILTER_INPUT"; then
        FILTER_TYPE="category"
        echo "📚 BMAD Learn Loop Started"
        echo "Output: $OUTPUT_FILE"
        echo "Sources: $SOURCES_FILE"
        echo "Max rounds: $MAX_ROUNDS"
        echo "📂 Category filter: $FILTER_INPUT"
    else
        FILTER_TYPE="smart"
        echo "📚 BMAD Learn Loop Started"
        echo "Output: $OUTPUT_FILE"
        echo "Sources: $SOURCES_FILE"
        echo "Max rounds: $MAX_ROUNDS"
        echo "🧠 Smart filter: \"$FILTER_INPUT\""
        echo ""

        # 执行智能过滤
        SMART_SOURCES_FILE=$(mktemp)
        smart_filter_sources "$FILTER_INPUT" > "$SMART_SOURCES_FILE"

        # 检查是否有匹配
        if [ ! -s "$SMART_SOURCES_FILE" ]; then
            echo ""
            echo "❌ 没有找到与 \"$FILTER_INPUT\" 相关的学习源"
            echo ""
            echo "💡 建议："
            echo "  - 尝试使用更通用的关键词"
            echo "  - 查看可用分类：business, data, planning, tech, market"
            echo "  - 示例提示词：'变现策略'、'用户留存'、'AI技术'"
            exit 0
        fi

        matched_count=$(wc -l < "$SMART_SOURCES_FILE" | tr -d ' ')
        echo ""
        echo "✅ 找到 $matched_count 个相关学习源"
    fi
else
    echo "📚 BMAD Learn Loop Started"
    echo "Output: $OUTPUT_FILE"
    echo "Sources: $SOURCES_FILE"
    echo "Max rounds: $MAX_ROUNDS"
    echo "Filter: all"
fi

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

    # 获取待学习源总数
    TOTAL_SOURCES=$(echo "$PENDING" | grep -c . 2>/dev/null || echo "0")

    # 轮询选择学习源（从当前索引开始，最多尝试所有源一次）
    CURRENT_SOURCE=""
    ATTEMPTED=0
    while [ $ATTEMPTED -lt $TOTAL_SOURCES ]; do
        CURRENT_SOURCE=$(echo "$PENDING" | sed -n "$((CURRENT_SOURCE_INDEX + 1))p")
        URL=$(echo "$CURRENT_SOURCE" | cut -d'|' -f2 2>/dev/null || echo "")

        # 检查当前源是否连续失败过多
        FAIL_COUNT=$(get_failure_count "$URL")
        if [ $FAIL_COUNT -lt $MAX_SOURCE_FAILURES ]; then
            break  # 当前源可以尝试
        fi

        # 当前源失败过多，切换到下一个
        CURRENT_SOURCE_INDEX=$(( (CURRENT_SOURCE_INDEX + 1) % TOTAL_SOURCES ))
        ATTEMPTED=$((ATTEMPTED + 1))
    done

    if [ -z "$CURRENT_SOURCE" ]; then
        echo "⚠️ 所有源都连续失败过多，重置失败计数..."
        # 重置所有失败计数
        > "$FAILURE_COUNT_FILE"
        CURRENT_SOURCE_INDEX=0
        CURRENT_SOURCE=$(echo "$PENDING" | head -1)
    fi

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
        # 增加失败计数
        increment_failure "$URL"
        CURRENT_SOURCE_INDEX=$(( (CURRENT_SOURCE_INDEX + 1) % TOTAL_SOURCES ))
        continue
    fi

    # 智能过滤模式：根据关键词过滤文章
    if [ "$FILTER_TYPE" = "smart" ] && [ -n "$FILTER_INPUT" ]; then
        ARTICLE_URLS=$(ai_filter_articles "$ARTICLE_URLS" "$FILTER_INPUT")
    fi

    # 统计本轮文章数
    ARTICLE_COUNT=$(echo "$ARTICLE_URLS" | wc -l | tr -d ' ')

    # 检查是否有可学习的文章（排除已学习的）
    AVAILABLE_ARTICLES=0
    while IFS= read -r ARTICLE_URL; do
        [ -z "$ARTICLE_URL" ] && continue
        if ! is_url_learned "$ARTICLE_URL"; then
            AVAILABLE_ARTICLES=$((AVAILABLE_ARTICLES + 1))
        fi
    done <<< "$ARTICLE_URLS"

    if [ $AVAILABLE_ARTICLES -eq 0 ]; then
        echo "⚠️ 没有可学习的新文章（全部已学习或过滤掉）"
        # 增加失败计数
        increment_failure "$URL"
        CURRENT_SOURCE_INDEX=$(( (CURRENT_SOURCE_INDEX + 1) % TOTAL_SOURCES ))
        continue
    fi

    echo "📰 Found $ARTICLE_COUNT article(s) to process ($AVAILABLE_ARTICLES 可学习)"

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

        # 智能推断子文件夹
        SUBFOLDER=$(ai_detect_subfolder "$DESCRIPTION")
        if [ -n "$SUBFOLDER" ]; then
            TARGET_DIR="docs/knowledge/$CATEGORY/$SUBFOLDER/"
            echo "📂 检测到子文件夹: $SUBFOLDER"
        else
            TARGET_DIR="docs/knowledge/$CATEGORY/"
        fi

        # 构建学习 prompt
        BMAD_PROMPT="/bmad-agent-autonomous-learner

执行学习任务：
- 分类: $CATEGORY
- 子文件夹: ${SUBFOLDER:-无}
- 来源: $ARTICLE_URL
- 主页: $URL
- 描述: $DESCRIPTION

请使用 Learn 能力从该具体文章 URL 学习知识并存储到 ${TARGET_DIR} 目录。

重要要求：
1. 文档来源字段必须记录完整文章 URL: $ARTICLE_URL
2. 使用当前日期 (2026年) 作为获取日期
3. 如果文章中有原始发布日期，也要记录
4. 学习完成后，将关键洞察沉淀到 ${TARGET_DIR}知识沉淀.md

处理流程：
1. 获取 URL 内容
2. 提取关键知识点
3. 存储到对应分类目录（如果有子文件夹要求，请放到子文件夹中）
4. 沉淀关键洞察到知识沉淀文件
5. 返回学习结果摘要（包含文章标题、知识点沉淀位置、新增知识点数量）"

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
            echo "**知识沉淀**: docs/knowledge/$CATEGORY/知识沉淀.md"
            echo ""
            echo "---"
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

    # 如果有文章被学习，重置失败计数并切换到下一个源
    if [ $ARTICLES_LEARNED -gt 0 ]; then
        echo ""
        echo "✅ Round $COUNT finished: $ARTICLES_LEARNED article(s) learned"
        # 成功后重置该源的失败计数
        reset_failure "$URL"
        # 切换到下一个源
        CURRENT_SOURCE_INDEX=$(( (CURRENT_SOURCE_INDEX + 1) % TOTAL_SOURCES ))
    else
        echo ""
        echo "ℹ️ Round $COUNT: No new articles to learn"
        # 增加失败计数
        increment_failure "$URL"
        # 切换到下一个源
        CURRENT_SOURCE_INDEX=$(( (CURRENT_SOURCE_INDEX + 1) % TOTAL_SOURCES ))
    fi
done

echo ""
echo "🎉 Learning loop completed!"
echo "📄 Log saved to: $OUTPUT_FILE"
echo "📊 Total rounds: $COUNT"

# 显示统计
TOTAL_LEARNED=$(wc -l < "$LEARNED_FILE" | tr -d ' ')
echo "📚 Total sources learned: $TOTAL_LEARNED"
