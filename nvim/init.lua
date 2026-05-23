-- =========================================================
-- Minimal Native Neovim Config (Python Edition)
-- Neovim >= 0.12
-- Cross-platform: Linux + Windows
-- Zero plugins
-- =========================================================

-- ==================== Faster Startup =====================
vim.loader.enable()

-- ==================== Leader =============================
vim.g.mapleader = " "

-- ==================== UI ================================
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.cursorline = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true

vim.opt.termguicolors = true

vim.opt.signcolumn = "yes"

vim.opt.scrolloff = 8

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.clipboard = "unnamedplus"

vim.opt.completeopt = {
    "menu",
    "menuone",
    "noselect",
    "popup",
    "fuzzy",
}

vim.opt.pumheight = 10
vim.opt.winborder = "rounded"

vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

-- ==================== Theme ==============================
vim.cmd("colorscheme habamax")

-- ==================== Diagnostics ========================
vim.diagnostic.config({
    virtual_text = true,

    signs = true,

    underline = true,

    update_in_insert = false,

    severity_sort = true,

    float = {
        border = "rounded",
        source = "if_many",
    },
})

vim.keymap.set(
    "n",
    "gl",
    vim.diagnostic.open_float,
    { desc = "Show line diagnostics" }
)

vim.keymap.set(
    "n",
    "[d",
    vim.diagnostic.goto_prev,
    { desc = "Previous diagnostic" }
)

vim.keymap.set(
    "n",
    "]d",
    vim.diagnostic.goto_next,
    { desc = "Next diagnostic" }
)

-- ==================== Project Root =======================
local function project_root()

    local current =
        vim.api.nvim_buf_get_name(0)

    local root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        ".git",
    }

    local root =
        vim.fs.find(root_markers, {
            path = vim.fs.dirname(current),
            upward = true,
        })[1]

    if root then
        return vim.fs.dirname(root)
    end

    return vim.fn.getcwd()
end

-- ==================== Resolve pylsp ======================
local function resolve_pylsp_cmd()

    local is_windows =
        vim.fn.has("win32") == 1

    local bin_dir =
        is_windows and "Scripts" or "bin"

    local exe_ext =
        is_windows and ".exe" or ""

    local pylsp_bin =
        "pylsp" .. exe_ext

    local candidate_paths = {}

    -- Active virtual environment
    local virtual_env =
        vim.env.VIRTUAL_ENV

    if virtual_env
        and virtual_env ~= ""
    then
        table.insert(
            candidate_paths,
            virtual_env
                .. "/"
                .. bin_dir
                .. "/"
                .. pylsp_bin
        )
    end

    -- Project local environments
    local root = project_root()

    for _, venv_name in ipairs({
        ".venv",
        "venv",
    }) do
        table.insert(
            candidate_paths,
            root
                .. "/"
                .. venv_name
                .. "/"
                .. bin_dir
                .. "/"
                .. pylsp_bin
        )
    end

    -- First valid executable
    for _, candidate
        in ipairs(candidate_paths)
    do
        if vim.uv.fs_stat(candidate) then
            return candidate
        end
    end

    -- Fallback to PATH
    local cmd_path =
        vim.fn.exepath("pylsp")

    if cmd_path ~= "" then
        return cmd_path
    end

    return nil
end

-- ==================== Python Snippets ====================
local python_snippets = {
    ["def"] =
        "def ${1:name}(${2:args}):\n    ${3:pass}",

    ["class"] =
        "class ${1:ClassName}:\n    def __init__(self, ${2:args}):\n        ${3:pass}",

    ["ifmain"] =
        "if __name__ == \"__main__\":\n    ${1:main()}",
}

-- ==================== Smart Auto Pairs ===================
local function pair(open, close)

    return function()

        local col =
            vim.api.nvim_win_get_cursor(0)[2]

        local line =
            vim.api.nvim_get_current_line()

        local next_char =
            line:sub(col + 1, col + 1)

        -- Skip duplicate closing chars
        if next_char == close then
            return "<Right>"
        end

        return open
            .. close
            .. "<Left>"
    end
end

vim.keymap.set(
    "i",
    "(",
    pair("(", ")"),
    { expr = true }
)

vim.keymap.set(
    "i",
    "[",
    pair("[", "]"),
    { expr = true }
)

vim.keymap.set(
    "i",
    "{",
    pair("{", "}"),
    { expr = true }
)

vim.keymap.set(
    "i",
    "\"",
    pair("\"", "\""),
    { expr = true }
)

vim.keymap.set(
    "i",
    "'",
    pair("'", "'"),
    { expr = true }
)

-- ==================== pylsp ==============================
local pylsp_cmd =
    resolve_pylsp_cmd()

