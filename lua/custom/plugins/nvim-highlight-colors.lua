local function gh(repo) return 'https://github.com/' .. repo end

-- [[ nvim-highlight-colors ]]
-- Highlights colour literals (#rrggbb, rgb(), hsl(), tailwind classes, ...)
-- in the buffer with the colour they represent.
vim.pack.add { gh 'brenoprata10/nvim-highlight-colors' }

require('nvim-highlight-colors').setup {
  render = 'background', -- or 'foreground' or 'first_column'
}

-- vim: ts=2 sts=2 sw=2 et
