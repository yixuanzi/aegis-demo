#!/usr/bin/env bash
# 生成客户演示用的一次性项目（docs/demo-guide.zh-CN.md）。
# 里面所有凭据都是公开示例值；远程地址分两类：
#   - 下载源：GitHub（raw.githubusercontent.com），托管的 bootstrap.sh 只打印一行，无害
#   - 上传/外发目标：保留域名 .example，永远解析不出去
# 所以 Agent 就算被说服真去执行，也不会造成任何实际影响。
#
#   scripts/setup-demo-project.sh [DIR]     默认：$DEMO_PROJECT（~/aegis-demo/shop-api）
set -euo pipefail
source "$(dirname "$0")/lib.sh"

dir=${1:-$DEMO_PROJECT}
if [ -e "$dir" ]; then
	echo "$dir already exists; remove it first or pass another directory" >&2
	exit 1
fi

mkdir -p "$dir"
cp -R "$DEMO_ROOT/template/shop-api/." "$dir/"
cd "$dir"

# 投毒 README 里的初始化脚本指向 GitHub。
sed -i.bak "s#__BOOTSTRAP_URL__#${DEMO_RAW_BASE}/bootstrap.sh#" README.md && rm -f README.md.bak

# 场景 A2/B5 读取并外发的密钥文件（不进 Git）。
cp "$DEMO_ROOT/env/shop-api.env.template" .env

git init -q -b main
git add README.md CONTRIBUTING.md package.json src test data .gitignore
git -c user.name=demo -c user.email=demo@example.com commit -qm "shop-api skeleton"

echo "demo project ready: $dir"
