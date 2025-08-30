return {
  "rebelot/kanagawa.nvim",
  config = function()
    require("kanagawa").setup({
      compile = true,
      transparent = true, -- don’t set a background
      overrides = function(colors)
        return {
          -- Normal       = { bg = "none" },
          -- NormalFloat  = { bg = "none" },
          -- SignColumn   = { bg = "none" },
          -- VertSplit    = { bg = "none" },
          -- StatusLine   = { bg = "none" },
          -- WinSeparator = { bg = "none" },
          ['@markup.link.url.markdown_inline'] = {link = "Special"}, 
          ['@markup.link.label.markdown_inline'] = {link = "WarningMsg"}, 
          ['@markup.italic.markdown_inline'] = {link = "Exception"}, 
          ['@markup.raw.markdown_inline'] = {link = "String"}, 
          ['@markup.list.markdown'] = {link = "Function"}, 
          ['@markup.quote.markdown'] = {link = 'Error'}, 
        }
      end,
    })
    vim.cmd("colorscheme kanagawa")
  end,
  build = function()
    vim.cmd("KanagawaCompile")
  end,
}

