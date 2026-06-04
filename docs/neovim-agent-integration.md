# Neovim + Claude Code / Pi Integration Research

Goal: make Neovim feel closer to VS Code-style agent integrations: select code, send it to an agent, keep a live conversation, apply edits, and avoid context friction.

## Existing approaches

### Claude Code

There are community Neovim plugins that integrate with the `claude` / Claude Code CLI. The usual patterns are:

- Open Claude Code in a terminal/tmux pane from Neovim.
- Send visual selection, current file, diagnostics, or prompts to Claude.
- Provide commands/keymaps like `ClaudeCode`, `ClaudeCodeSend`, `ClaudeCodeDiff`, etc.
- Rely on Claude Code CLI to edit files in the current working directory.

Good direction if the primary agent is Claude Code and the desired workflow is terminal-native.

### General Neovim AI plugins

Plugins like CodeCompanion/Avante-style tools provide native chat buffers and selection-aware prompts, but they usually talk directly to providers such as Anthropic/OpenAI rather than to a coding harness. They are good for inline chat but do not necessarily reuse Claude Code/Pi sessions, tools, permissions, or filesystem-editing behavior.

### Pi

Pi is very integration-friendly:

- Interactive terminal mode already supports `@file` references and path completion.
- Print mode can receive one-shot prompts.
- RPC mode exposes a JSONL protocol over stdin/stdout.
- SDK mode allows full custom UIs in Node/TypeScript.
- Extensions can add tools, commands, event handlers, and UI behaviors.

For a Neovim integration, Pi RPC mode is the best fit.

## Best options

### Option 1: Simple tmux/terminal workflow

Use Neovim keymaps to send context to an existing Pi or Claude Code terminal pane.

Pros:
- Very fast to implement.
- Minimal moving parts.
- Keeps the real Pi/Claude Code terminal UI.
- Works well with tmux.

Cons:
- Harder to parse responses.
- No native Neovim chat UI.
- Applying changes still happens through the harness, not an editor-side diff UI.

Potential keymaps:

```text
<leader>as - Send visual selection to agent
<leader>af - Send current file path to agent
<leader>ap - Prompt agent from Neovim input
<leader>ad - Send diagnostics for current buffer
<leader>ar - Ask agent to review current file
```

### Option 2: Neovim plugin wrapping Pi RPC

Build a small Lua plugin that starts `pi --mode rpc` using `vim.fn.jobstart()` and communicates over JSONL.

Features:
- Native Neovim side panel/floating chat.
- Stream assistant output into a buffer.
- Send selected code/current file/current diagnostics.
- Queue steering/follow-up prompts while Pi is working.
- Abort current operation from Neovim.
- Show tool calls/results in the chat buffer.
- Use `:checktime` after Pi edits files so Neovim reloads changed buffers.

Pros:
- Smoothest Pi-specific integration.
- Reuses Pi sessions, tools, models, extensions, skills, and context files.
- Can become very close to VS Code agent UX.

Cons:
- More implementation work.
- Need to handle JSONL framing correctly.
- Need UI decisions for chat buffers, tool output folding, and file reloads.

### Option 3: Node/TypeScript bridge using Pi SDK

Build a dedicated Node process with the Pi SDK, then expose a simple RPC/API to Neovim.

Pros:
- Type-safe Pi integration.
- Easier to use Pi internals than raw JSONL.
- Best for a serious, distributable plugin.

Cons:
- More infrastructure.
- Requires a Node companion process.
- More complex install/update flow.

## Recommended path

Start with Option 1 for immediate productivity, then evolve to Option 2.

### Phase 1: Agent keymaps + tmux/terminal

Add Neovim commands that collect context and copy/send prompts:

- Visual selection to clipboard with a prompt wrapper.
- Current file path relative to cwd.
- Current file content or range.
- Current diagnostics.
- Git diff from `git diff -- <file>`.

This gives a smooth workflow even before building a full RPC client.

### Phase 2: Pi RPC Neovim plugin MVP

Create `lua/plugins/agent.lua` or a small local plugin with:

- `:PiStart` / `:PiStop`
- `:PiChat`
- `:PiPrompt {text}`
- `:PiSendSelection`
- `:PiSendFile`
- `:PiAbort`
- `:PiState`

Under the hood:

```sh
pi --mode rpc
```

Neovim sends:

```json
{"type":"prompt","message":"..."}
{"type":"steer","message":"..."}
{"type":"follow_up","message":"..."}
{"type":"abort"}
{"type":"get_state"}
```

Neovim listens for:

```text
message_update        Stream assistant text
agent_start/end       Update statusline/chat state
tool_execution_*      Show tool activity
queue_update          Show pending messages
extension_ui_request  Optional future dialogs
```

### Phase 3: Better editor ergonomics

Add:

- Floating input prompt.
- Chat side split.
- Telescope picker for prompt templates/skills via `get_commands`.
- Trouble/quickfix integration for diagnostics.
- Gitsigns/diffview integration for reviewing edits.
- Buffer reload after agent edits files:

```lua
vim.cmd("checktime")
```

## Important Pi RPC details

- Pi RPC uses strict JSONL with `\n` framing.
- Do not split on arbitrary Unicode line separators.
- During streaming, prompts must use `streamingBehavior = "steer"` or `"followUp"`.
- Extension UI requests may need responses if Pi extensions call `ctx.ui.select`, `confirm`, `input`, or `editor`.
- Built-in TUI commands are not available over RPC, but extension commands, prompt templates, and skills are available through `prompt` / `get_commands`.

## Initial recommendation

For this repo, the first implementation should be a lightweight Neovim Lua module for Pi RPC, not a Claude-only plugin. It fits the current direction better because Pi exposes a formal RPC protocol and can still use Anthropic/Claude models.

Claude Code integration can remain a parallel terminal/tmux workflow if desired.
