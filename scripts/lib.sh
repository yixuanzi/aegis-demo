# shellcheck shell=bash
# 公共加载：读取 env/demo.env（没有就用 env/demo.env.example 的默认值）。
# 用法：source "$(dirname "$0")/lib.sh"
DEMO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
if [ -f "$DEMO_ROOT/env/demo.env" ]; then
	# shellcheck disable=SC1091
	. "$DEMO_ROOT/env/demo.env"
else
	# shellcheck disable=SC1091
	. "$DEMO_ROOT/env/demo.env.example"
fi
