return {
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' }
        },
        config = function()
            local builtin = require("telescope.builtin")
            -- Search for files in current directory
            vim.keymap.set("n", "<leader>pf", function()
                builtin.find_files({ prompt_title = "Find project files" })
            end)
            -- Search for files gloablly
            vim.keymap.set("n", "<leader>gf", function()
                builtin.find_files({ prompt_title = "Find global files", cwd = "~/" })
            end)
            -- Search interactively for string in project
            vim.keymap.set("n", "<leader>ps", builtin.live_grep)
        end
    }
}
