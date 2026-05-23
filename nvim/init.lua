-- ============ Basic Options ============
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }
vim.g.mapleader = " "

vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

-- ============ LSP Setup (native) ============
local function resolve_pylsp_cmd()
    -- OS detection
    local is_windows = vim.fn.has("win32") == 1
    local bin_dir = is_windows and "Scripts" or "bin"
    local exe_ext = is_windows and ".exe" or ""
    local pylsp_bin = "pylsp" .. exe_ext

    local root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }
    local root_file = vim.fs.find(root_markers, {
        path = vim.fn.getcwd(),
        upward = true,
    })[1]

    local candidate_paths = {}

    local virtual_env = vim.env.VIRTUAL_ENV
    if virtual_env and virtual_env ~= "" then
        table.insert(candidate_paths, virtual_env .. "/" .. bin_dir .. "/" .. pylsp_bin)
    end

    if root_file then
        local project_root = vim.fs.dirname(root_file)
        for _, venv_name in ipairs({ ".venv", "venv" }) do
            table.insert(candidate_paths, project_root .. "/" .. venv_name .. "/" .. bin_dir .. "/" .. pylsp_bin)
        end
    end

    for _, candidate in ipairs(candidate_paths) do
        if vim.uv.fs_stat(candidate) then
            return candidate
        end
    end

    -- Fallback to system path
    local cmd_path = vim.fn.exepath("pylsp")
    if cmd_path ~= "" then
        return cmd_path
    end

    return nil
end

local pylsp_cmd = resolve_pylsp_cmd()
if pylsp_cmd then
    vim.lsp.config("pylsp", {
        cmd = { pylsp_cmd },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
    })
    vim.lsp.enable("pylsp")
else
    vim.notify(
        "pylsp not found on PATH or in .venv. Install python-lsp-server in your Python environment.",
        vim.log.levels.WARN
    )
end

-- ============ LSP Keymaps + Auto-Completion ============
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if vim.lsp.completion and client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})

-- ============ Basic Python Run/Test Keymaps (no plugins) ============
local function run_in_split(cmd)
    -- Reuse a bottom split terminal for quick run/test cycles.
    vim.cmd("botright 12split")
    vim.cmd("terminal " .. cmd)
    vim.cmd("startinsert")
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        vim.keymap.set("n", "<leader>rr", function()
            run_in_split("python \"" .. vim.fn.expand("%:p") .. "\"")
        end, vim.tbl_extend("force", opts, { desc = "Run current Python file" }))

        vim.keymap.set("n", "<leader>ta", function()
            run_in_split("pytest -q")
        end, vim.tbl_extend("force", opts, { desc = "Run all tests" }))

        vim.keymap.set("n", "<leader>tf", function()
            run_in_split("pytest -q \"" .. vim.fn.expand("%:p") .. "\"")
        end, vim.tbl_extend("force", opts, { desc = "Run tests in current file" }))
    end,
})


-- ============ Auto-close Brackets ============
vim.keymap.set("i", "(", "()<Left>")
vim.keymap.set("i", "{", "{}<Left>")
vim.keymap.set("i", "[", "[]<Left>")

-- You will likely want these for Python strings too:
vim.keymap.set("i", "\"", "\"\"<Left>")
vim.keymap.set("i", "'", "''<Left>")


-- ============ Diagnostics Keymaps ============
-- Show warning/error on the current line in a floating window
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- Jump to the previous or next warning/error
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })


-- ============ Theme ============
vim.cmd("colorscheme habamax") -- or retrobox


-- ============ Native Snippets (No Plugins) ============
-- Define your custom Python snippets here
local python_snippets = {
    -- $1 is the first stop, $2 is the second, $0 is where the cursor ends up last.
    ["def"] = "def ${1:name}(${2:args}):\n    ${3:pass}",
    ["class"] = "class ${1:ClassName}:\n    def __init__(self, ${2:args}):\n        ${3:pass}",
    ["ifmain"] = "if __name__ == \"__main__\":\n    ${1:main()}"
}
vim.keymap.set({ "i", "s" }, "<Tab>", function()
    -- 1. If we are already inside a snippet, jump forward to the next placeholder
    if vim.snippet.active({ direction = 1 }) then
        vim.snippet.jump(1)
        return
    end

    -- 2. Get the word right before the cursor
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local word = line:sub(1, col):match("%w+$")

    -- 3. If the word matches our snippet dictionary, expand it
    if vim.bo.filetype == "python" and word and python_snippets[word] then
        -- Delete the trigger word (e.g., "def")
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        vim.api.nvim_buf_set_text(0, row, col - #word, row, col, {})
        
        -- Expand the snippet
        vim.snippet.expand(python_snippets[word])
        return
    end

    -- 4. Otherwise, behave like a normal Tab key
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", true)
end, { silent = true, desc = "Snippet expand or jump forward" })

-- Use Shift+Tab to jump backward through the snippet
vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
    if vim.snippet.active({ direction = -1 }) then
        vim.snippet.jump(-1)
    end
end, { silent = true, desc = "Snippet jump backward" })
