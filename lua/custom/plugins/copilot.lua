-- return {
--   'github/copilot.vim',
-- }
-- Copilot settings and keymaps as written in MariaSolOs/dotfiles
-- currently, using the cmp integration from zbirenbaum/copilot-cmp mostly
-- return {
-- {
--   'zbirenbaum/copilot.lua',
--   cmd = 'Copilot',
--   event = 'InsertEnter',
--   opts = {
--     suggestion = {
--       auto_trigger = true,
--       -- Use alt to interact with Copilot.
--       keymap = {
--         -- Disable the built-in mapping, we'll configure it in nvim-cmp.
--         accept = false,
--         accept_word = '<M-w>',
--         accept_line = '<M-l>',
--         next = '<M-]>',
--         prev = '<M-[>',
--         dismiss = '/',
--       },
--     },
--     filetypes = { markdown = true },
--   },
--   config = function(_, opts)
--     local cmp = require 'cmp'
--     local copilot = require 'copilot.suggestion'
--     local luasnip = require 'luasnip'
--
--     require('copilot').setup(opts)
--
--     local function set_trigger(trigger)
--       vim.b.copilot_suggestion_auto_trigger = trigger
--       vim.b.copilot_suggestion_hidden = not trigger
--     end
--
--     -- Hide suggestions when the completion menu is open.
--     cmp.event:on('menu_opened', function()
--       if copilot.is_visible() then
--         copilot.dismiss()
--       end
--       set_trigger(false)
--     end)
--
--     -- Disable suggestions when inside a snippet.
--     cmp.event:on('menu_closed', function()
--       set_trigger(not luasnip.expand_or_locally_jumpable())
--     end)
--     vim.api.nvim_create_autocmd('User', {
--       pattern = { 'LuasnipInsertNodeEnter', 'LuasnipInsertNodeLeave' },
--       callback = function()
--         set_trigger(not luasnip.expand_or_locally_jumpable())
--       end,
--     })
--   end,
-- },
-- }
return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = false,
        },
        filetypes = {
          -- Default enabled filetypes
          -- Add more filetypes as needed
          markdown = true,
          help = false,
          gitcommit = true,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ['.'] = false,
        },
        copilot_node_command = 'node', -- Node.js version must be > 16.x
        server_opts_overrides = {},
      }
    end,
  },
  {
    'zbirenbaum/copilot-cmp',
    dependencies = { 'zbirenbaum/copilot.lua' },
    config = function()
      require('copilot_cmp').setup {
        method = 'getCompletionsCycling',
        formatters = {
          label = require('copilot_cmp.format').format_label_text,
          insert_text = require('copilot_cmp.format').format_insert_text,
          preview = require('copilot_cmp.format').deindent,
        },
      }
    end,
  },
}
