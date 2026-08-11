local function gh(repo) return 'https://github.com/' .. repo end

-- [[ GitHub Copilot ]]
--
-- Copilot is driven by `copilot.lua`, with its own inline suggestions and panel
-- turned off: completions are surfaced as regular items inside the completion
-- menu instead.
--
-- Under nvim-cmp that wiring was `zbirenbaum/copilot-cmp`. Kickstart now uses
-- blink.cmp, so the equivalent bridge is `fang2hou/blink-copilot`, which is
-- registered as the `copilot` source in `lua/kickstart/plugins/blink-cmp.lua`.
vim.pack.add {
  gh 'zbirenbaum/copilot.lua',
  gh 'fang2hou/blink-copilot',
}

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

-- vim: ts=2 sts=2 sw=2 et
