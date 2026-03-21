#!/bin/bash
# ============================================
# AIBO Knowledge Search Script
# 知识库搜索脚本
# ============================================
#
# 用法:
#   ./search-knowledge.sh [options] [keywords]
#
# 示例:
#   ./search-knowledge.sh 留存
#   ./search-knowledge.sh -c 商业化 变现
#   ./search-knowledge.sh -f "*.md" eCPM
#
# ============================================

set -e

KNOWLEDGE_DIR="docs/knowledge"
DEFAULT_COLOR='\033[0m'
GREEN_COLOR='\033[0;32m'
YELLOW_COLOR='\033[0;33m'
BLUE_COLOR='\033[0;34m'
CYAN_COLOR='\033[0;36m'

# 默认设置
SEARCH_CATEGORY=""
SEARCH_EXTENSIONS="*.md"
SHOW_LINES=3
USE_REGEX=false

usage() {
    echo "AIBO 知识库搜索"
    echo ""
    echo "用法: $0 [选项] 关键词..."
    echo ""
    echo "选项:"
    echo "  -c, --category <分类>    指定分类 (产品|运营|商业化|数据|技术|质量|商务|行业)"
    echo "  -f, --file <pattern>    文件模式 (默认: *.md)"
    echo "  -n, --lines <num>       显示匹配行的上下文行数 (默认: 3)"
    echo "  -r, --regex             使用正则表达式匹配"
    echo "  -h, --help              显示帮助"
    echo ""
    echo "示例:"
    echo "  $0 留存"
    echo "  $0 -c 商业化 变现 eCPM"
    echo "  $0 -r \"(D[0-9]|ROAS)\""
    exit 1
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--category)
            SEARCH_CATEGORY="$2"
            shift 2
            ;;
        -f|--file)
            SEARCH_EXTENSIONS="$2"
            shift 2
            ;;
        -n|--lines)
            SHOW_LINES="$2"
            shift 2
            ;;
        -r|--regex)
            USE_REGEX=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            KEYWORDS+=("$1")
            shift
            ;;
    esac
done

if [ ${#KEYWORDS[@]} -eq 0 ]; then
    echo "错误: 请提供搜索关键词"
    usage
fi

# 确定搜索目录
if [ -n "$SEARCH_CATEGORY" ]; then
    SEARCH_DIR="$KNOWLEDGE_DIR/$SEARCH_CATEGORY"
    if [ ! -d "$SEARCH_DIR" ]; then
        echo "错误: 分类目录不存在: $SEARCH_DIR"
        exit 1
    fi
else
    SEARCH_DIR="$KNOWLEDGE_DIR"
fi

# 构建搜索关键词
SEARCH_PATTERN="${KEYWORDS[*]}"

echo -e "${CYAN_COLOR}========================================${DEFAULT_COLOR}"
echo -e "${CYAN_COLOR}  AIBO 知识库搜索${DEFAULT_COLOR}"
echo -e "${CYAN_COLOR}========================================${DEFAULT_COLOR}"
echo -e "${BLUE_COLOR}搜索目录:${DEFAULT_COLOR} $SEARCH_DIR"
echo -e "${BLUE_COLOR}关键词:${DEFAULT_COLOR} ${KEYWORDS[*]}"
echo -e "${BLUE_COLOR}模式:${DEFAULT_COLOR} $([ "$USE_REGEX" = true ] && echo "正则表达式" || echo "精确匹配")"
echo ""

# 执行搜索
if [ "$USE_REGEX" = true ]; then
    # 正则表达式搜索
    RESULTS=$(grep -rn --include="$SEARCH_EXTENSIONS" -e "$SEARCH_PATTERN" "$SEARCH_DIR" 2>/dev/null || true)
else
    # 关键词搜索 (不区分大小写)
    RESULTS=$(grep -rn --include="$SEARCH_EXTENSIONS" -i -e "$SEARCH_PATTERN" "$SEARCH_DIR" 2>/dev/null || true)
fi

if [ -z "$RESULTS" ]; then
    echo -e "${YELLOW_COLOR}未找到匹配结果${DEFAULT_COLOR}"
    exit 0
fi

# 统计结果
TOTAL_MATCHES=$(echo "$RESULTS" | wc -l)
UNIQUE_FILES=$(echo "$RESULTS" | cut -d: -f1 | sort -u | wc -l)

echo -e "${GREEN_COLOR}找到 $TOTAL_MATCHES 个匹配，涉及 $UNIQUE_FILES 个文件${DEFAULT_COLOR}"
echo ""

# 按文件分组显示结果
echo "$RESULTS" | while IFS=: read -r file line content; do
    RELATIVE_PATH="${file#$KNOWLEDGE_DIR/}"

    # 显示文件头
    echo -e "${GREEN_COLOR}▶ $RELATIVE_PATH:$line${DEFAULT_COLOR}"

    # 显示匹配内容（高亮关键词）
    echo "$content" | sed "s/.*\(${KEYWORDS[0]}\).*/\0/i" | grep -i --color=always "${KEYWORDS[0]}"
    echo ""
done

echo ""
echo -e "${CYAN_COLOR}========================================${DEFAULT_COLOR}"
echo -e "${CYAN_COLOR}  搜索完成${DEFAULT_COLOR}"
echo -e "${CYAN_COLOR}========================================${DEFAULT_COLOR}"
