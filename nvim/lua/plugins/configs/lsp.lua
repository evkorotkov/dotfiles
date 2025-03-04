return {
  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      { 'williamboman/mason-lspconfig.nvim' },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local opts = { buffer = event.buf }
          local map = vim.keymap.set

          map('n', 'gd', vim.lsp.buf.definition, opts)
          map('n', 'gD', vim.lsp.buf.declaration, opts)
          map('n', 'gI', vim.lsp.buf.implementation, opts)
          map('n', 'K', vim.lsp.buf.hover, opts)
          map('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          map("n", "<leader>vv", function() vim.lsp.buf.format { async = true } end, opts)
          map('n', '<leader>rn', vim.lsp.buf.rename, opts)
          map('n', '[d', vim.diagnostic.goto_prev)
          map('n', ']d', vim.diagnostic.goto_next)
          map('n', '<leader>to', vim.diagnostic.setqflist)
          map('n', '<leader>tl', vim.diagnostic.open_float)
          map({ 'n', 'v' }, '<leader>ta', vim.lsp.buf.code_action, opts)
        end
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          client.server_capabilities.semanticTokensProvider = nil
        end,
      })

      --
      -- Diagnostics UI
      --
      vim.diagnostic.config({
        underline = true,
        virtual_text = false,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.HINT] = '',
            [vim.diagnostic.severity.INFO] = '',
          },
        },
        update_in_insert = false,
        float = {
          source = "always",
          border = "rounded",
        },
        severity_sort = false,
      })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover,
        { border = 'rounded' }
      )
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        { border = 'rounded' }
      )

      --
      -- Servers overrides
      --
      local servers = {
        ts_ls = {
          settings = {
            diagnostics = {
              ignoredCodes = {
                7016, -- disable "could not find declaration file for module"
              },
            },
          },
        },

        tailwindcss = {
          filetypes = { 'ruby', 'eruby', 'slim' },
          settings = {
            tailwindCSS = {
              includeLanguages = {
                ruby = "erb",
              },
              experimental = {
                classRegex = {
                  [[class= "([^"]*)]],
                  [[class: "([^"]*)]],
                  [[class= '([^"]*)]],
                  [[class: '([^"]*)]],
                  '~H""".*class="([^"]*)".*"""',
                  '~F""".*class="([^"]*)".*"""',
                },
              }
            }
          }
        },

        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { 'vim' }
              },
            }
          }
        },

        ruby_lsp = {
          filetypes = { 'ruby', 'eruby', 'slim' },
        },

        yamlls = {
          settings = {
            yaml = {
              validate = false,
              schemaStore = {
                enable = false,
                url = "",
              },
              schemas = {
                ['https://json.schemastore.org/github-workflow.json'] = '.github/workflows/*.{yml,yaml}',
                ["https://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
                kubernetes = "templates/**",
              }
            }
          }
        },
      }

      local lspconfig = require('lspconfig')
      lspconfig.sourcekit.setup({
        capabilities = {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        }
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      require('mason-lspconfig').setup({
        ensure_installed = {
          'eslint',
          'ts_ls',
          'lua_ls',
          'tailwindcss',
          'terraformls',
          'tflint',
          'yamlls',
          'ruby_lsp',
        },
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}

            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            lspconfig[server_name].setup(server)
          end,
        },
      })
    end,
  },
}
