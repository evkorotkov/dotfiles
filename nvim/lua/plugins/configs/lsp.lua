vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(ev)
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions

    local function on_list(options)
      local items = {}
      local set = {}
      -- Filter not unique filenames because of issue with duplicates in ruby-lsp after saving files
      for i, v in pairs(options.items) do
        if not set[v.filename] then
          set[v.filename] = true
          table.insert(items, v)
        end
      end

      vim.fn.setqflist({}, ' ', vim.tbl_extend("keep", { items = items }, options))
      vim.cmd.cfirst()
    end

    local opts = { buffer = ev.buf }

    vim.keymap.set('n', 'gd', function()
      vim.lsp.buf.definition(vim.tbl_extend("keep", { on_list = on_list }, opts))
    end)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>vv", function()
      vim.lsp.buf.format { async = true }
    end, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
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
    'tsserver',
    'lua_ls',
    'tailwindcss',
    'emmet_ls',
  }
})

local lspconfig = require('lspconfig')
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
local get_servers = mason_lspconfig.get_installed_servers

for _, server_name in ipairs(get_servers()) do
  lspconfig[server_name].setup({
    capabilities = lsp_capabilities,
  })
end

-- override tsserver settings
lspconfig.tsserver.setup({
  settings = {
    diagnostics = {
      ignoredCodes = {
        7016, -- disable "could not find declaration file for module"
      },
    },
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
  cmd = { 'ruby-lsp' },
})
