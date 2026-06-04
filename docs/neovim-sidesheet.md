# Neovim Sidesheet

## Table of Contents
- [Introduction](#introduction)
- [Basic Navigation](#basic-navigation)
  - [Cursor Movement](#cursor-movement)
  - [Text Scrolling](#text-scrolling)
  - [Jumping Around](#jumping-around)
- [Editing Basics](#editing-basics)
  - [Insert Mode](#insert-mode)
  - [Deleting Text](#deleting-text)
  - [Copying and Pasting](#copying-and-pasting)
  - [Text Objects](#text-objects)
  - [Visual Mode](#visual-mode)
- [Search and Replace](#search-and-replace)
- [Working with Files](#working-with-files)
  - [Opening and Saving](#opening-and-saving)
  - [Buffers](#buffers)
  - [Windows and Tabs](#windows-and-tabs)
- [Neovim-Specific Features](#neovim-specific-features)
  - [Built-in Terminal](#built-in-terminal)
  - [LSP Support](#lsp-support)
  - [Treesitter](#treesitter)
- [Your Configuration](#your-configuration)
  - [Leader Key](#leader-key)
  - [Custom Keybindings](#custom-keybindings)
- [Installed Plugins](#installed-plugins)
  - [File Navigation](#file-navigation)
  - [Git Integration](#git-integration)
  - [Code Intelligence](#code-intelligence)
  - [User Interface](#user-interface)
  - [Code Editing](#code-editing)
- [Common Tasks](#common-tasks)
- [Advanced Features](#advanced-features)
- [Additional Resources](#additional-resources)

## Introduction

Neovim is a modern, enhanced version of Vim focused on extensibility and usability. This sidesheet provides a comprehensive reference for Neovim's features, with specific attention to your configuration.

## Basic Navigation

### Cursor Movement

```
h - Move left
j - Move down
k - Move up
l - Move right

w - Jump forward to the start of a word
e - Jump forward to the end of a word
b - Jump backward to the start of a word

0 - Jump to the start of the line
^ - Jump to the first non-blank character of the line
$ - Jump to the end of the line

gg - Go to the first line of the document
G - Go to the last line of the document
5G - Go to line 5
```

### Text Scrolling

```
Ctrl+f - Page down (forward)
Ctrl+b - Page up (backward)
Ctrl+d - Scroll down half a page
Ctrl+u - Scroll up half a page
zz - Center current line
zt - Place current line at top
zb - Place current line at bottom
```

### Jumping Around

```
% - Jump to matching bracket
{ - Jump to previous paragraph
} - Jump to next paragraph
Ctrl+o - Jump to previous location
Ctrl+i - Jump to next location
```

## Editing Basics

### Insert Mode

```
i - Insert before the cursor
a - Insert after the cursor
I - Insert at the beginning of the line
A - Insert at the end of the line
o - Open a new line below and insert
O - Open a new line above and insert
Esc - Exit insert mode
```

### Deleting Text

```
x - Delete character under cursor
X - Delete character before cursor
dw - Delete word
dd - Delete line
D - Delete from cursor to end of line
d$ - Delete from cursor to end of line
d0 - Delete from cursor to beginning of line
d^ - Delete from cursor to first non-blank character
dG - Delete from current line to end of file
d5G - Delete from current line to line 5
```

### Copying and Pasting

```
y - Yank (copy) text
yy - Yank entire line
y$ - Yank to end of line
p - Paste after cursor
P - Paste before cursor
```

### Text Objects

```
iw - Inner word
aw - A word (includes surrounding space)
is - Inner sentence
as - A sentence
ip - Inner paragraph
ap - A paragraph

# Usage examples:
diw - Delete inner word
ci( - Change text inside parentheses
yi" - Yank text inside double quotes
va{ - Visually select text including braces
```

### Visual Mode

```
v - Enter visual mode (character-wise)
V - Enter visual line mode
Ctrl+v - Enter visual block mode
o - Move to the other end of selection
```

## Search and Replace

```
/pattern - Search forward for pattern
?pattern - Search backward for pattern
n - Repeat search forward
N - Repeat search backward
* - Search forward for word under cursor
# - Search backward for word under cursor

:%s/old/new/g - Replace all occurrences in file
:%s/old/new/gc - Replace with confirmations
```

## Working with Files

### Opening and Saving

```
:e filename - Edit a file
:w - Write (save) file
:w filename - Write to filename
:wq - Write and quit
:q - Quit
:q! - Quit without saving
```

### Buffers

```
:ls - List all buffers
:b number - Switch to buffer number
:bn - Next buffer
:bp - Previous buffer
:bd - Delete (close) buffer
```

### Windows and Tabs

```
:sp - Split window horizontally
:vsp - Split window vertically
Ctrl+w h/j/k/l - Navigate between windows
Ctrl+w = - Make all windows equal size
Ctrl+w _ - Maximize height of active window
Ctrl+w | - Maximize width of active window
Ctrl+w + - Increase window height
Ctrl+w - - Decrease window height
Ctrl+w > - Increase window width
Ctrl+w < - Decrease window width

:tabnew - Create new tab
:tabn - Next tab
:tabp - Previous tab
:tabclose - Close tab
```

## Neovim-Specific Features

### Built-in Terminal

```
:terminal - Open terminal in new buffer
:split term://bash - Open terminal in horizontal split
:vsplit term://bash - Open terminal in vertical split

# While in terminal mode:
<C-\><C-n> - Exit terminal mode (go to normal mode)
i or a - Enter terminal mode (from normal mode)
```

### LSP Support

Neovim has built-in support for Language Server Protocol:

```
gd - Go to definition
K - Show hover information
gr - Show references
<Space>rn - Rename symbol
<Space>ca - Code action
<Space>f - Format code
```

### Treesitter

Your setup uses nvim-treesitter for improved syntax highlighting and code navigation.

## Your Configuration

### Leader Key

Your leader key is set to `Space`. Your local leader key is set to `,`.

### Custom Keybindings

Basic operations:
```
<leader>w  - Save file
<leader>q  - Quit Neovim
<leader>h  - Clear search highlighting
<leader>cp - Copy relative file path to clipboard
```

Window, buffer, and tab navigation:
```
<C-h/j/k/l>       - Move between windows
<C-Up/Down>       - Resize window height
<C-Left/Right>    - Resize window width
<Tab>             - Next buffer
<S-Tab>           - Previous buffer
<leader>bb        - Open recent buffers with Telescope
<leader>bd        - Delete current buffer safely
<leader>tc        - Close tab
<leader>sv        - Scratch vertical split matching current filetype
```

Visual mode:
```
< - Indent left and keep selection
> - Indent right and keep selection
J - Move selected lines down
K - Move selected lines up
```

## Installed Plugins

### File Navigation

**nvim-tree** - File explorer:
```
<leader>tt - Toggle file explorer
```

**oil.nvim** - Directory editor/file manager:
```
-         - Open parent directory
<leader>O - Open Oil in a vertical split
```

**telescope.nvim** - Fuzzy finder:
```
<leader>ff - Find files
<leader>fH - Find files from home
<leader>fg - Live grep
<leader>fr - Recent files in current working directory
<leader>fb - Find buffers
<leader>fh - Find help tags
```

**harpoon** - Fast project file navigation:
```
<leader>ma - Add current file
<leader>mm - Open Harpoon menu
<leader>m1-4 - Jump to marked file 1-4
<leader>mp - Previous Harpoon file
<leader>mn - Next Harpoon file
```

### Git Integration

**lazygit.nvim** - Git client:
```
<leader>gg - Open LazyGit
<leader>gF - Open LazyGit for current file
```

**telescope git pickers**:
```
<leader>gs - Git status
<leader>gb - Git branches
<leader>gc - Git commits
<leader>gC - Git commits for current file
```

**diffview.nvim** - Git diff/review UI:
```
<leader>gv - Open Diffview for working tree
<leader>gV - Compare with HEAD~1
<leader>gL - Current file history
<leader>gA - Repository file history
<leader>gQ - Close Diffview
<leader>gR - Refresh Diffview
```

**gitsigns.nvim** - Git status in the gutter:
```
]c / [c       - Next/previous hunk
<leader>ghp   - Preview hunk
<leader>ghi   - Preview hunk inline
<leader>ghd   - Diff current file
<leader>ghs   - Stage hunk/selection
<leader>ghr   - Reset hunk/selection
<leader>ghu   - Undo stage hunk
<leader>ghS   - Stage buffer
<leader>ghR   - Reset buffer
<leader>ghb   - Full blame for current line
<leader>ght   - Toggle current line blame
<leader>ghq   - Send hunks to quickfix
ih            - Select hunk text object
```

### Code Intelligence

**nvim-lspconfig + mason.nvim** - LSP configuration and server installation.
Configured servers:
```
lua_ls, ts_ls, pyright, gopls, rust_analyzer
```

LSP/navigation keys:
```
gd         - Go to definition with Telescope
gD         - Go to type definition with Telescope
gr         - References with Telescope
gi         - Implementations with Telescope
K          - Hover information
<Space>rn - Rename symbol
<Space>ca - Code action
<Space>f  - Format code
<Space>e  - Diagnostic float
[d / ]d    - Previous/next diagnostic
<Space>q  - Diagnostics to location list
```

**nvim-cmp + LuaSnip** - Autocompletion and snippets:
```
<C-Space> - Trigger completion
<C-d>     - Scroll docs down
<C-f>     - Scroll docs up
<CR>      - Confirm selection
<Tab>     - Select next completion item or expand/jump snippet
<S-Tab>   - Select previous completion item or jump back in snippet
```

**conform.nvim** - Formatting on save:
```
lua: stylua
python: ruff_format
javascript/typescript/jsx/tsx/json/html/css/markdown: prettier
```

### Diagnostics and Lists

**tiny-inline-diagnostic.nvim** - Inline diagnostics:
```
<leader>dt - Toggle inline diagnostics
<leader>de - Enable inline diagnostics
<leader>dd - Disable inline diagnostics
```

**trouble.nvim** - Diagnostics, references, quickfix, and location list UI:
```
<leader>xx - Workspace diagnostics
<leader>xX - Buffer diagnostics
<leader>xr - References
<leader>xq - Quickfix
<leader>xl - Location list
```

**todo-comments.nvim** - TODO/FIXME navigation and search:
```
]t / [t      - Next/previous todo comment
<leader>st   - Search TODOs with Telescope
<leader>xt   - TODOs in Trouble
<leader>xT   - TODOs in quickfix
```

### User Interface

**catppuccin** - Catppuccin Mocha theme with transparent background.

**lualine.nvim** - Status line.

**bufferline.nvim** - Buffer tabs at the top.

**dropbar.nvim** - Winbar breadcrumbs for file path and code symbols.

**aerial.nvim** - Code outline/symbol sidebar:
```
<leader>a - Toggle Aerial
]a / [a   - Next/previous symbol
```

**indent-blankline.nvim** - Indentation guides.

**nvim-ufo** - Folding UI/provider:
```
zR - Open all folds
zM - Close all folds
zr - Open folds except kinds
zm - Close folds by level
```

**which-key.nvim** - Keybinding helper popup.

**nvim-notify** - Floating notifications.

### Code Editing

**nvim-treesitter** - Improved syntax highlighting with parsers for Lua, Vim, JS/TS/TSX, JSON, Bash, Markdown, HTML, CSS, Python, Go, Rust, and more.

**nvim-autopairs** - Auto-close brackets and quotes.

**nvim-surround** - Add/change/delete surrounding quotes, brackets, tags, etc.

**Comment.nvim** - Context-aware comment toggles for regular files and JSX/TSX.

**toggleterm.nvim** - Floating terminal integration:
```
<C-\> - Toggle terminal
```

### Markdown

**render-markdown.nvim** - Inline Markdown rendering:
```
<leader>mr - Toggle Markdown rendering
```

**markdown-preview.nvim** - Browser Markdown preview:
```
<leader>mP - Toggle browser preview
```

## Common Tasks

### Opening and Navigating Projects

1. Open Neovim in a directory: `nvim .`
2. Use Telescope:
   - `<leader>ff` to find files
   - `<leader>fg` to search within files
   - `<leader>fr` to open recent files in the current working directory
3. Use file managers:
   - `-` for Oil parent-directory editing
   - `<leader>tt` for nvim-tree
4. Use Harpoon for frequently accessed files: `<leader>ma`, then `<leader>m1`-`<leader>m4`.

### Working with Git

1. View git status markers in the sign column with gitsigns.
2. Open LazyGit: `<leader>gg`.
3. Review diffs with Diffview: `<leader>gv`.
4. Preview/stage/reset hunks with gitsigns: `<leader>ghp`, `<leader>ghs`, `<leader>ghr`.

### Code Editing Workflow

1. Navigate to definition: `gd`.
2. View documentation: `K`.
3. Rename symbol: `<Space>rn`.
4. Format code: `<Space>f` or save the file for format-on-save.
5. Use code actions: `<Space>ca`.
6. Toggle comments with Comment.nvim.
7. Inspect diagnostics with `<Space>e`, `<leader>xx`, or inline diagnostics.

### Multiple Files Management

1. Open multiple files: `:e file1`, `:e file2`.
2. Navigate buffers: `<Tab>` and `<S-Tab>`.
3. Delete a buffer safely: `<leader>bd`.
4. Split windows: `:sp` horizontal, `:vsp` vertical, or `<leader>sv` for a scratch vertical split.
5. Navigate splits: `<C-h/j/k/l>`.

## Advanced Features

### Macros

```
q{letter} - Start recording to register {letter}
q - Stop recording
@{letter} - Execute macro stored in register {letter}
@@ - Repeat the last executed macro
5@a - Execute macro 'a' 5 times
```

### Marks

```
m{letter} - Set mark at current position
'{letter} - Jump to line of mark
`{letter} - Jump to position of mark

# Lowercase marks are buffer-specific
# Uppercase marks are global
```

### Registers

```
"{register}y - Yank into register
"{register}p - Paste from register

# Special registers:
"0 - Last yanked text
"" - Unnamed register (last delete or yank)
"_ - Black hole register (discard text)
"+ - System clipboard
"* - Selection clipboard
```

### Command Line

```
:! command - Execute shell command
:read !command - Insert output of command
:help keyword - Get help on keyword
```

## Additional Resources

- Official Neovim documentation: `:help`
- Neovim website: [neovim.io](https://neovim.io)
- Neovim GitHub: [github.com/neovim/neovim](https://github.com/neovim/neovim)
- Learn Vim (applicable to Neovim): [vimways.org](https://vimways.org)
- Interactive tutorial: Run `vimtutor` in your terminal