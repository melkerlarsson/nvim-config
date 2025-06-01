vim.diagnostic.config({
    virtual_text = {
        prefix = "●", -- valfritt: kan också vara ">>", "→", etc.
        spacing = 2,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

local smart_go_to_definition = function(client)
    local encoding = client.offset_encoding or "utf-16"
    local params = vim.lsp.util.make_position_params(0, encoding)
    vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result)
        if err or not result or vim.tbl_isempty(result) then
            print("[LSP] No definition found")
            return
        end

        local def = result[1]
        local uri = def.uri or def.targetUri
        local range = def.range or def.targetSelectionRange
        local filename = vim.uri_to_fname(uri)

        if filename ~= vim.api.nvim_buf_get_name(0) then
            vim.cmd('vsplit ' .. filename)
        end

        vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })
        vim.lsp.buf.clear_references()
    end)
end

local on_attach = function(client, bufnr)
    vim.keymap.set('n', 'gd', function() smart_go_to_definition(client) end, { desc = "Smarter Go to Definition" })
end


return {

    {
        "neovim/nvim-lspconfig",
        config = function()
            local capabilities = require('blink.cmp').get_lsp_capabilities()
            local lspconfig = require("lspconfig")


            local jdtls_path = "/usr/local/opt/jdtls/libexec"
            local jdtls_launcher =
            "/usr/local/opt/jdtls/libexec/plugins/org.eclipse.equinox.launcher_1.7.0.v20250424-1814.jar" -- jdtls_path .. "plugins/org.eclipse.equinox.launcher_1.7.0.v20250424-1814.jar"
            local jdtls_config = jdtls_path .. "/config_mac"

            local root_markers = { "build.gradle", "settings.gradle", ".git" }
            local root_dir = require("lspconfig.util").root_pattern(unpack(root_markers))(vim.fn.getcwd())

            lspconfig.jdtls.setup({
                cmd = {
                    "java",
                    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                    "-Dosgi.bundles.defaultStartLevel=4",
                    "-Declipse.product=org.eclipse.jdt.ls.core.product",
                    "-Dlog.protocol=true",
                    "-Dlog.level=ALL",
                    "-Xms1g",
                    "--add-modules=ALL-SYSTEM",
                    "--add-opens", "java.base/java.util=ALL-UNNAMED",
                    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
                    "-jar", vim.fn.glob(jdtls_launcher),
                    "-configuration", jdtls_config,
                    "-data", vim.fn.stdpath("cache") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t"),
                },
                capabilities = capabilities,
                on_attach = on_attach,
                root_dir = root_dir,
            })


            lspconfig.lua_ls.setup({
                cmd = { "lua-language-server" },
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    Lua = {
                        runtime = {
                            version = 'LuaJIT', -- Neovim uses LuaJIT
                            path = vim.split(package.path, ';'),
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
                },
            })
            lspconfig.pyright.setup { capabilities = capabilities, on_attach = on_attach }
            lspconfig.ruff.setup({ capabilities = capabilities, on_attach = on_attach })
            lspconfig.rust_analyzer.setup({ capabilities = capabilities, on_attach = on_attach })
            lspconfig.texlab.setup({ capabilities = capabilities, on_attach = on_attach })
        end,
    }
}
