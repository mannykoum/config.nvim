local lspconfig = require 'lspconfig'
local util = lspconfig.util

-- Define a function that returns the project root directory
local project_root = util.root_pattern('.git', 'compile_commands.json', '.clangd', 'CMakeLists.txt', 'Makefile', 'compile_flags.txt', '.projectrc')
  or util.path.dir_name

lspconfig.clangd.setup {
  cmd = { 'clangd', '--header-insertion=never' },
  root_dir = project_root,
  on_attach = function(client, bufnr)
    -- Setup buffer-specific keymaps or settings here
  end,
  -- Pass specific flags or settings per project
  settings = {
    clangd = {
      compilationDatabaseDirectory = 'build',
    },
  },
}
