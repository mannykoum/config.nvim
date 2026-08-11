local function gh(repo) return 'https://github.com/' .. repo end

-- [[ fzf-lua ]]
-- Fuzzy finder over fzf. Icon support comes from `mini.icons`, which
-- `kickstart.plugins.mini` already mocks as `nvim-web-devicons`.
vim.pack.add { gh 'ibhagwan/fzf-lua' }

require('fzf-lua').setup {}

-- vim: ts=2 sts=2 sw=2 et
