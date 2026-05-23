# Minimalist Native Neovim Config (Python Edition)

A lightweight, 100% plugin-free Neovim configuration tailored specifically for Python development. This setup leverages Neovim 0.10+'s powerful built-in features to provide a modern IDE experience without the bloat of third-party package managers.

Fully cross-platform: seamlessly works on both **Linux** and **Windows**.

---

## ✨ Features

- **Zero Plugins:** Blazing fast startup time and zero dependency hell.
- **Native LSP Integration:** Automatically detects local Python virtual environments (`.venv` or `venv`) on both Windows (`Scripts/`) and Linux (`bin/`).
- **Native Snippet Engine:** Expand and jump through Python boilerplate (`def`, `class`, `ifmain`) using just the `<Tab>` key.
- **Integrated Test/Run Runner:** Execute your Python scripts or run `pytest` in a bottom-split terminal without leaving the editor.
- **Auto-closing Pairs:** Instantly closes brackets and quotes, keeping your cursor exactly where it needs to be.
- **Cross-Platform Clipboard:** Seamlessly copy/paste between Neovim and your browser/OS using the `unnamedplus` register.

---

## ⚙️ Prerequisites

To get the most out of this configuration, ensure you have the following installed:

### 1. Neovim >= 0.10

Required for native snippets and the `habamax` / `retrobox` themes.

### 2. Python LSP Server

Install this in your project's virtual environment or globally:

```bash
pip install "python-lsp-server[all]"
```
if pip is not showing due to pevn use this command
```pyenv global 3.13.12```

### 3. Clipboard Utility (Linux Only)

#### X11

```bash
sudo apt install xclip
```

or

```bash
sudo apt install xsel
```

#### Wayland

```bash
sudo apt install wl-clipboard
```

> Windows handles clipboard integration natively.

---

## 🚀 Installation

Simply copy the `init.lua` file into your Neovim configuration directory.

### Linux

```bash
~/.config/nvim/init.lua
```

### Windows

```powershell
~/AppData/Local/nvim/init.lua
```

---

## ⌨️ Keybindings Cheat Sheet

### Leader Key

```text
<Space>
```

---

## 🐍 Python Execution & Testing

| Keymap      | Action      | Description                                                  |
| ------------ | ------------ | ------------------------------------------------------------ |
| `<leader>rr` | Run Script   | Executes the current Python file in a split terminal.        |
| `<leader>tf` | Test File    | Runs `pytest` on the current file.                           |
| `<leader>ta` | Test All     | Runs `pytest` on the entire project.                         |

---

## 🧠 LSP & Code Navigation

| Keymap       | Action               | Description                                                  |
| ------------- | -------------------- | ------------------------------------------------------------ |
| `gd`          | Go to Definition     | Jumps to where a function/class is defined.                  |
| `gD`          | Go to Declaration    | Jumps to the declaration.                                    |
| `gr`          | Find References      | Lists all places where the item under the cursor is used.    |
| `K`           | Hover Documentation  | Shows the docstring/type info for the item under the cursor. |
| `<leader>rn` | Rename               | Renames the variable/function across the file.               |
| `<leader>ca` | Code Action          | Shows available quick-fixes or refactors.                    |

---

## 🚨 Diagnostics (Errors & Warnings)

| Keymap | Action                  | Description                                                  |
| ------- | ----------------------- | ------------------------------------------------------------ |
| `gl`    | Show Line Diagnostics   | Opens a floating window explaining the error/warning.        |
| `[d`    | Previous Diagnostic     | Jumps to the previous error/warning.                         |
| `]d`    | Next Diagnostic         | Jumps to the next error/warning.                             |

---

## ✂️ Snippets

| Keymap               | Action        | Description                                                  |
| -------------------- | ------------- | ------------------------------------------------------------ |
| `def + <Tab>`        | Function      | Expands to a standard Python function layout.                |
| `class + <Tab>`      | Class         | Expands to a standard class with an `__init__` method.       |
| `ifmain + <Tab>`     | Main Guard    | Expands to `if __name__ == "__main__":`                      |
| `<Tab>`              | Jump Forward  | Moves cursor to the next variable in the snippet.            |
| `<S-Tab>`            | Jump Backward | Moves cursor to the previous variable in the snippet.        |

---

## 🎨 Theming

This config uses Neovim 0.10's upgraded built-in themes. It defaults to `habamax` for a high-contrast dark mode.

To change this, modify the following line in `init.lua`:

```lua
vim.cmd("colorscheme habamax")
-- Alternatives: retrobox, sorbet, quiet
```


