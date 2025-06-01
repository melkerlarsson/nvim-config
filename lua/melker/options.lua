vim.opt.clipboard = "unnamedplus"

-- TAB
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- UI CONFIG
vim.opt.number = true
vim.opt.relativenumber = true
vim.o.scrolloff = 8
vim.opt.cursorline = true

local orange = vim.api.nvim_get_hl(0, { name = "GruvboxOrange", link = false }).fg
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = orange, bold = true })

-- Testing this
vim.o.updatetime = 100

-- On Save
vim.api.nvim_create_autocmd("BufWritePost", {
    callback = function()
        vim.lsp.buf.format({})
    end
})
