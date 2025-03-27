return {
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 1000,
    dependencies = {
      {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
          require("rose-pine").setup({
            styles = {
              bold = false,
              italic = false,
              transparency = false,
            },
            highlight_groups = {
              ["@string.special.symbol.ruby"] = { fg = "gold" },
            },
          })
        end,
      },
      {
        "EdenEast/nightfox.nvim",
        config = function()
          require('nightfox').setup({
            groups = {
              all = {
                ["@string.special.symbol.ruby"] = { fg = "palette.green" },
                ["@variable.member.ruby"] = { fg = "palette.orange" },
                ["rubyTodo"] = { fg = "palette.comment", bg = "bg4" }
              }
            },
          })
        end,
      }
    },
    init = function()
      local function is_dark_mode()
        local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
        if not handle then
          return false
        end

        local result = handle:read("*a")
        handle:close()
        return result:match("Dark") ~= nil
      end

      if is_dark_mode() then
        -- vim.cmd("colorscheme duskfox")
        vim.cmd("colorscheme rose-pine-moon")
      else
        -- vim.cmd("colorscheme dawnfox")
        vim.cmd("colorscheme rose-pine-dawn")
      end
    end,
    config = function()
      local auto_dark_mode = require('auto-dark-mode')
      auto_dark_mode.setup({
        update_interval = 1000,
        set_dark_mode = function()
          vim.api.nvim_set_option_value('background', 'dark', {})
          -- vim.cmd("colorscheme duskfox")
          vim.cmd("colorscheme rose-pine-moon")

          -- https://github.com/neovim/neovim/issues/23590
          vim.cmd('hi! link CurSearch Search')
        end,
        set_light_mode = function()
          vim.api.nvim_set_option_value('background', 'light', {})
          -- vim.cmd("colorscheme dawnfox")
          vim.cmd("colorscheme rose-pine-dawn")

          -- https://github.com/neovim/neovim/issues/23590
          vim.cmd('hi! link CurSearch Search')
        end,

      })
    end
  }
}
