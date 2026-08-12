#!/usr/bin/env bash
# Portable node_repl launcher: expand home without hardcoding /Users/<name>.
set -euo pipefail
CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"
export CODEX_HOME
export SKY_CUA_SERVICE_PATH="${SKY_CUA_SERVICE_PATH:-${CODEX_HOME}/computer-use/Codex Computer Use.app}"
export NODE_REPL_TRUSTED_CODE_PATHS="${NODE_REPL_TRUSTED_CODE_PATHS:-${CODEX_HOME}:/Applications/ChatGPT.app/Contents/Resources/cua_node/lib/node_modules}"
exec /Applications/ChatGPT.app/Contents/Resources/cua_node/bin/node_repl "$@"
