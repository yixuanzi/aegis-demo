#!/usr/bin/env bash
# A6 演示前备份 / 演示后恢复 ~/.claude/settings.json。
#   scripts/backup-claude-settings.sh backup|restore
set -euo pipefail
source "$(dirname "$0")/lib.sh"
src="$HOME/.claude/settings.json"
dst="$DEMO_ROOT/backup/claude-settings.json"
case ${1:-} in
backup)
	[ -f "$src" ] || { echo "$src not found" >&2; exit 1; }
	mkdir -p "$DEMO_ROOT/backup"
	cp -p "$src" "$dst"
	echo "backed up $src -> $dst"
	;;
restore)
	[ -f "$dst" ] || { echo "no backup at $dst" >&2; exit 1; }
	cp -p "$dst" "$src"
	echo "restored $src from $dst"
	;;
*)
	echo "usage: $0 backup|restore" >&2
	exit 2
	;;
esac
