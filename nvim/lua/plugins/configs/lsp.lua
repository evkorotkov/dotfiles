return {
  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(ev)

          local function go_to_unique_definition()
            vim.lsp.buf_request(0, 'textDocument/definition', vim.lsp.util.make_position_params(), function(_, result, _, _)
              if not result or vim.tbl_isempty(result) then
                print("No definitions found")
                return
              end

              local unique_results = {}
              local seen = {}

              for _, def in ipairs(result) do
                local uri = def.uri or def.targetUri
                seen[uri] = def
              end

              for _, def in pairs(seen) do
                table.insert(unique_results, def)
              end

              if #unique_results == 1 then
                vim.lsp.util.jump_to_location(unique_results[1], 'utf-8')
              else
                local items = vim.lsp.util.locations_to_items(unique_results, 'utf-8')
                vim.fn.setqflist({}, 'r', { title = 'LSP Definitions', items = items })
                vim.api.nvim_command("copen")
              end
            end)
          end

          local opts = { buffer = ev.buf }

          vim.keymap.set('n', 'gd', go_to_unique_definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<leader>vv", function()
            vim.lsp.buf.format { async = true }
          end, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
          vim.keymap.set({ 'n', 'v' }, '<space>co', vim.lsp.buf.code_action, opts)
        end
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          client.server_capabilities.semanticTokensProvider = nil
        end,
      })

      local mason_lspconfig = require('mason-lspconfig')

      require('mason').setup()
      mason_lspconfig.setup({
        ensure_installed = {
          'eslint',
          'ts_ls',
          'lua_ls',
          'tailwindcss',
          'terraformls',
          'tflint',
          'yamlls'
        }
      })

      local lspconfig = require('lspconfig')
      local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
      local get_servers = mason_lspconfig.get_installed_servers

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover,
      { border = 'rounded' }
      )
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
      vim.lsp.handlers.signature_help,
      { border = 'rounded' }
      )

      for _, server_name in ipairs(get_servers()) do
        lspconfig[server_name].setup({
          capabilities = lsp_capabilities,
        })
      end

      local signs = {
        { name = 'DiagnosticSignError', text = '' },
        { name = 'DiagnosticSignWarn', text = '' },
        { name = 'DiagnosticSignHint', text = '' },
        { name = 'DiagnosticSignInfo', text = '' },
      }

      for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = '' })
      end

      vim.diagnostic.config({
        underline = true,
        virtual_text = false,
        signs = true,
        update_in_insert = false,
        float = {
          source = "always",
          border = "rounded",
        },
        severity_sort = false,
      })

      -- override tsserver settings
      lspconfig.ts_ls.setup({
        settings = {
          diagnostics = {
            ignoredCodes = {
              7016, -- disable "could not find declaration file for module"
            },
          },
        },
      })

      lspconfig.tailwindcss.setup({
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
      })

      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            }
          }
        }
      })

      lspconfig.ruby_lsp.setup({
        filetypes = { 'ruby', 'eruby', 'slim' },
        cmd = { 'ruby-lsp' },
      })

      lspconfig.yamlls.setup({
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
      })

      lspconfig.sourcekit.setup {
        capabilities = {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        },
      }
    end,
  },
}
