#!/bin/bash
# Put the shim in place of cli.js of the SDK that a demo installed. The
# original stays as cli.js.claude. Run it again after each npm install.
set -eu
T=$(dirname "$(realpath "$0")")
DEMO=$(realpath "${1:?pass the demo directory}")
SDK="$DEMO/node_modules/@anthropic-ai/claude-agent-sdk"
[ -f "$SDK/cli.js" ] || { echo "no $SDK/cli.js: run npm install first" >&2; exit 2; }
if ! grep -q "fyai" "$SDK/cli.js"; then
	mv "$SDK/cli.js" "$SDK/cli.js.claude"
fi
cp "$T/cli-shim.js" "$SDK/cli.js"
ln -sf "$T/bin/claude" "$SDK/fyai-claude"
echo "the SDK of $(basename "$DEMO") runs fyai"
