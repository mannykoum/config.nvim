return {
  {
    -- Theme inspired by Atom
    -- styles: dark, darker, deep, cool, warm, warmer, light
    'navarasu/onedark.nvim',
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('onedark').setup {
        style = 'deep',
        toggle_style_list = { 'light', 'deep' },
      }
      -- Enable theme
      require('onedark').load()
    end,
  },
}
