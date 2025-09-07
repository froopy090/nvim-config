-- froopy's init.lua :)

-- Set leader key
vim.g.mapleader = ' '
vim.g.NERDTreeShowDevIcons = 1

-- Basic settings
-- set termguicolors
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.hlsearch = false        -- Do not highlight search results
vim.opt.hidden = true           -- Enable background buffers
vim.opt.wrap = false            -- Disable line wrap

-- Indentation settings
vim.opt.tabstop = 4             -- Number of spaces for a tab
vim.opt.shiftwidth = 4          -- Number of spaces for indentation
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.smartindent = true      -- Enable smart indentation
vim.opt.clipboard = "unnamedplus"      -- Allows me to use system clipboard

-- Error messages
vim.diagnostic.config({
  virtual_text = true, -- inline text
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- Plugin management
-- Using 'packer.nvim' for plugin management
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd 'packadd packer.nvim'
end

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'  -- Package manager

  -- Syntax highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- LSP 
  use 'neovim/nvim-lspconfig'

  -- Autocompletion
  use 'hrsh7th/nvim-cmp'         -- Completion plugin
  use 'hrsh7th/cmp-nvim-lsp'     -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-buffer'       -- Buffer source for nvim-cmp
  use 'hrsh7th/cmp-path'         -- Path source for nvim-cmp
  use 'hrsh7th/cmp-cmdline'      -- Cmdline source for nvim-cmp
  use 'L3MON4D3/LuaSnip'         -- Snippets plugin
  use 'saadparwaiz1/cmp_luasnip'

  -- LSP UI enhancements
  use {
    'nvimdev/lspsaga.nvim',
    config = function()
      require('lspsaga').setup({})
    end,
  }

  -- File explorer
  use 'preservim/nerdtree'

  -- Icons 
  use 'kyazdani42/nvim-web-devicons' -- Required by nerdtree

  -- Telescope for fuzzy finding
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  -- Which-key to show keymaps
  use 'folke/which-key.nvim'

  -- Dispatch for running commands
    use 'tpope/vim-dispatch'

  -- Status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }  -- optional dependency for icons
  }
--  Theme
    use("oxfist/night-owl.nvim")
end) 

--Which-key configuration
require("which-key").setup{
  -- leaving blank for default settings    
}

-- Treesitter configuration
require'nvim-treesitter.configs'.setup {

  ensure_installed = { "c", "cpp", "lua", "python", "java" },
  highlight = {
    enable = true,
  },
}

-- LSP configuration
local nvim_lsp = require('lspconfig')
local web_lsp_servers = {'tailwindcss', 'ts_ls', 'jsonls', 'eslint'}

-- Function to set up common settings for each LSP
local on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_buf_set_option(bufnr, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', { noremap = true, silent = true })
    end
end

-- LSP server configurations
-- C++
nvim_lsp.clangd.setup {
    on_attach = on_attach,
    cmd = { "clangd", "--compile-commands-dir=./", "--header-insertion=never" },
}

-- Python 
-- Enable pyright for Python LSP
nvim_lsp.pyright.setup {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    on_attach = function(client, bufnr)
	local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
	local opts = { noremap=true, silent=true }

	-- LSP keybindings
	buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    	buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
   	buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    	buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    	buf_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
   	buf_set_keymap('n', '<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
end
}

-- Typescript/javascript, html, and css 
for _, lsp in pairs(web_lsp_servers) do 
    nvim_lsp[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end 

nvim_lsp.cssls.setup{
    on_attach = on_attach,
    capabilities = capabilities
}
nvim_lsp.html.setup{
    on_attach = on_attach,
    capabilities = capabilities
}

-- nvim-cmp setup (for autocompletion)
local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = {
        ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'path' },
    },
})

-- Telescope configuration
require('telescope').setup{
  defaults = {
    -- No config for now 
  }
}

-- Theme configuration 
-- require("night-owl").setup()
-- vim.cmd.colorscheme("night-owl")

-- Key mappings for Telescope
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'J', ":m '>+1<CR>gv=gc", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'K', ":m '>-2<CR>gv=gc", { noremap = true, silent = true })


-- Key mappings for NERDTree
vim.api.nvim_set_keymap('n', '<leader>n', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