if pylsp_cmd then

    vim.api.nvim_create_autocmd(
        "FileType",
        {
            pattern = "python",

            callback = function(args)

                local root =
                    project_root()

                -- Prevent duplicate clients
                for _, client
                    in ipairs(
                        vim.lsp.get_clients()
                    )
                do
                    if client.name
                            == "pylsp"
                        and client.config
                            .root_dir
                            == root
                    then
                        vim.lsp.buf_attach_client(
                            args.buf,
                            client.id
                        )
                        return
                    end
                end

                vim.lsp.start({

                    name = "pylsp",

                    cmd = {
                        pylsp_cmd,
                    },

                    root_dir = root,

                    settings = {
                        pylsp = {
                            plugins = {

                                -- ====================
                                -- Jedi Completion
                                -- ====================
                                jedi_completion = {
                                    enabled = true,
                                    fuzzy = true,
                                    include_params = true,
                                },

                                jedi_definition = {
                                    enabled = true,
                                },

                                jedi_references = {
                                    enabled = true,
                                },

                                jedi_hover = {
                                    enabled = true,
                                },

                                jedi_symbols = {
                                    enabled = true,
                                },

                                -- ====================
                                -- Formatting
                                -- ====================
                                black = {
                                    enabled = true,
                                },

                                isort = {
                                    enabled = true,
                                },

                                -- ====================
                                -- Type Checking
                                -- ====================
                                pylsp_mypy = {
                                    enabled = true,
                                    live_mode = false,
                                },

                                -- ====================
                                -- Disable old linters
                                -- ====================
                                pycodestyle = {
                                    enabled = false,
                                },

                                pyflakes = {
                                    enabled = false,
                                },

                                mccabe = {
                                    enabled = false,
                                },
                            },
                        },
                    },

                    bufnr = args.buf,
                })
            end,
        }
    )

else
    vim.notify(
        "pylsp not found.\nInstall with:\n\npip install 'python-lsp-server[all]'",
        vim.log.levels.ERROR
    )
end

-- ==================== LSP Attach =========================
vim.api.nvim_create_autocmd(
    "LspAttach",
    {
        callback = function(ev)

            local opts = {
                buffer = ev.buf,
                silent = true,
            }

            local client =
                vim.lsp.get_client_by_id(
                    ev.data.client_id
                )

            -- ====================
            -- Navigation
            -- ====================
            vim.keymap.set(
                "n",
                "gd",
                vim.lsp.buf.definition,
                opts
            )

            vim.keymap.set(
                "n",
                "gD",
                vim.lsp.buf.declaration,
                opts
            )

            vim.keymap.set(
                "n",
                "gr",
                vim.lsp.buf.references,
                opts
            )

            vim.keymap.set(
                "n",
                "gi",
                vim.lsp.buf.implementation,
                opts
            )

            vim.keymap.set(
                "n",
                "K",
                vim.lsp.buf.hover,
                opts
            )

            -- ====================
            -- Actions
            -- ====================
            vim.keymap.set(
                "n",
                "<leader>rn",
                vim.lsp.buf.rename,
                opts
            )

            vim.keymap.set(
                "n",
                "<leader>ca",
                vim.lsp.buf.code_action,
                opts
            )

            vim.keymap.set(
                "n",
                "<leader>fm",
                vim.lsp.buf.format,
                opts
            )

            -- ====================
            -- Signature Help
            -- ====================
            vim.keymap.set(
                "i",
                "<C-k>",
                vim.lsp.buf.signature_help,
                opts
            )

            -- ====================
            -- Completion
            -- ====================
            if client
                and client:supports_method(
                    "textDocument/completion"
                )
            then
                vim.lsp.completion.enable(
                    true,
                    client.id,
                    ev.buf,
                    {
                        autotrigger = true,
                    }
                )
            end

            -- ====================
            -- Inlay Hints
            -- ====================
            if client
                and client:supports_method(
                    "textDocument/inlayHint"
                )
            then
                vim.lsp.inlay_hint.enable(
                    true,
                    { bufnr = ev.buf }
                )
            end
        end,
    }
)

-- ==================== Completion =========================

-- Manual completion trigger
vim.keymap.set(
    "i",
    "<C-Space>",
    function()
        vim.lsp.completion.get()
    end
)

-- Safe Enter behavior
vim.keymap.set(
    "i",
    "<CR>",
    function()

        if vim.fn.pumvisible() == 1 then

            local selected =
                vim.fn.complete_info({
                    "selected",
                }).selected

            if selected ~= -1 then
                return "<C-y>"
            end

            return "<C-e><CR>"
        end

        return "<CR>"

    end,
    {
        expr = true,
        silent = true,
    }
)

-- Tab completion + snippets
vim.keymap.set(
    "i",
    "<Tab>",
    function()

        -- Completion menu navigation
        if vim.fn.pumvisible() == 1 then
            return "<C-n>"
        end

        -- Snippet jump forward
        if vim.snippet.active({
            direction = 1,
        }) then
            vim.snippet.jump(1)
            return ""
        end

        local col =
            vim.api.nvim_win_get_cursor(0)[2]

        local line =
            vim.api.nvim_get_current_line()

        local word =
            line:sub(1, col):match("%w+$")

        -- Expand snippets safely
        if vim.bo.filetype
                == "python"
            and word
            and python_snippets[word]
        then

            local keys =
                string.rep(
                    "<BS>",
                    #word
                )

            vim.api.nvim_feedkeys(
                vim.keycode(keys),
                "n",
                false
            )

            vim.schedule(function()
                vim.snippet.expand(
                    python_snippets[word]
                )
            end)

            return ""
        end

        return "<Tab>"

    end,
    {
        expr = true,
        silent = true,
    }
)

