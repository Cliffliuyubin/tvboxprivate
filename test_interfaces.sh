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
