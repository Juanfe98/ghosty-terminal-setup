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

Your leader key is set to `Space`.

### Custom Keybindings

Basic operations:
```
<leader>w - Save file
<leader>q - Quit Neovim
<leader>h - Clear search highlighting
```

Window navigation:
```
<C-h> - Move to left window
<C-j> - Move to down window  
<C-k> - Move to up window
<C-l> - Move to right window
```

Window resizing:
```
<C-Up> - Decrease window height
<C-Down> - Increase window height
<C-Left> - Decrease window width
<C-Right> - Increase window width
```

Buffer navigation:
```
<Tab> - Next buffer
<S-Tab> - Previous buffer
```

Visual mode:
```
< - Indent left (keeps selection)
> - Indent right (keeps selection)
J - Move selected lines down
K - Move selected lines up
```

## Installed Plugins

### File Navigation

**nvim-tree** - File explorer:
```
<leader>e - Toggle file explorer
```

**telescope** - Fuzzy finder:
```
<leader>ff - Find files
<leader>fg - Find text (grep)
<leader>fb - Find buffers
<leader>fh - Find help tags
```

### Git Integration

**lazygit** - Git client:
```
<leader>gg - Open LazyGit
<leader>gF - Open LazyGit for current file
```

**gitsigns** - Git status in the gutter:
Shows git diff markers in the sign column.

### Code Intelligence

**nvim-lspconfig** - LSP configuration:
Provides integration with language servers.

**mason.nvim** - Package manager:
Installs and manages LSP servers, linters, formatters.

**nvim-cmp** - Autocompletion:
```
<C-Space> - Trigger completion
<C-d> - Scroll docs down
<C-f> - Scroll docs up
<CR> - Confirm selection
<Tab> - Select next item
<S-Tab> - Select previous item
```

**LuaSnip** - Snippet engine:
Works with nvim-cmp for snippet expansion.

### User Interface

**onedark** - Theme:
Dark theme based on Atom's One Dark.

**lualine** - Status line:
Enhanced status line with useful information.

**bufferline** - Buffer tabs:
Shows tabs for open buffers at the top.

**indent-blankline** - Indentation guides:
Displays vertical lines for indentation.

**which-key** - Keybinding helper:
Shows available key bindings in a popup.

### Code Editing

**nvim-autopairs** - Auto-close brackets:
Automatically closes brackets, quotes, etc.

**Comment.nvim** - Comment toggle:
Toggle comments with keybindings.

**toggleterm** - Terminal integration:
```
<C-\> - Toggle terminal
```

## Common Tasks

### Opening and Navigating Projects

1. Open Neovim in a directory: `nvim .`
2. Use nvim-tree: Press `<leader>e` to toggle file explorer
3. Use Telescope: 
   - `<leader>ff` to find files
   - `<leader>fg` to search within files

### Working with Git

1. View git status: Changes appear in the sign column (gitsigns)
2. Open LazyGit: `<leader>gg`
3. See git changes for current file: `<leader>gF`

### Code Editing Workflow

1. Navigate to definition: `gd`
2. View documentation: `K`
3. Rename symbol: `<Space>rn`
4. Format code: `<Space>f`
5. Use code actions: `<Space>ca`
6. Toggle comments: Use Comment.nvim

### Multiple Files Management

1. Open multiple files: `:e file1`, `:e file2`
2. Navigate buffers: `<Tab>` and `<S-Tab>`
3. Split windows: `:sp` (horizontal), `:vsp` (vertical)
4. Navigate splits: `<C-h/j/k/l>`

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