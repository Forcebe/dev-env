---@module 'lazy'
---@type LazySpec
return {
  -- Auto-close and auto-rename HTML/JSX/TSX tags
  {
    'windwp/nvim-ts-autotag',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    },
  },

  -- Sets commentstring based on treesitter context (correct JSX comments: {/* */})
  -- Integrates with Neovim's built-in gc commenting
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
    init = function()
      -- Override Neovim's built-in get_option to use ts_context_commentstring
      local get_option = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option)
        return option == 'commentstring' and require('ts_context_commentstring.internal').calculate_commentstring() or get_option(filetype, option)
      end
    end,
  },

  -- Better diagnostics list UI
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = {},
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
      { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', desc = 'Symbols (Trouble)' },
    },
  },

  -- GitHub Copilot
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      suggestion = { enabled = false }, -- Disable inline suggestions, use blink.cmp instead
      panel = { enabled = false },
    },
  },

  -- Copilot as a blink.cmp completion source
  {
    'fang2hou/blink-copilot',
    lazy = true,
  },

  -- Display package versions inline in package.json
  {
    'vuki656/package-info.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    event = { 'BufRead package.json' },
    opts = {},
    keys = {
      { '<leader>ps', function() require('package-info').show() end, desc = 'Show package versions' },
      { '<leader>ph', function() require('package-info').hide() end, desc = 'Hide package versions' },
      { '<leader>pu', function() require('package-info').update() end, desc = 'Update package' },
      { '<leader>pd', function() require('package-info').delete() end, desc = 'Delete package' },
      { '<leader>pi', function() require('package-info').install() end, desc = 'Install package' },
      { '<leader>pc', function() require('package-info').change_version() end, desc = 'Change package version' },
    },
  },

  -- Type-check entire project (not just open files)
  {
    'dmmulroy/tsc.nvim',
    cmd = 'TSC',
    opts = {},
  },

  -- Inline test runner
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'marilari88/neotest-vitest',
      'nvim-neotest/neotest-jest',
    },
    keys = {
      { '<leader>tn', function() require('neotest').run.run() end, desc = '[T]est [N]earest' },
      { '<leader>tf', function() require('neotest').run.run(vim.fn.expand '%') end, desc = '[T]est [F]ile' },
      { '<leader>ts', function() require('neotest').summary.toggle() end, desc = '[T]est [S]ummary' },
      { '<leader>to', function() require('neotest').output_panel.toggle() end, desc = '[T]est [O]utput' },
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require 'neotest-vitest',
          require 'neotest-jest' {
            jestCommand = 'npx jest',
          },
        },
      }
    end,
  },
}
