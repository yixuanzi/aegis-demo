#!/usr/bin/env bash
# 演示前一键准备：检查依赖 → 生成 env/demo.env → 生成演示项目 → 备份 settings.json
# → 彩排自检（核心 + 扩展场景）。任何一步失败都会退出非 0。
#
#   scripts/prepare.sh
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/lib.sh

step() { printf '\n==> %s\n' "$*"; }

step "检查依赖"
for c in git jq node; do
	command -v "$c" >/dev/null && printf '  ok  %s\n' "$c" || { echo "  缺少 $c" >&2; exit 1; }
done
sensor=${AEGIS_SENSOR_BIN:-$(command -v aegis-sensor || true)}
if [ -x "$sensor" ]; then
	printf '  ok  aegis-sensor (%s)\n' "$("$sensor" --version 2>&1 | head -1)"
else
	echo "  缺少 aegis-sensor：请先在演示终端通过「探针安装」页装好探针" >&2
	exit 1
fi

step "环境变量文件"
if [ -f env/demo.env ]; then
	echo "  env/demo.env 已存在，保持不变"
else
	cp env/demo.env.example env/demo.env
	echo "  已生成 env/demo.env，请按实际环境检查"
fi

step "演示项目 $DEMO_PROJECT"
if [ -e "$DEMO_PROJECT" ]; then
	echo "  已存在，跳过（要重建请先删除该目录）"
else
	scripts/setup-demo-project.sh
fi

step "备份 ~/.claude/settings.json"
if [ -f "$HOME/.claude/settings.json" ]; then
	scripts/backup-claude-settings.sh backup
else
	echo "  没有 ~/.claude/settings.json，跳过"
fi

step "彩排自检：核心场景（9 条 finding + deny deny deny allow）"
scripts/replay.sh check

step "彩排自检：扩展场景 B1–B13"
scripts/replay-extended.sh

printf '\n全部通过。接下来按 docs/demo-guide.zh-CN.md「演示前准备」第 6 步起，在控制台里完成预热数据、规则集合、LLM 配置和 MCP。\n'
