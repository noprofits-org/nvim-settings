-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

-- Plugin setup
require("lazy").setup({
  -- Custom high-contrast theme based on your screenshot
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = true,
        styles = {
          comments = { italic = false, bold = true },
          keywords = { italic = false, bold = true },
          functions = { italic = false, bold = false },
          variables = { },
        },
        on_colors = function(colors)
          -- Force black background
          colors.bg = "#000000"
          colors.bg_dark = "#000000"
          colors.bg_float = "#000000"
          colors.bg_sidebar = "#000000"
          colors.bg_statusline = "#000000"
          
          -- Bright foreground colors
          colors.fg = "#ffffff"
          colors.comment = "#00ff00"  -- Bright green comments
          colors.blue = "#00ffff"     -- Cyan for functions
          colors.cyan = "#00ffff"     -- Cyan
          colors.purple = "#ff00ff"   -- Magenta
          colors.green = "#00ff00"    -- Bright green
          colors.orange = "#ff9900"   -- Bright orange
        end,
        on_highlights = function(hl, c)
          -- Force specific highlight overrides to match your screenshot
          hl.Comment = { fg = "#00ff00", bold = true }  -- Bright green comments
          hl.Keyword = { fg = "#00ffff", bold = true }  -- Bright cyan keywords
          hl.Function = { fg = "#00ffff" }              -- Bright cyan functions
          hl.String = { fg = "#ffff00" }                -- Bright yellow strings
          hl.Identifier = { fg = "#ffffff" }            -- White identifiers
          hl.Operator = { fg = "#ffffff" }              -- White operators
          hl.Special = { fg = "#ff00ff" }               -- Bright magenta special chars
          hl.LineNr = { fg = "#444444" }                -- Subtle line numbers
          hl.CursorLineNr = { fg = "#888888" }          -- Brighter current line number
          
          -- Set very bright syntax for key elements
          hl.Statement = { fg = "#00ffff", bold = true }
          hl.PreProc = { fg = "#ff00ff", bold = true }
          hl.Type = { fg = "#00ff00", bold = true }
          
          -- TreeSitter overrides
          hl["@function"] = { fg = "#00ffff" }
          hl["@keyword"] = { fg = "#00ffff", bold = true }
          hl["@string"] = { fg = "#ffff00" }
          hl["@comment"] = { fg = "#00ff00", bold = true }
          hl["@property"] = { fg = "#ff00ff" }
          hl["@parameter"] = { fg = "#ffffff" }
          hl["@variable"] = { fg = "#ffffff" }
          hl["@constant"] = { fg = "#ff9900" }
        end
      })
      vim.cmd.colorscheme("tokyonight")
      
      -- Force black background to be sure
      vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup {}
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup { 
        options = { 
          theme = "tokyonight",
          component_separators = { left = '|', right = '|'},
          section_separators = { left = '', right = ''},
        }
      }
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "haskell", "javascript", "python", "latex", "lua" },
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup {
        ensure_installed = { "hls", "ts_ls", "pyright", "ltex", "lua_ls" },
      }

      local lspconfig = require("lspconfig")
      lspconfig.hls.setup {}
      lspconfig.ts_ls.setup {}
      lspconfig.pyright.setup {}
      lspconfig.ltex.setup { settings = { ltex = { language = "en-US" } } }
      lspconfig.lua_ls.setup {}

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, noremap = true, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup {
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm { select = true },
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      }
    end,
  },

  -- LaTeX
  {
    "lervag/vimtex",
    config = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_compiler_method = "latexmk"
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup {}
      vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { noremap = true, silent = true })
    end,
  },
})

-- Keybindings
vim.keymap.set("n", "<leader>w", ":w<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>q", ":q<CR>", { noremap = true, silent = true })

-- Disable arrow keys
vim.keymap.set("", "<Up>", "<Nop>", { noremap = true })
vim.keymap.set("", "<Down>", "<Nop>", { noremap = true })
vim.keymap.set("", "<Left>", "<Nop>", { noremap = true })
vim.keymap.set("", "<Right>", "<Nop>", { noremap = true })

-- Ensure very high contrast no matter what by forcing these highlight overrides
-- This happens after colorscheme load and will persist
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- Black background
    vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
    
    -- Extremely bright syntax colors
    vim.api.nvim_set_hl(0, "Comment", { fg = "#00ff00", bold = true })      -- Bright green
    vim.api.nvim_set_hl(0, "Function", { fg = "#00ffff" })                  -- Bright cyan
    vim.api.nvim_set_hl(0, "Keyword", { fg = "#00ffff", bold = true })      -- Bold bright cyan
    vim.api.nvim_set_hl(0, "Statement", { fg = "#00ffff", bold = true })    -- Bold bright cyan
    vim.api.nvim_set_hl(0, "String", { fg = "#ffff00" })                    -- Bright yellow
    vim.api.nvim_set_hl(0, "Special", { fg = "#ff00ff" })                   -- Bright magenta
  end,
})

-- Run once at startup
vim.cmd("doautocmd ColorScheme")
