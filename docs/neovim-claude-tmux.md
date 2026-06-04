# Neovim + Claude Code tmux Integration

This repo includes a lightweight Neovim integration for sending editor context to a Claude Code pane running inside tmux.

The goal is to keep the workflow terminal-native while making Neovim feel closer to a VS Code-style agent workflow: select code, write a custom prompt, and send rich context to the coding agent.

## Files

```text
config/nvim/lua/config/agent_tmux.lua  Integration module
config/nvim/lua/config/keymaps.lua     Keymaps that call the module
```

## Requirements

- Neovim
- tmux
- Claude Code running in a tmux pane
- Neovim running inside the same tmux session

## How target pane detection works

The integration sends prompts to a tmux pane.

Target selection order:

1. If `vim.g.claude_tmux_target` is already set, use that pane.
2. Otherwise scan panes in the current tmux session with:

   ```sh
   tmux list-panes -a
   ```

3. If exactly one pane looks like Claude Code, use it automatically.
4. If multiple Claude-like panes are found, ask you to choose one.
5. If none are found, fallback to the previous tmux pane: `!`.

Because it uses `tmux list-panes -a`, it can find Claude Code in another window of the same tmux session, not only in the same window.

## Commands

```vim
:ClaudeSendSelection     Send visual selection to Claude Code
:ClaudeSendFile          Send current file to Claude Code
:ClaudeSendDiagnostics   Send current buffer diagnostics to Claude Code
:ClaudePickTarget        Pick the Claude Code tmux target pane
:ClaudeClearTarget       Clear the stored target pane
```

## Keymaps

```text
visual <leader>ac  Send selected code to Claude Code
normal <leader>af  Send current file to Claude Code
normal <leader>ad  Send current buffer diagnostics to Claude Code
normal <leader>ap  Pick Claude Code tmux target pane
```

## Prompt composer

Before sending context, Neovim opens a floating prompt composer.

This composer supports multiline prompts, so you can write detailed instructions like:

```text
Refactor this code to reduce duplication.
Keep the public API unchanged.
Explain the tradeoffs before suggesting changes.
```

Controls:

```text
<C-s>  Send prompt
Enter  Newline while in insert mode
q      Cancel from normal mode
Esc    Cancel from normal mode
<C-c>  Cancel from insert mode
```

## Workflows

### Send selected code

1. Visually select code in Neovim.
2. Press:

   ```text
   <leader>ac
   ```

3. Write a prompt in the floating composer.
4. Press `<C-s>`.

Claude receives:

```text
Your custom prompt

File: path/to/file
Lines: 10-25
Filetype: lua

```lua
selected code
```
```

### Send current file

Press:

```text
<leader>af
```

Claude receives your custom prompt plus the full current file, including file path, line range, and filetype.

### Send diagnostics

Press:

```text
<leader>ad
```

Claude receives your custom prompt plus current buffer diagnostics, including:

- severity
- file path
- line and column
- diagnostic source
- diagnostic code, when available
- diagnostic message

This is useful for prompts like:

```text
Help me fix these diagnostics with the smallest safe change.
```

## Recommended tmux setup

A simple setup:

```text
Window 1 / Pane 1: Neovim
Window 1 / Pane 2: Claude Code
```

But this also works if Claude Code is in another window in the same tmux session.

If auto-detection is not enough, manually pick the pane:

```vim
:ClaudePickTarget
```

or press:

```text
<leader>ap
```

## Notes

- This integration sends text to Claude Code by using `tmux load-buffer`, `tmux paste-buffer`, and `tmux send-keys Enter`.
- It submits automatically after pasting.
- It currently targets Claude Code, but the design could be generalized later for other agents.

## Future ideas

Potential improvements for later iterations:

### Send git diff

Add commands/keymaps for:

```text
Send current file diff
Send whole repo diff
Send staged diff
```

Useful for:

- code review
- commit message generation
- regression detection

### Send current function or symbol

Use Treesitter or LSP to detect the current function/class/symbol and send only that block.

Potential keymap:

```text
<leader>as  Send current symbol
```

### Prompt templates

Add reusable prompts such as:

```text
/review
/refactor
/explain
/fix-diagnostics
/write-tests
/commit-message
```

Could be implemented as a picker or as text expansion inside the prompt composer.

### Paste without auto-submit

Add a variant that pastes into Claude Code but does not press Enter, allowing manual edits before submitting.

Possible keymap:

```text
<leader>aC  Paste selection without submitting
```

### Accumulated context bundle

Allow adding multiple snippets/files/diagnostics to a temporary context bundle before sending one final prompt.

Possible workflow:

```text
<leader>aa  Add selection to bundle
<leader>ab  Send bundle to Claude
<leader>aB  Clear bundle
```

### Target status indicator

Show the active Claude target pane in:

- notifications
- lualine
- a small command output

Potential command:

```vim
:ClaudeTarget
```

### Better pane picker UI

Use Telescope for tmux pane picking instead of the default `vim.ui.select`.

This could show searchable pane metadata:

```text
%12  session:2.1  window=agent  command=claude  path=/repo
```

### Claude/Pi abstraction

Generalize the module from Claude-specific names to agent-generic names:

```vim
:AgentSendSelection
:AgentSendFile
:AgentSendDiagnostics
:AgentPickTarget
```

Then support:

- Claude Code through tmux
- Pi through tmux
- Pi through RPC

### Pi RPC integration

Build a richer Neovim-native client for:

```sh
pi --mode rpc
```

This could support:

- native chat buffer
- streaming assistant output
- steering/follow-up prompts
- abort from Neovim
- tool call rendering
- automatic `:checktime` after file edits
