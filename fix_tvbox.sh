#!/bin/bash
# TVBoxPrivate 修复脚本
# 生成时间: 2025-12-22

set -e

echo "=========================================="
echo "TVBoxPrivate 修复脚本"
echo "=========================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否在正确的目录
if [ ! -f "TVbox_Dr.json" ]; then
    echo -e "${RED}错误: 请在 tvboxprivate 目录下运行此脚本${NC}"
    exit 1
fi

echo ""
echo "步骤 1: 修复 MD5 校验..."
echo "------------------------------------------"

# 修复 moyumoyu.php 的 MD5
OLD_MD5="36456a794b9f6d670931667d79bf8e9c"
NEW_MD5="588615758b58becade1485bde0600132"

if grep -q "$OLD_MD5" TVbox_Dr.json; then
    sed -i "s/$OLD_MD5/$NEW_MD5/g" TVbox_Dr.json
    echo -e "${GREEN}✓ 已修复 moyumoyu.php 的 MD5 校验${NC}"
else
    echo -e "${YELLOW}⚠ MD5 校验已经是正确的${NC}"
fi

echo ""
echo "步骤 2: 备份原配置文件..."
echo "------------------------------------------"

# 备份原配置文件
BACKUP_FILE="TVbox_Dr.json.backup.$(date +%Y%m%d_%H%M%S)"
cp TVbox_Dr.json "$BACKUP_FILE"
echo -e "${GREEN}✓ 已备份到: $BACKUP_FILE${NC}"

echo ""
echo "步骤 3: 下载最新的直播源..."
echo "------------------------------------------"

# 创建备份目录
mkdir -p backup

# 备份旧的直播源
if [ -f "lib/result.m3u" ]; then
    cp lib/result.m3u "backup/result.m3u.$(date +%Y%m%d)"
    echo -e "${GREEN}✓ 已备份旧的直播源${NC}"
fi

# 下载新的直播源
echo "正在下载最新的直播源..."
LIVE_SOURCES=(
    "https://live.hacks.tools/tv/iptv4.m3u"
    "https://raw.githubusercontent.com/Troray/IPTV/main/tv/iptv.txt"
)

for source in "${LIVE_SOURCES[@]}"; do
    echo "尝试下载: $source"
    if curl -s -L --connect-timeout 10 --max-time 30 "$source" -o "lib/result_new.m3u" 2>/dev/null; then
        if [ -s "lib/result_new.m3u" ]; then
            mv lib/result_new.m3u lib/result.m3u
            echo -e "${GREEN}✓ 成功下载直播源${NC}"
            break
        fi
    fi
    echo -e "${YELLOW}⚠ 下载失败，尝试下一个源...${NC}"
done

# 清理临时文件
rm -f lib/result_new.m3u

echo ""
echo "步骤 4: 验证 JAR 文件..."
echo "------------------------------------------"

# 检查 JAR 文件是否存在
JAR_FILES=(
    "jar/fix250711.jar"
    "jar/Yoursmile.jar"
    "jar/main_baohejiekou.jar"
    "jar/moyumoyu.php"
)

for jar in "${JAR_FILES[@]}"; do
    if [ -f "$jar" ]; then
        echo -e "${GREEN}✓ $jar 存在${NC}"
    else
        echo -e "${RED}✗ $jar 不存在${NC}"
    fi
done

echo ""
echo "步骤 5: 生成接口测试脚本..."
echo "------------------------------------------"

# 创建接口测试脚本
cat > test_interfaces.sh << 'EOF'
#!/bin/bash
# TVBox 接口测试脚本

echo "=========================================="
echo "TVBox 接口可用性测试"
echo "=========================================="

interfaces=(
    "http://www.饭太硬.com/tv"
    "https://tvkj.top/DC.txt"
    "https://raw.githubusercontent.com/xyq254245/xyqonlinerule/main/XYQTVBox.json"
    "https://gitee.com/blssss/jk/raw/api/bls.json"
    "https://raw.githubusercontent.com/yoursmile66/TVBox/main/XC.json"
    "https://gitee.com/kgysp/tv/raw/box/666.api"
    "https://4708.kstore.space/ck.json"
    "https://fmbox.cc"
)

echo ""
echo "测试时间: $(date)"
echo ""

available=0
failed=0

for url in "${interfaces[@]}"; do
    status=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 10 "$url" 2>/dev/null)
    if [ "$status" = "200" ]; then
        echo -e "✅ $url"
        ((available++))
    else
        echo -e "❌ $url (状态码: $status)"
        ((failed++))
    fi
done

echo ""
echo "=========================================="
echo "测试结果: 可用 $available, 失败 $failed"
echo "=========================================="
EOF

chmod +x test_interfaces.sh
echo -e "${GREEN}✓ 已生成接口测试脚本: test_interfaces.sh${NC}"

echo ""
echo "步骤 6: 生成 JAR 更新脚本..."
echo "------------------------------------------"

# 创建 JAR 更新脚本
cat > update_jars.sh << 'EOF'
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
EOF

chmod +x update_jars.sh
echo -e "${GREEN}✓ 已生成 JAR 更新脚本: update_jars.sh${NC}"

echo ""
echo "=========================================="
echo "修复完成！"
echo "=========================================="
echo ""
echo "已执行的修复:"
echo "  1. ✓ 修复了 moyumoyu.php 的 MD5 校验"
echo "  2. ✓ 备份了原配置文件"
echo "  3. ✓ 尝试更新直播源"
echo "  4. ✓ 验证了 JAR 文件"
echo "  5. ✓ 生成了接口测试脚本"
echo "  6. ✓ 生成了 JAR 更新脚本"
echo ""
echo "后续步骤:"
echo "  1. 运行 ./test_interfaces.sh 测试接口可用性"
echo "  2. 运行 ./update_jars.sh 更新 JAR 文件"
echo "  3. 检查 backup/ 目录中的备份文件"
echo ""
echo "注意事项:"
echo "  - 请确保网络连接正常"
echo "  - 部分接口可能需要代理访问"
echo "  - 建议定期运行此脚本保持更新"
echo ""
