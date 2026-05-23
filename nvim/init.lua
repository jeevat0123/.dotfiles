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
    local root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }
    local root_file = vim.fs.find(root_markers, {
        path = vim.fn.getcwd(),
        upward = true,
    })[1]

    local candidate_paths = {}

    local virtual_env = vim.env.VIRTUAL_ENV
    if virtual_env and virtual_env ~= "" then
        table.insert(candidate_paths, virtual_env .. "/Scripts/pylsp.exe")
    end

    if root_file then
        local project_root = vim.fs.dirname(root_file)
        for _, venv_name in ipairs({ ".venv", "venv" }) do
            table.insert(candidate_paths, project_root .. "/" .. venv_name .. "/Scripts/pylsp.exe")
        end
    end

    for _, candidate in ipairs(candidate_paths) do
        if vim.uv.fs_stat(candidate) then
            return candidate
        end
    end

    for _, cmd_name in ipairs({ "pylsp.exe", "pylsp" }) do
        local cmd_path = vim.fn.exepath(cmd_name)
        if cmd_path ~= "" then
            return cmd_path
        end
    end

    return nil
end

local pylsp_cmd = resolve_pylsp_cmd()
if pylsp_cmd then
    vim.lsp.config("pylsp", {
        cmd = { pylsp_cmd },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
        settings = {
            pylsp = {
                plugins = {
                    -- Disable heavy plugins that slow down responsiveness
                    pylint = { enabled = false },
                    rope_completion = { enabled = false },
                    yapf = { enabled = false },
                    -- Optimize the Jedi completion engine
                    jedi_completion = { 
                        enabled = true, 
                        fuzzy = false, -- Turning off fuzzy search speeds up exact dot-matching
                        include_params = true, 
                    },
                }
            }
        }
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
