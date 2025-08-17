-- Marp for markdown presentations in Neovim
-- requires marp-cli to be installed
-- -- Install marp-cli globally using npm:
-- -- npm install -g @marp-team/marp-cli
return {
  {
    'mpas/marp-nvim',
    config = function()
      require('marp').setup {
        port = 8080,
        wait_for_response_timeout = 30,
        wait_for_response_delay = 1,
      }
    end,
  },
}
