local function gh(repo) return 'https://github.com/' .. repo end

-- [[ CLI coding agents ]]
--
-- `codecompanion.nvim` runs an agent CLI inside a Neovim terminal (its "CLI
-- interaction") and lets you hand that agent context from the current buffer
-- without leaving the editor.
--
-- Each CLI authenticates itself -- through its own `login` flow, or whatever it
-- already reads from the environment -- so no API keys or secrets belong in
-- this config.
--
-- See https://codecompanion.olimorris.dev/usage/cli
--
-- The agents below are listed in preference order: `cmd` is looked up on $PATH
-- once, at startup, only the agents found there are ever exposed, and the first
-- of those becomes the default.
local candidates = {
  { name = 'claude_code', cmd = 'claude', args = {}, description = 'Claude Code' },
  { name = 'codex', cmd = 'codex', args = {}, description = 'OpenAI Codex' },
  -- `--cli` pins Hermes to its plain REPL, which behaves in a terminal buffer.
  -- (`hermes acp` also exists, if you would rather drive it over ACP.)
  { name = 'hermes', cmd = 'hermes', args = { '--cli' }, description = 'Hermes Agent' },
}

local agents, installed = {}, {}
for _, candidate in ipairs(candidates) do
  if vim.fn.executable(candidate.cmd) == 1 then
    table.insert(installed, candidate.name)
    agents[candidate.name] = {
      cmd = candidate.cmd,
      args = candidate.args,
      description = candidate.description,
      provider = 'terminal',
    }
  end
end

-- With nothing to drive, there is no point installing the plugin or claiming
-- the `<leader>a` prefix -- just say so, once, after startup has settled.
if vim.tbl_isempty(installed) then
  vim.schedule(
    function()
      vim.notify('No agent CLI found on $PATH.\nInstall `claude`, `codex` or `hermes`, then restart Neovim.', vim.log.levels.WARN, { title = 'CLI agents' })
    end
  )
  return
end

vim.pack.add { { src = gh 'olimorris/codecompanion.nvim', version = vim.version.range '19.*' } }

local codecompanion = require 'codecompanion'

codecompanion.setup {
  interactions = {
    cli = {
      agent = installed[1],
      agents = agents,
      opts = {
        auto_insert = true, -- Start typing as soon as the terminal is focused
      },
    },
  },
}

-- The agent every mapping below talks to. CodeCompanion routes an unqualified
-- call to whichever terminal was used last, then falls back to the configured
-- default once that terminal is gone -- so tracking the choice here and passing
-- it explicitly is what keeps `<leader>ap` sticky. It also means the prompt
-- built below and the terminal it is sent to are decided by the same value, and
-- so can never disagree about which agent is listening.
local active = installed[1]

---Open a named agent in its own terminal.
---@param name string Key from the `agents` table above
local function open(name)
  if not agents[name] then return vim.notify(('Unknown or unavailable agent: %s'):format(name), vim.log.levels.ERROR, { title = 'CLI agents' }) end
  active = name
  codecompanion.cli { agent = name }
end

---Choose one of the installed agents and open it.
local function select()
  vim.ui.select(installed, {
    prompt = 'Agent CLI:',
    format_item = function(name) return ('%s (%s)'):format(agents[name].description, agents[name].cmd) end,
  }, function(name)
    if name then open(name) end
  end)
end

---Show or hide the active agent's terminal, starting it if it isn't running.
local function toggle() codecompanion.toggle_cli { agent = active } end

-- `:Agent` with no argument toggles whichever agent you last opened; with a
-- name it opens that one. `:AgentSelect` is the same picker as `<leader>ap`.
vim.api.nvim_create_user_command('Agent', function(cmd)
  if cmd.args == '' then
    toggle()
  else
    open(cmd.args)
  end
end, {
  nargs = '?',
  complete = function(lead)
    return vim.tbl_filter(function(name) return vim.startswith(name, lead) end, installed)
  end,
  desc = 'Toggle the last agent, or open one by name',
})

vim.api.nvim_create_user_command('AgentSelect', select, { desc = 'Pick an agent CLI to open' })

-- [[ Sending context ]]
--
-- `#{this}` is the visual selection in visual mode and the whole buffer in
-- normal mode. Context is inserted but not submitted, so you can add to it
-- before hitting enter. See `:h codecompanion-editor-context`.
--
-- A visual selection is inlined as literal text, which every agent can read. A
-- whole buffer is not: CodeCompanion expands it to a bare `@path` token -- the
-- same token `/file` and `/buffer` insert in the prompt buffer. Claude Code and
-- Codex read that as a file reference. Hermes does not: it only matches
-- `@file:`, `@folder:`, `@git:`, `@url:`, `@diff` and `@staged`, so a bare
-- `@path` arrives as prose and the file is never attached. CodeCompanion has no
-- per-agent hook to rewrite those tokens, so build the reference ourselves for
-- the one case we own -- and see `dependencies.md` for the slash commands,
-- which stay a manual `@file:` away for Hermes users.

-- An unquoted Hermes reference is matched as `\S+`, so a path with whitespace
-- or brackets in it would parse as a truncated reference and leave the tail
-- behind as loose text. Mirrors its own `format_reference_value`.
local NEEDS_QUOTING = '[%s()%[%]{}<>"\'`]'

---Build a Hermes file reference for a path.
---@param path string
---@return string
local function hermes_file_ref(path)
  if not path:find(NEEDS_QUOTING) then return '@file:' .. path end
  for _, quote in ipairs { '`', '"', "'" } do
    if not path:find(quote, 1, true) then return ('@file:%s%s%s'):format(quote, path, quote) end
  end
  return '@file:' .. path -- Every quote Hermes accepts is already in the path
end

---The prompt `<leader>as` sends, or nil when there is nothing to send.
---@return string|nil
local function context_prompt()
  local mode = vim.fn.mode():sub(1, 1)
  if mode == 'v' or mode == 'V' or mode == '\22' or active ~= 'hermes' then return '#{this}' end

  local name = vim.api.nvim_buf_get_name(0)
  if name == '' or vim.fn.filereadable(name) == 0 then
    vim.notify(
      'Hermes attaches files from disk, and this buffer has none.\nWrite it first, or select the lines you want to send.',
      vim.log.levels.WARN,
      { title = 'CLI agents' }
    )
    return nil
  end

  -- Absolute, because the terminal keeps the working directory it started in:
  -- a relative path would quietly resolve against the wrong root after a `:cd`.
  return hermes_file_ref(vim.fn.fnamemodify(name, ':p'))
end

local function send_context()
  local prompt = context_prompt()
  if prompt then codecompanion.cli(prompt, { agent = active }) end
end

local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { desc = desc }) end

map('n', '<leader>aa', toggle, 'Toggle [a]gent')
map('n', '<leader>ap', select, '[P]ick agent')
map({ 'n', 'x' }, '<leader>ak', function() codecompanion.cli { prompt = true, agent = active } end, 'As[k] agent')
map({ 'n', 'x' }, '<leader>as', send_context, '[S]end context to agent')
map('n', '<leader>ad', function() codecompanion.cli('Fix #{diagnostics}', { agent = active }) end, 'Send [d]iagnostics to agent')

-- Document the new prefix. `which-key` is loaded ahead of `custom.plugins` in
-- `lua/plugins.lua`, but guard anyway so reordering can't break startup.
local ok, which_key = pcall(require, 'which-key')
if ok then which_key.add { { '<leader>a', group = '[A]gent', mode = { 'n', 'x' } } } end

-- vim: ts=2 sts=2 sw=2 et
