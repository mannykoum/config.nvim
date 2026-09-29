local function gh(repo) return 'https://github.com/' .. repo end

-- [[ focus.nvim ]]
-- Auto-resizes the focused split. Pinned to the latest tagged release.
vim.pack.add { { src = gh 'nvim-focus/focus.nvim', version = vim.version.range '*' } }

require('focus').setup()

-- vim: ts=2 sts=2 sw=2 et
