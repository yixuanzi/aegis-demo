#!/usr/bin/env bash
# 扩展场景 B1–B13 的彩排自检：读取 data/scenarios.json，把每条命令作为
# Claude Code PreToolUse 回调重放给 aegis-sensor（隔离 HOME，不真正执行任何命令），
# 核对预期规则是否命中。绝对路径一律写成 /Users/demo/...（规则只认 /Users/<user>/ 形式）。有缺失则退出 1。
#
#   scripts/replay-extended.sh [SENSOR]
set -euo pipefail
source "$(dirname "$0")/lib.sh"

sensor=${1:-${AEGIS_SENSOR_BIN:-$(command -v aegis-sensor || true)}}
[ -x "$sensor" ] || { echo "aegis-sensor not found; pass its path as the first argument" >&2; exit 2; }
command -v jq >/dev/null || { echo "jq is required" >&2; exit 2; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/home" "$work/machine"
export HOME="$work/home" NUMBAT_MACHINE_DIR="$work/machine"
out="$work/records.ndjson"
session="demo-ext-$(date +%Y%m%d-%H%M%S)"

jq -c '.extended[]' "$DEMO_ROOT/data/scenarios.json" | {
	missing=0
	n=0
	while IFS= read -r row; do
		id=$(jq -r .id <<<"$row")
		name=$(jq -r .name <<<"$row")
		cmd=$(jq -r --arg p "$DEMO_PROJECT" '.command | gsub("{{PROJECT}}"; $p)' <<<"$row")
		n=$((n + 1))
		: >"$out"
		jq -nc --arg s "$session-$id" --arg c "$DEMO_PROJECT" --arg cmd "$cmd" --arg id "toolu_ext$n" \
			'{session_id:$s,cwd:$c,hook_event_name:"PreToolUse",tool_name:"Bash",tool_input:{command:$cmd},tool_use_id:$id}' |
			"$sensor" hook PreToolUse --agent claude --emit all --output file --output-file "$out" >/dev/null
		for rule in $(jq -r '.expect[]' <<<"$row"); do
			if jq -e --arg id "$rule" 'select(.record_type=="finding" and .rule_id==$id)' "$out" >/dev/null 2>&1; then
				printf '  ok       %-4s %-28s %s\n' "$id" "$rule" "$name"
			else
				printf '  MISSING  %-4s %-28s %s\n' "$id" "$rule" "$name" >&2
				missing=1
			fi
		done
	done
	exit $missing
}
