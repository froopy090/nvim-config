-- init.lua

-- Set leader key
vim.g.mapleader = ' '

-- Basic settings
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = false   -- Show relative line numbers
vim.opt.hlsearch = false        -- Do not highlight search results
vim.opt.hidden = true           -- Enable background buffers
vim.opt.wrap = false            -- Disable line wrap

-- Indentation settings
vim.opt.tabstop = 4             -- Number of spaces for a tab
vim.opt.shiftwidth = 4          -- Number of spaces for indentation
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.smartindent = true      -- Enable smart indentation
vim.opt.clipboard = "unnamedplus"      -- Allows me to use system clipboard

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

  -- LSP configuration
  use 'neovim/nvim-lspconfig'

  -- Autocompletion
  use 'hrsh7th/nvim-cmp'         -- Completion plugin
  use 'hrsh7th/cmp-nvim-lsp'     -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-buffer'       -- Buffer source for nvim-cmp
  use 'hrsh7th/cmp-path'         -- Path source for nvim-cmp
  use 'hrsh7th/cmp-cmdline'      -- Cmdline source for nvim-cmp
  use 'L3MON4D3/LuaSnip'         -- Snippets plugin

  -- LSP UI enhancements
  use {
    'nvimdev/lspsaga.nvim',
    config = function()
      require('lspsaga').setup({})
    end,
  }
  
  -- File explorer
  use 'preservim/nerdtree'

  -- Telescope for fuzzy finding
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  -- Which-key to show keymaps
  use 'folke/which-key.nvim'

  -- Themes :)
  use { "catppuccin/nvim", as = "catppuccin" }
end) 

--Which-key configuration
require("which-key").setup{
    plugins = {
    marks = true, -- shows a list of marks
    registers = true, -- shows your registers
    spelling = {
      enabled = true, -- enable highlighting of misspelled words
      suggestions = 20, -- how many suggestions should be shown
    },
    presets = {
      operators = true, -- adds help for operators like d, y, ...
      motions = true, -- adds help for motions
      text_objects = true, -- help for text objects triggered after entering an operator
      windows = true, -- default bindings on <c-w>
      nav = true, -- basic navigation
      z = true, -- bindings for folds, spelling and others prefixed with z
      g = true, -- bindings for prefixed with g
    },
  },
  -- other configurations go here
}

-- Treesitter configuration
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "cpp", "lua", "python" },
  highlight = {
    enable = true,
  },
}

-- LSP configuration
local lspconfig = require'lspconfig'

-- Function to set up common settings for each LSP
local on_attach = function(client, bufnr)
    -- Enable LSP-based formatting, this autoformats the code
    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_buf_set_option(bufnr, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', { noremap = true, silent = true })
    end
end

-- C++ LSP
lspconfig.clangd.setup{}

-- Autocompletion configuration
local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
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
    -- Your telescope configuration here
  }
}

-- Catpppuccin configurations
require("catppuccin").setup({
    flavour = "auto", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    color_overrides = {},
    custom_highlights = {},
    default_integrations = true,
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
            enabled = true,
            indentscope_color = "",
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
})

-- setup must be called before loading
vim.cmd.colorscheme "catppuccin"

-- Key mappings for Telescope
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'J', ":m '>+1<CR>gv=gc", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'K', ":m '>-2<CR>gv=gc", { noremap = true, silent = true })


-- Key mappings for NERDTree
vim.api.nvim_set_keymap('n', '<leader>n', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
