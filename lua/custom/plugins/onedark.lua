local function gh(repo) return 'https://github.com/' .. repo end

-- [[ Colorscheme: onedark ]]
-- Theme inspired by Atom.
-- styles: dark, darker, deep, cool, warm, warmer, light
--
-- NOTE: this is loaded after `kickstart.plugins.tokyonight`, so it wins and is
-- the active colorscheme. Toggle between the styles in `toggle_style_list`
-- with `<leader>tc` (see `lua/keymaps.lua`).
vim.pack.add { gh 'navarasu/onedark.nvim' }

require('onedark').setup {
  style = 'deep',
  toggle_style_list = { 'light', 'deep' },
}

-- Enable theme
require('onedark').load()

-- vim: ts=2 sts=2 sw=2 et
