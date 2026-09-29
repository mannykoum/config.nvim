-- [[ PICO-8 ]]
--  Filetype, highlighting and a tmux-aware runner for PICO-8 carts.
--  The LSP (pico8_ls, installed by Mason) is enabled in `kickstart/plugins/lspconfig.lua`.
--
--  Recommended layout: keep code in `*.p8.lua` files and pull them into the cart with
--  `#include main.p8.lua` in its `__lua__` section. PICO-8 then owns the `.p8` (sprites, sfx, map)
--  and Neovim owns the code, so the two never overwrite each other.
--
--  Keymaps (in p8 buffers):
--    <leader>pr  save and (re)launch the cart
--    <leader>pk  kill the running cart
--    <leader>pt  toggle launching in a tmux window or a side pane
--
--  PICO-8 always draws in its own graphical window. Inside tmux, the launcher (and `printh` output)
--  goes to a background window named `pico8`, or to a side pane when `vim.g.pico8_tmux_target = 'pane'`.
--  With PICO-8 already open, Ctrl-R in PICO-8 re-reads changed files from disk and reruns the cart.

vim.filetype.add {
  extension = { p8 = 'p8' },
  pattern = { ['.*%.p8%.lua'] = 'p8' },
}

-- PICO-8 code is (mostly) Lua, so borrow the Lua parser for highlighting
vim.treesitter.language.register('lua', 'p8')

local tmux_window = 'pico8'
local pane_id
local job_id

---Find the cart to run for the current buffer: the file itself, or a `.p8` next to an included `.p8.lua`.
---@param callback fun(cart: string)
local function with_cart(callback)
  local file = vim.api.nvim_buf_get_name(0)
  if file:match '%.p8$' then return callback(file) end

  if vim.b.pico8_cart and vim.uv.fs_stat(vim.b.pico8_cart) then return callback(vim.b.pico8_cart) end

  local carts = vim.fn.glob(vim.fs.joinpath(vim.fs.dirname(file), '*.p8'), false, true)
  if #carts == 0 then return vim.notify('No .p8 cart found next to ' .. vim.fn.fnamemodify(file, ':t'), vim.log.levels.WARN) end
  if #carts == 1 then
    vim.b.pico8_cart = carts[1]
    return callback(carts[1])
  end

  local buf = vim.api.nvim_get_current_buf()
  vim.ui.select(carts, { prompt = 'PICO-8 cart', format_item = function(c) return vim.fn.fnamemodify(c, ':t') end }, function(choice)
    if not choice then return end
    vim.b[buf].pico8_cart = choice
    callback(choice)
  end)
end

local function kill()
  if vim.env.TMUX then
    if pane_id then
      vim.system({ 'tmux', 'kill-pane', '-t', pane_id }):wait()
      pane_id = nil
    end
    vim.system({ 'tmux', 'kill-window', '-t', ':' .. tmux_window }):wait()
  end
  if job_id then
    vim.fn.jobstop(job_id)
    job_id = nil
  end
end

local function toggle_target()
  vim.g.pico8_tmux_target = (vim.g.pico8_tmux_target or 'window') == 'pane' and 'window' or 'pane'
  vim.notify('PICO-8 launches in a tmux ' .. vim.g.pico8_tmux_target)
end

local function run()
  vim.cmd 'silent! wall'
  with_cart(function(cart)
    kill()
    local dir = vim.fs.dirname(cart)
    if vim.env.TMUX then
      -- Keep the window open after PICO-8 exits so `printh` output and errors stay readable
      local shell_cmd = ('pico8 -run %s; printf "\\n[pico8 exited: %%s]\\n" $?; read -r _'):format(vim.fn.shellescape(cart))
      if (vim.g.pico8_tmux_target or 'window') == 'pane' then
        local result =
          vim.system({ 'tmux', 'split-window', '-d', '-h', '-l', '30%', '-t', vim.env.TMUX_PANE or '', '-P', '-F', '#{pane_id}', '-c', dir, shell_cmd }):wait()
        pane_id = vim.trim(result.stdout or '')
      else
        vim.system { 'tmux', 'new-window', '-d', '-n', tmux_window, '-c', dir, shell_cmd }
      end
    else
      job_id = vim.fn.jobstart({ 'pico8', '-run', cart }, { cwd = dir, detach = true })
    end
  end)
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('custom-pico8', { clear = true }),
  pattern = 'p8',
  callback = function(args)
    vim.bo[args.buf].commentstring = '-- %s'
    vim.keymap.set('n', '<leader>pr', run, { buffer = args.buf, desc = 'PICO-8: [R]un cart' })
    vim.keymap.set('n', '<leader>pk', kill, { buffer = args.buf, desc = 'PICO-8: [K]ill cart' })
    vim.keymap.set('n', '<leader>pt', toggle_target, { buffer = args.buf, desc = 'PICO-8: [T]oggle tmux window/pane' })
  end,
})

local ok, which_key = pcall(require, 'which-key')
if ok then which_key.add { { '<leader>p', group = '[P]ICO-8' } } end

-- vim: ts=2 sts=2 sw=2 et
