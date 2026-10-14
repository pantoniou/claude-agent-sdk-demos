#!/bin/bash
# Make the private home and arena that the demos run fyai in.
#
#   FYAI_BIN      the fyai binary (default: fyai on PATH)
#   FYAI_MODEL    the model of every session (anthropic/claude-haiku-5.5)
#   FYAI_KEY_ENV  the variable that holds its key (ANTHROPIC_API_KEY)
set -eu
T=$(dirname "$(realpath "$0")")
BIN=$(command -v "${FYAI_BIN:-fyai}") || { echo "fyai not found: set FYAI_BIN" >&2; exit 2; }
MODEL=${FYAI_MODEL:-anthropic/claude-haiku-5.5}
KEY_ENV=${FYAI_KEY_ENV:-ANTHROPIC_API_KEY}
mkdir -p "$T/state/home/.config/fyai" "$T/state/work"
printf '%s\n' "$BIN" > "$T/state/fyai-bin"
cd "$T/state/work"
printf 'model: %s\napi_key: {type: env, value: %s}\ndisplay:\n  markdown: false\n' \
	"$MODEL" "$KEY_ENV" > config.yaml
HOME="$T/state/home" XDG_CONFIG_HOME="$T/state/home/.config" \
XDG_STATE_HOME="$T/state/home/.local/state" FYAI_AUTH_STORAGE=file \
	"$BIN" init --force >/dev/null
rm config.yaml
# Every demo directory uses this one arena.
printf 'arena_dir: %s/.fyai/arena\n' "$T/state/work" \
	> "$T/state/home/.config/fyai/config.yaml"
echo "fyai: $BIN, model $MODEL, key in \$$KEY_ENV"