-- Shift Tab
vim.keymap.set(
    "i",
    "<S-Tab>",
    function()

        if vim.fn.pumvisible() == 1 then
            return "<C-p>"
        end

        if vim.snippet.active({
            direction = -1,
        }) then
            vim.snippet.jump(-1)
            return ""
        end

        return "<S-Tab>"

    end,
    {
        expr = true,
        silent = true,
    }
)

-- ==================== Auto Format ========================
vim.api.nvim_create_autocmd(
    "BufWritePre",
    {
        pattern = "*.py",

        callback = function()
            vim.lsp.buf.format({
                async = false,
            })
        end,
    }
)

-- ==================== Terminal Runner ====================
local term_buf = nil

local function run_in_split(cmd)

    if term_buf
        and vim.api.nvim_buf_is_valid(
            term_buf
        )
    then
        vim.cmd(
            "botright sbuffer "
                .. term_buf
        )
    else
        vim.cmd("botright 12split")
        vim.cmd("terminal")

        term_buf =
            vim.api.nvim_get_current_buf()
    end

    local job_id =
        vim.bo[term_buf].channel

    if job_id then
        vim.fn.chansend(
            job_id,
            cmd .. "\n"
        )
    end

    vim.cmd("startinsert")
end

-- ==================== Python Keymaps =====================
vim.api.nvim_create_autocmd(
    "FileType",
    {
        pattern = "python",

        callback = function(ev)

            local opts = {
                buffer = ev.buf,
                silent = true,
            }

            -- Run file
            vim.keymap.set(
                "n",
                "<leader>rr",
                function()

                    local file =
                        vim.fn.expand("%:p")

                    run_in_split(
                        'python "'
                            .. file
                            .. '"'
                    )

                end,
                vim.tbl_extend(
                    "force",
                    opts,
                    {
                        desc =
                        "Run current Python file",
                    }
                )
            )

            -- Run tests in current file
            vim.keymap.set(
                "n",
                "<leader>tf",
                function()

                    local file =
                        vim.fn.expand("%:p")

                    run_in_split(
                        'pytest -q "'
                            .. file
                            .. '"'
                    )

                end,
                vim.tbl_extend(
                    "force",
                    opts,
                    {
                        desc =
                        "Run tests in current file",
                    }
                )
            )

            -- Run all tests
            vim.keymap.set(
                "n",
                "<leader>ta",
                function()
                    run_in_split(
                        "pytest -q"
                    )
                end,
                vim.tbl_extend(
                    "force",
                    opts,
                    {
                        desc =
                        "Run all tests",
                    }
                )
            )
        end,
    }
)

-- ==================== Window Navigation ==================
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")

-- ==================== Terminal Escape ====================
vim.keymap.set(
    "t",
    "<Esc>",
    [[<C-\><C-n>]],
    { silent = true }
)

-- ==================== Save / Quit ========================
vim.keymap.set(
    "n",
    "<leader>w",
    "<cmd>w<CR>",
    { desc = "Save file" }
)

vim.keymap.set(
    "n",
    "<leader>q",
    "<cmd>q<CR>",
    { desc = "Quit window" }
)

-- ==================== Startup Checks =====================
vim.api.nvim_create_autocmd(
    "VimEnter",
    {
        callback = function()

            if vim.fn.executable(
                    "python"
                )
                == 0
            then
                vim.notify(
                    "Python not found in PATH",
                    vim.log.levels.ERROR
                )
            end

            if vim.fn.executable(
                    "pytest"
                )
                == 0
            then
                vim.notify(
                    "pytest not found in PATH",
                    vim.log.levels.WARN
                )
            end
        end,
    }
)
-- ==================== Better Delete ======================
-- Delete without overwriting clipboard/yank register

vim.keymap.set(
    { "n", "v" },
    "d",
    "\"_d",
    { noremap = true, silent = true }
)

vim.keymap.set(
    { "n", "v" },
    "D",
    "\"_D",
    { noremap = true, silent = true }
)

vim.keymap.set(
    "n",
    "x",
    "\"_x",
    { noremap = true, silent = true }
)

-- =========================================================
-- REQUIRED INSTALLS
-- =========================================================
--
-- pip install "python-lsp-server[all]"
-- pip install python-lsp-ruff
-- pip install pylsp-mypy
-- pip install black
-- pip install isort
-- pip install pytest
-- pip install rope
-- pip install jedi
--
-- Linux clipboard:
--
-- sudo apt install xclip
--
-- or
--
-- sudo apt install wl-clipboard
--
-- =========================================================
