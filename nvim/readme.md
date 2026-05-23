# Minimal Native Neovim Config (Python Edition)

A lightweight, blazing-fast, 100% plugin-free Neovim configuration built specifically for Python development using only native features from :contentReference[oaicite:0]{index=0}.

This setup provides a modern IDE experience without plugin managers, dependency conflicts, or startup bloat.

Fully cross-platform:
- Linux
- Windows

---

# ✨ Features

## ⚡ Zero Plugins
- No lazy.nvim
- No packer.nvim
- No Mason
- No dependency hell
- Instant startup

Uses only Neovim's native APIs.

---

## 🧠 Native LSP Support
Automatic Python LSP setup using:

- `python-lsp-server`
- local `.venv`
- active `VIRTUAL_ENV`
- global fallback

Supports:
- autocomplete
- hover docs
- go-to-definition
- references
- rename
- diagnostics
- formatting
- inlay hints

---

## 🔥 Native Autocomplete
Powered entirely by native Neovim completion.

Features:
- automatic popup suggestions
- fuzzy completion
- import suggestions
- method suggestions
- completion confirmation
- `<Tab>` navigation
- `<S-Tab>` reverse navigation

Example:

```python
from loguru import logger

logger.info()
```

Autocomplete suggestions appear automatically.

---

## ✂️ Native Snippet Engine
Uses Neovim 0.12 built-in snippets.

Built-in snippets:

| Trigger | Expands To |
|---|---|
| `def` | Python function |
| `class` | Python class |
| `ifmain` | Main entry block |

Example:

```python
def<Tab>
```

expands into:

```python
def name(args):
    pass
```

---

## 🎨 Smart Auto-Pairs
Automatic closing for:

- `()`
- `{}`
- `[]`
- `""`
- `''`

Cursor placement is handled automatically.

---

## 🚀 Integrated Python Runner
Run Python files directly inside Neovim.

Features:
- reusable terminal
- split terminal runner
- pytest integration

---

## 🧪 Integrated Pytest Support

Run:
- current file tests
- all project tests

without leaving Neovim.

---

## 🧹 Auto Formatting
Automatic formatting on save using:

- `black`
- `isort`

---

## ⚠️ Native Diagnostics
Features:
- inline diagnostics
- floating error popups
- warning navigation
- severity sorting

---

## 📋 System Clipboard Support
Uses system clipboard automatically.

Works on:
- Linux
- Windows

---

# ⚙️ Requirements

## Required

### 1. Neovim

Version:

```bash
nvim --version
```

Requires:

```text
Neovim >= 0.12
```

---

### 2. Python

Install Python 3.10+.

---

### 3. Python LSP + Tools

Install:

```bash
pip install "python-lsp-server[all]"
pip install python-lsp-ruff
pip install pylsp-mypy
pip install black
pip install isort
pip install pytest
pip install rope
pip install jedi
```

---

# 📋 Linux Clipboard Setup

## X11

```bash
sudo apt install xclip
```

## Wayland

```bash
sudo apt install wl-clipboard
```

Windows works automatically.

---

# 🚀 Installation

## Linux

Config location:

```bash
~/.config/nvim/init.lua
```

---

## Windows

Config location:

```text
~/AppData/Local/nvim/init.lua
```

---

## Copy Config

Copy the provided `init.lua` into your Neovim config directory.

---

# ⌨️ Keybindings

Leader key:

```text
Space
```

---

# 🧠 LSP Navigation

| Keymap | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Find references |
| `gi` | Go to implementation |
| `K` | Hover documentation |

---

# ✏️ Code Actions

| Keymap | Action |
|---|---|
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>fm` | Format file |

---

# ⚠️ Diagnostics

| Keymap | Action |
|---|---|
| `gl` | Show diagnostics popup |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |

---

# ✂️ Snippets

| Keymap | Action |
|---|---|
| `Tab` | Expand snippet / next placeholder |
| `Shift+Tab` | Previous placeholder |

---

# 🔥 Completion

| Keymap | Action |
|---|---|
| `Ctrl+Space` | Trigger completion |
| `Enter` | Confirm completion |
| `Tab` | Next completion item |
| `Shift+Tab` | Previous completion item |

---

# 🐍 Python Runner

| Keymap | Action |
|---|---|
| `<leader>rr` | Run current Python file |
| `<leader>tf` | Run tests in current file |
| `<leader>ta` | Run all tests |

---

# 🪟 Window Navigation

| Keymap | Action |
|---|---|
| `Ctrl+h` | Left window |
| `Ctrl+l` | Right window |
| `Ctrl+j` | Bottom window |
| `Ctrl+k` | Top window |

---

# 💾 Save / Quit

| Keymap | Action |
|---|---|
| `<leader>w` | Save file |
| `<leader>q` | Quit window |

---

# 🖥️ Terminal

| Keymap | Action |
|---|---|
| `Esc` | Exit terminal mode |

---

# 📂 Virtual Environment Detection

The config automatically detects:

## Priority Order

1. Active `VIRTUAL_ENV`
2. Project `.venv`
3. Project `venv`
4. Global `pylsp`

---

# 📁 Recommended Project Structure

```text
project/
├── .venv/
├── src/
├── tests/
├── pyproject.toml
└── README.md
```

---

# 🧪 Testing Your Setup

## Verify LSP

Inside Neovim:

```vim
:LspInfo
```

Expected:
- `pylsp` attached

---

## Verify Completion

Type:

```python
from loguru import
```

Expected:
- autocomplete suggestions

---

## Verify Formatting

Save a badly formatted file.

Expected:
- automatic formatting

---

# 🎨 Themes

Default:

```lua
vim.cmd("colorscheme habamax")
```

Built-in alternatives:

```lua
vim.cmd("colorscheme retrobox")
vim.cmd("colorscheme sorbet")
vim.cmd("colorscheme quiet")
```

---

# ⚡ Performance

This config uses:

```lua
vim.loader.enable()
```

Benefits:
- Lua bytecode caching
- faster startup
- reduced config load time

---

# 🧼 Philosophy

This config intentionally avoids:
- plugin managers
- heavy frameworks
- unnecessary abstractions
- startup slowdown

Everything is:
- native
- minimal
- fast
- maintainable
- future-proof

---

# ✅ Features Summary

| Feature | Included |
|---|---|
| Native LSP | ✅ |
| Native Completion | ✅ |
| Native Snippets | ✅ |
| Auto Formatting | ✅ |
| Auto Pairs | ✅ |
| Diagnostics | ✅ |
| Inlay Hints | ✅ |
| Semantic Highlighting | ✅ |
| Python Runner | ✅ |
| Pytest Integration | ✅ |
| System Clipboard | ✅ |
| Cross Platform | ✅ |
| Plugin Free | ✅ |

---

# 📜 License

MIT
