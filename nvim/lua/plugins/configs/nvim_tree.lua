vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  disable_netrw = true,

  filters = {
    custom = {
      ".git$",
      "\\.ruby-lsp$",
      ".DS_Store",
    },
    git_ignored = false,
  },

  hijack_cursor = true,

  view = {
    width = 40,
    preserve_window_proportions = true,
  },

  git = {
    enable = false,
    -- timeout = 10000, -- default 400, git integration turns off after 10 attempts. increased to fix issue with 1password
  },

  modified = {
    enable = false,
  },

  diagnostics = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    root_folder_modifier = ":t",
    special_files = {},
    indent_markers = {
      enable = true,
    },
    icons = {
      show = {
        folder_arrow = false,
        git = false
      }
    },
  },
})

vim.keymap.set('n', '<leader>re', function ()
  vim.cmd('NvimTreeFindFile')
  vim.cmd('normal! zz')
end, { silent = true })
vim.keymap.set('n', '<leader>rt', ':NvimTreeToggle<cr>', { silent = true })
