return {
  "ibhagwan/fzf-lua",
  dependencies = { "echasnovski/mini.icons" },
  opts = {}, 
  keys = {
    {"<leader>ff", function() require('fzf-lua').files() end, desc="find files in the project directory"}, 
    {"<leader>fg", function() require("fzf-lua").live_grep() end, desc="live grep in the current project"}, 
    {"<leader>fc", function() require("fzf-lua").files({cwd=vim.fn.stdpath("config")}) end, desc="find in neovim configuration"}, 
    {"<leader>fb", function() require("fzf-lua").builtin() end, desc="list all the builtin commands for the fzf lua"}, 
    {"<leader>fh", function() require("fzf-lua").helptags() end, desc="find neovim docs help"}, 
    {"<leader>fk", function() require("fzf-lua").keymaps() end, desc="find keymaps"}, 
    {"<leader>fw", function() require("fzf-lua").grep_cword() end, desc="find current word under cursor"}, 
    {"<leader>fW", function() require("fzf-lua").grep_cWORD() end, desc="find current word considering space"}, 
    {"<leader>fd", function() require("fzf-lua").diagnostic_document() end, desc="find diagnostics"}, 
    {"<leader>fr", function() require("fzf-lua").resume() end, desc="resume search from previous buffer"}, 
    {"<leader>fo", function() require("fzf-lua").oldfiles() end, desc="find recent files"}, 
    {"<leader><leader>", function() require("fzf-lua").buffers() end, desc="find currently opened buffers"},  
    {"<leader>/", function() require("fzf-lua").lgrep_curbuf() end, desc="live grep through current buffer"}
  }
}
