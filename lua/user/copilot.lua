vim.g.copilot_filetypes = {
  ['*'] = false,
  ['javascript'] = true,
  ['typescript'] = true,
  ['lua'] = true,
  ['rust'] = true,
  ['c'] = true,
  ['c#'] = true,
  ['c++'] = true,
  ['go'] = true,
  ['python'] = true,
  ['bash'] = true,
  ['matlab'] = true,
  ['html'] = true,
  ['css'] = true,
  ['scss'] = true,
  ['sass'] = true,
  ['less'] = true,
  ['json'] = true,
  ['yaml'] = true,
  ['toml'] = true,
  ['markdown'] = true,
  ['vim'] = true,
  ['viml'] = true,
  ['sh'] = true,
}
vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap('i', '<C-l>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.keymap.set('i', '<C-j>', 'copilot#Next()', { expr = true, silent = true })
vim.keymap.set('i', '<C-k>', 'copilot#Previous()', { expr = true, silent = true })
