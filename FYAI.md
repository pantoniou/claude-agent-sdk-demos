# Running the demos on fyai

These demos use the Claude Agent SDK. The SDK runs the Claude Code CLI and
drives it with the stream-json protocol. fyai speaks that protocol, so the
demos run on fyai without changes to their code. Only the CLI that the SDK
starts is replaced. The files for that are in `fyai/`.

## What you need

- fyai built from the `devel` branch that has the SDK front end
  (`src/fyai_claude_sdk.c`).
- libfyaml with the fix for JSON escapes (commit `32123a45`, "emitter: write
  a byte that is not UTF-8 as U+FFFD in JSON"). If the installed library is
  older, set `FYAI_LD_LIBRARY_PATH` to the build directory of the fixed
  library: `export FYAI_LD_LIBRARY_PATH=~/work/libfyaml/build`.
- Node.js 20 or later, for the TypeScript demos.
- uv and Python 3.10 or later, for `research-agent`.
- The key of the model, in the environment variable that `setup.sh` names
  (`ANTHROPIC_API_KEY` by default). The SDK also checks for
  `ANTHROPIC_API_KEY`, so set it even when the model is of another provider.

## One time: make the fyai state

```sh
FYAI_BIN=~/work/sandbox/fyai/build/fyai fyai/setup.sh
```

This makes a private home and one arena in `fyai/state/` (ignored by git).
Every demo uses this arena, whatever its directory. Your own `~/.fyai` is not
touched. The variables:

| Variable | Default | What it is |
| --- | --- | --- |
| `FYAI_BIN` | `fyai` on `PATH` | the fyai binary |
| `FYAI_MODEL` | `anthropic/claude-haiku-5.5` | the model of every session |
| `FYAI_KEY_ENV` | `ANTHROPIC_API_KEY` | the variable that holds its key |

The demos name Claude models (`opus`, `sonnet`, `haiku`, `claude-*`).
`fyai/bin/claude` replaces those names with the model of the arena. Another
model name goes to fyai as given.

Look at the sessions with
`HOME=fyai/state/home XDG_CONFIG_HOME=fyai/state/home/.config fyai branch list`.
Each SDK session is a branch `sdk/<session id>`.

## Each TypeScript demo

1. Install its packages. Do not use the lock file: it resolves the packages
   from a registry inside Anthropic (`artifactory.infra.ant.dev`), which gives
   401. Some demos also pin a `zod` that the SDK does not accept as a peer.

   ```sh
   cd <demo>
   npm install --no-package-lock --legacy-peer-deps
   ```

2. Make its SDK run fyai. The script replaces
   `node_modules/@anthropic-ai/claude-agent-sdk/cli.js` with a shim that runs
   `fyai/bin/claude`, and keeps the original as `cli.js.claude`. Do this again
   after each `npm install`.

   ```sh
   ../fyai/install-shim.sh .
   ```

3. Run the demo as its README says, with the key in the environment.

## The chat demo (`simple-chatapp`)

```sh
cd simple-chatapp
npm install --no-package-lock --legacy-peer-deps
../fyai/install-shim.sh .
export ANTHROPIC_API_KEY=...          # or source your providers.env
npm run dev
```

Open http://localhost:5173. The server listens on 3001 (`PORT` changes it)
and the Vite client on 5173. Each chat is one SDK session. The agent runs in
`simple-chatapp/` itself, because the demo gives no `cwd`. It may use `Bash`,
`Read` and `Write`, which the demo allows. Web search is on, because the demo
allows `WebSearch`.

## The Python demo (`research-agent`)

The SDK from PyPI bundles a Claude Code CLI and runs it before it looks at
`PATH`. Install the SDK from its source repository, which bundles none, and
put `fyai/bin` first on `PATH`:

```sh
cd research-agent
uv venv && uv pip install -e .
uv pip install --reinstall \
    "claude-agent-sdk @ git+https://github.com/anthropics/claude-agent-sdk-python"
PATH="$PWD/../fyai/bin:$PATH" .venv/bin/python -m research_agent.agent
```

## Status

| Demo | SDK | Status |
| --- | --- | --- |
| `hello-world` | TS 0.1.14 | Runs. |
| `simple-chatapp` | TS 0.1.77 | Runs: a chat that calls `Bash` gets its answer over the WebSocket. |
| `research-agent` | Python | Starts and delegates to the researcher sub-agent. The researcher repeated its web searches until the run was stopped. Not working yet. |
| `hello-world-v2` | TS 0.1.59 | Not tried. It uses the `unstable_v2_*` session API. |
| `resume-generator` | TS 0.1.59 | Not tried. |
| `email-agent` | TS 0.1.28 | Not tried. It needs bun and an IMAP account, and uses an SDK MCP server. |
| `excel-demo` | TS 0.1.25 | Not tried. It is an Electron desktop application. |
| `ask-user-question-previews` | TS 0.2.69 | Does not run: fyai has no `plan` permission mode and no `AskUserQuestion` tool. |

## What fyai does not do

fyai writes no files under `~/.claude` and reads none. Settings files,
`.claude/agents/*.md`, transcript files and session stores of Claude Code do
not apply. `setting_sources` has no effect. Extended thinking is not
supported yet. `doc/claude-sdk-compat.md` in fyai describes what the SDK
front end supports.
