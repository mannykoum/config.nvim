local function gh(repo) return 'https://github.com/' .. repo end

-- [[ markdown-preview.nvim ]]
-- Live markdown preview in the browser: `:MarkdownPreview` / `:MarkdownPreviewStop`.
--
-- The plugin ships a prebuilt preview server that has to be fetched once.
-- Register the build step *before* `vim.pack.add` so it also fires on the very
-- first install. Kept local (rather than in `lua/pack.lua`) so that upstream
-- kickstart merges stay conflict free.
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('custom-markdown-preview-build', { clear = true }),
  callback = function(ev)
    if ev.data.spec.name ~= 'markdown-preview.nvim' then return end
    if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end
    if not ev.data.active then vim.cmd.packadd 'markdown-preview.nvim' end
    vim.fn['mkdp#util#install']()
  end,
})

vim.pack.add { gh 'iamcco/markdown-preview.nvim' }

-- vim: ts=2 sts=2 sw=2 et
