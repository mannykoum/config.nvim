local function gh(repo) return 'https://github.com/' .. repo end

-- [[ Marp ]]
-- Marp for markdown presentations in Neovim.
-- Requires marp-cli to be installed, e.g. install it globally using npm:
--   npm install -g @marp-team/marp-cli
--
-- Use `:MarpToggle` to start/stop the live preview server.
vim.pack.add { gh 'mpas/marp-nvim' }

require('marp').setup {
  port = 8080,
  wait_for_response_timeout = 30,
  wait_for_response_delay = 1,
}

-- vim: ts=2 sts=2 sw=2 et
