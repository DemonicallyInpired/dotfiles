vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.cursorline = true
vim.opt.undofile = true

vim.opt.mouse = "a"
vim.opt.showmode = false 
vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true

vim.opt.listchars = { tab = " ", trail = ".", nbsp = "󱁐" }

vim.opt.inccommand = "split"
vim.opt.scrolloff = 10
vim.opt.clipboard = "unnamedplus"

-- vim.opt.cmdheight = 0

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("YankHighlight", {clear = true}), 
    pattern = "*", 
    callback = function()
        vim.highlight.on_yank()
    end, 
    desc = "Highlight yank"
})

vim.api.nvim_create_autocmd("colorscheme", {
    callback = function()
        vim.cmd [[
            highlight LineNr guibg=NONE
            "highlight CursorLineNr guibg=NONE
            highlight SignColumn guibg=NONE
        ]]
    end
})
