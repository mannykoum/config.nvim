vim.g.copilot_filetypes = {
  ['*'] = true,
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

vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', { replace_keycodes = false, expr = true })

vim.keymap.set('i', '<C-L>', 'copilot#Next()', { expr = true, silent = true })
vim.keymap.set('i', '<C-K>', 'copilot#Previous()', { expr = true, silent = true })

function globHome(partialNames, maxDepth)
  local home = os.getenv 'HOME' -- Gets the user's home directory
  local command = 'find ' .. home .. ' -type d -maxdepth ' .. tostring(maxDepth) -- Start constructing the command

  if #partialNames > 0 then
    command = command .. ' \\( ' -- Start of the OR grouping
    for i, name in ipairs(partialNames) do
      command = command .. '-name "*' .. name .. '*"'
      if i < #partialNames then
        command = command .. ' -o ' -- OR operator
      end
    end
    command = command .. ' \\)' -- End of the OR grouping
  end

  local directories = {}

  -- Execute the command and capture the output
  local pipe = io.popen(command, 'r')
  if not pipe then
    return nil, 'Failed to open pipe'
  end

  -- Read each line from the command output
  for line in pipe:lines() do
    table.insert(directories, line)
  end

  -- Close the pipe
  pipe:close()

  return directories
end

local matchedDirectories, err = globHome({ 'polarfire-embedded', 'z7000cam', 'z7', 'csp' }, 3)
if not matchedDirectories then
  print('Error:', err)
  -- else
  --   print 'Found directories:'
  --   for _, directory in ipairs(matchedDirectories) do
  --     print(directory)
  --   end
end
vim.g.copilot_workspace_folders = matchedDirectories
