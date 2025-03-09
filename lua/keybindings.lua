-- set the vertical bar at 80 characters
vim.cmd 'set colorcolumn=80'

-- exit insert mode with jj
vim.api.nvim_set_keymap('i', 'jj', '<Esc>', { noremap = true })
