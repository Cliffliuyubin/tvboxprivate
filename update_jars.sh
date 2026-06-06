#!/bin/bash
# TVBox JAR 文件更新脚本

echo "=========================================="
echo "TVBox JAR 文件更新"
echo "=========================================="

# 创建备份目录
mkdir -p backup

# 备份现有的 JAR 文件
echo "备份现有的 JAR 文件..."
for jar in jar/*.jar jar/*.php; do
    if [ -f "$jar" ]; then
        cp "$jar" "backup/$(basename $jar).$(date +%Y%m%d)"
    fi
done

echo ""
echo "下载最新的 JAR 文件..."
echo ""

# GitHub 项目列表
GITHUB_REPOS=(
    "liu673cn/box"
    "xiaohucode"
    "UndCover/PyramidStore"
)

for repo in "${GITHUB_REPOS[@]}"; do
    echo "尝试从 $repo 获取..."
    
    # 获取最新的 release
    latest_release=$(curl -s "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null | grep -o '"browser_download_url": "[^"]*\.jar"' | head -1 | cut -d'"' -f4)
    
    if [ -n "$latest_release" ]; then
        echo "下载: $latest_release"
        if curl -s -L --connect-timeout 10 --max-time 60 "$latest_release" -o "jar/spider_new.jar" 2>/dev/null; then
            if [ -s "jar/spider_new.jar" ]; then
                mv jar/spider_new.jar jar/fix250711.jar
                echo -e "\033[0;32m✓ 成功更新 JAR 文件\033[0m"
                break
            fi
        fi
    fi
    echo -e "\033[1;33m⚠ 从 $repo 获取失败\033[0m"
done

# 清理临时文件
rm -f jar/spider_new.jar

echo ""
echo "=========================================="
echo "JAR 文件更新完成"
echo "=========================================="
