--[[
  100% NATIVE NEOVIM 0.12 SECURE CONFIGURATION
  - Zero external package managers (No Lazy)
  - Zero external binary downloaders (No Mason)
  - Native autocomplete and snippets
  - Native LSP formatting
--]]

-- Purge Windows paths from Neovim to prevent WSL path pollution
local current_path = vim.env.PATH
local clean_paths = {}
for p in string.gmatch(current_path, "[^:]+") do
    if not string.find(p, "/mnt/c/") then
        table.insert(clean_paths, p)
    end
end
vim.env.PATH = table.concat(clean_paths, ":")

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.mouse = ''
vim.g.have_nerd_font = true

-- SECURITY: Disable modelines to prevent arbitrary code execution
vim.o.modeline = false

-- [[ Basic Options ]]
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 50

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- [[ Native Package Management (Option B) ]]
-- Neovim naturally loads anything in `site/pack/*/start/`
local pack_path = vim.fn.stdpath('data') .. '/site/pack/secure/start/'

local function ensure_plugin(name, repo, commit)
  local path = pack_path .. name
  if not (vim.uv or vim.loop).fs_stat(path) then
    vim.notify('Securely installing ' .. name .. '...', vim.log.levels.INFO)

    local clone_out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', repo, path })
    if vim.v.shell_error ~= 0 then error('Error cloning ' .. name .. ':\n' .. clone_out) end
    local checkout_out = vim.fn.system({ 'git', '-C', path, 'checkout', commit })
    if vim.v.shell_error ~= 0 then error('Error pinning commit for ' .. name .. ':\n' .. checkout_out) end

    -- Special build step for telescope-fzf-native
    if name == 'telescope-fzf-native.nvim' and vim.fn.executable('make') == 1 then
      vim.fn.system({ 'make', '-C', path })
    end

    -- Force load immediately on the first run
    vim.cmd('packadd ' .. name)
  end
end

-- =====================================================================
-- FETCH PLUGINS (Replace the hashes below with audited commits!)
-- =====================================================================

-- Core & Utilities
ensure_plugin('vim-sleuth', 'https://github.com/tpope/vim-sleuth.git', '1d25e8e5dc4062e38cab1a461934ee5e9d59e5a8')
ensure_plugin('vim-fugitive', 'https://github.com/tpope/vim-fugitive.git', '96c1009fcf8ce60161cc938d149dd5a66d570756')
ensure_plugin('flash.nvim', 'https://github.com/folke/flash.nvim.git', 'ec0bf2842189f65f60fd40bf3557cac1029cc932')
ensure_plugin('which-key.nvim', 'https://github.com/folke/which-key.nvim.git', 'fcbf4eea17cb299c02557d576f0d568878e354a4')

-- UI & Navigation
ensure_plugin('tokyonight.nvim', 'https://github.com/folke/tokyonight.nvim.git', '545d72cde6400835d895160ecb5853874fd5156d')
ensure_plugin('mini.nvim', 'https://github.com/echasnovski/mini.nvim.git', 'a995fe9cd4193fb492b5df69175a351a74b3d36b')
ensure_plugin('todo-comments.nvim', 'https://github.com/folke/todo-comments.nvim.git', '31e3c38ce9b29781e4422fc0322eb0a21f4e8668')
ensure_plugin('nui.nvim', 'https://github.com/MunifTanjim/nui.nvim.git', 'f535005e6ad1016383f24e39559833759453564e')
ensure_plugin('neo-tree.nvim', 'https://github.com/nvim-neo-tree/neo-tree.nvim.git', 'f3df514fff2bdd4318127c40470984137f87b62e')

-- Telescope & Dependencies
ensure_plugin('plenary.nvim', 'https://github.com/nvim-lua/plenary.nvim.git', '50012918b2fc8357b87cff2a7f7f0446e47da174')
ensure_plugin('nvim-web-devicons', 'https://github.com/nvim-tree/nvim-web-devicons.git', '21417212f640a1dad28a1408f04468819848f5e7')
ensure_plugin('telescope-fzf-native.nvim', 'https://github.com/nvim-telescope/telescope-fzf-native.nvim.git', 'b25b749b9db64d375d782094e2b9dce53ad53a40')
ensure_plugin('telescope-ui-select.nvim', 'https://github.com/nvim-telescope/telescope-ui-select.nvim.git', '6e51d7da30bd139a6950adf2a47fda6df9fa06d2')
ensure_plugin('telescope.nvim', 'https://github.com/nvim-telescope/telescope.nvim.git', '3333a52ff548ba0a68af6d8da1e54f9cd96e9179')

-- LSP & Parsing
ensure_plugin('nvim-treesitter', 'https://github.com/nvim-treesitter/nvim-treesitter.git', '42fc28ba918343ebfd5565147a42a26580579482')
ensure_plugin('fidget.nvim', 'https://github.com/j-hui/fidget.nvim.git', 'b61e8af9b8b68ee0ec7da5fb7a8c203aae854f2e')
-- Lazedev will probably be removed
-- ensure_plugin('lazydev.nvim', 'https://github.com/folke/lazydev.nvim.git', '01bc2aacd51cf9021eb19d048e70ce3dd09f7f93')
ensure_plugin('nvim-lspconfig', 'https://github.com/neovim/nvim-lspconfig.git', '9bafffaeaae363c5211080e06e04ed5b422fd5ad')

-- require('lazydev').setup {
--   library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } },
-- }
-- -- =====================================================================
-- NATIVE AUTOCOMPLETION & FORMATTING (Neovim 0.12+)
-- =====================================================================

vim.opt.autocomplete = true 
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('native-lsp-attach', { clear = true }),
  callback = function(event)
    -- Enable Autocomplete
    vim.lsp.completion.enable(true, event.data.client_id, event.buf, { autotrigger = true })

    -- Map Native Formatting
    vim.keymap.set('n', '<leader>fw', function()
      vim.lsp.buf.format { async = true }
    end, { buffer = event.buf, desc = '[F]ormat [w]orkspace/buffer natively' })

    vim.keymap.set('v', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, { buffer = event.buf, desc = '[F]ormat selection natively' })
  end,
})

-- Native Snippet Navigation
vim.keymap.set({ 'i', 's' }, '<C-l>', function()
  if vim.snippet.active({ direction = 1 }) then vim.snippet.jump(1) end
end, { desc = 'Jump forward in snippet' })

vim.keymap.set({ 'i', 's' }, '<C-h>', function()
  if vim.snippet.active({ direction = -1 }) then vim.snippet.jump(-1) end
end, { desc = 'Jump backward in snippet' })

-- =====================================================================
-- CUSTOM KEYMAPS & AUTOCOMMANDS
-- =====================================================================

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Disable arrows
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Window navigation
vim.keymap.set('n', '<C-left>', '<C-w><C-h>', { desc = 'Move focus left' })
vim.keymap.set('n', '<C-right>', '<C-w><C-l>', { desc = 'Move focus right' })
vim.keymap.set('n', '<C-down>', '<C-w><C-j>', { desc = 'Move focus down' })
vim.keymap.set('n', '<C-up>', '<C-w><C-k>', { desc = 'Move focus up' })

-- User specific
vim.keymap.set('n', '<leader>m', ':bn<CR>')
vim.keymap.set('n', '<leader>M', ':bp<CR>')
vim.keymap.set('n', '<left>', ']c')
vim.keymap.set('n', '<right>', '[c')
vim.keymap.set('n', '-', '$')
vim.keymap.set('n', '<F2>', '<C-w>q')
vim.keymap.set('n', '<F4>', ':wq!<CR>')
vim.keymap.set('n', '<F6>', '<cmd>:qa<CR>')
vim.keymap.set('n', '<F7>', ':w!<CR>')
vim.keymap.set('n', '<F12>', '<cmd>:LspClangdSwitchSourceHeader<CR>')
vim.keymap.set({ 'n', 'x', 's' }, '<C-k>', '<C-u>')
vim.keymap.set({ 'n', 'x', 's' }, '<C-j>', '<C-d>')
vim.keymap.set('n', '<C-1>', '<C-6>')
vim.keymap.set('n', '<leader>ls', ':ls<CR>', { desc = 'Show modified buffers' })
vim.keymap.set('n', '<leader>wa', ':wall<CR>', { desc = 'Write all opened buffers' })
vim.keymap.set('n', '<leader>wb', ':w!<CR>', { desc = 'Write current buffer' })
vim.keymap.set('n', 'q=', ':horizontal wincmd =<CR>', { desc = 'Windows horiontally equal' })
vim.keymap.set('n', 'q-', ':vertical wincmd =<CR>', { desc = 'Windows vertically equal' })
vim.keymap.set('n', '<leader>p', ':pwd<CR>', { desc = 'Show pwd' })
vim.keymap.set('n', '<F9>', ':tabclose<CR>')
vim.keymap.set('n', '<leader>gt', ':tabnew<CR>', { desc = 'Open a new tab'})

local function ScrollbindToAllWindows()
  vim.cmd('windo set scrollbind!')
end
vim.keymap.set('n', '<C-w>b', ScrollbindToAllWindows, { desc = 'Toggle scrollbind for all windows' })

vim.keymap.set('n', '<leader>WFL', ':!google-chrome -- https://www.compass-group.fi/ravintolat-ja-ruokalistat/foodco/kaupungit/oulu/garden/<CR>', { desc = '[W]hat\'s [F]or [L]unch?'})

-- Native Commenting mapped to your old Qt-CRA key
vim.keymap.set('n', '<leader>k', 'gcc', { remap = true, desc = 'Toggle comment line (Native)' })

-- Autocmds
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'cpp', 'h' },
  callback = function()
    vim.opt_local.comments = { '://' }
    vim.opt_local.commentstring = '// %s'
  end,
})

-- =====================================================================
-- FLAT PLUGIN CONFIGURATIONS
-- =====================================================================

-- [[ Colorscheme ]]
require('tokyonight').setup {
  styles = { comments = { italic = true } },
}
vim.cmd.colorscheme 'tokyonight-night'

-- [[ Which-Key ]]
require('which-key').setup {
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
    { '<leader>d', group = '[D]ocument' },
    { '<leader>r', group = '[R]ename' },
    { '<leader>s', group = '[S]earch' },
    { '<leader>w', group = '[W]orkspace' },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
  },
}

-- [[ Todo Comments ]]
require('todo-comments').setup { signs = false }

-- [[ Mini suite ]]
require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup()
require('mini.statusline').setup {
  use_icons = vim.g.have_nerd_font,
  set_location = function() return '%2l:%-2v' end
}

-- [[ Flash ]]
require('flash').setup { search = { enable = false } }
vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
vim.keymap.set("o", "r", function() require("flash").remote() end, { desc = "Remote Flash" })
vim.keymap.set({ "o", "x" }, "R", function() require("flash").treesitter_search() end, { desc = "Treesitter Search" })
vim.keymap.set("c", "<c-s>", function() require("flash").toggle() end, { desc = "Toggle Flash Search" })

-- [[ Fugitive setup ]]
vim.keymap.set('n', '<leader>gg', ':G', { desc = 'Fugitive base' })
vim.keymap.set('n', '<leader>gl', ':Gclog', { desc = 'Fugitive clog' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'fugitive'},
  callback = function(args)
    vim.keymap.set('n', '<leader>can', 'ce', { buffer = args.buf, silent = true, remap = true, desc = 'Fugitive amend commit without editing message' })
    vim.keymap.set('n', '<leader>ca', 'cae', { buffer = args.buf, silent = true, remap = true, desc = 'Fugitive amend commit with editing message' })
    vim.keymap.set('n', '<leader>dv', 'dv', { buffer = args.buf, silent = true, remap = true, desc = 'Fugitive open vertical diff' })
    vim.keymap.set('n', '<leader>fms', ':setlocal foldmethod=syntax<CR>', { silent = true, remap = true, desc = 'Setlocal foldmethod to syntax' })
    vim.keymap.set('n', '<leader>fmd', ':setlocal foldmethod=diff<CR>', { silent = true, remap = true, desc = 'Setlocal foldmethod to diff' })
    vim.keymap.set('n', '<leader>crm', ':G commit -C', { desc = 'commit and reuse message' })
    vim.keymap.set('n', '<leader>crem', ':G commit -c', { desc = 'commit and edit reused message' })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'git',
  callback = function() vim.opt_local.foldmethod = 'syntax' end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'cpp', 'git' },
  callback = function(args)
    vim.keymap.set('n', '<leader>]', ']c', { buffer = args.buf, silent = true, remap = true, desc = 'Next change' })
    vim.keymap.set('n', '<leader>[', '[c', { buffer = args.buf, silent = true, remap = true, desc = 'Last change' })
  end
})

-- [[ Treesitter ]]
-- For native loading, call config directly
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'java', 'cmake' },
  highlight = { enable = true },
  auto_install = false, -- SECURITY: Do not auto download parsers
}

-- [[ Neo-Tree ]]
require('neo-tree').setup {
  event_handlers = {
    {
      event = "neo_tree_buffer_enter",
      handler = function() vim.opt_local.relativenumber = true end,
    },
  },
}

-- [[ Telescope ]]
require('telescope').setup {
  defaults = {
    layout_strategy = 'horizontal',
    layout_config = { width = 0.9, height = 0.8, prompt_position = 'bottom' },
    preview = { treesitter = false },
  },
  pickers = {
    lsp_document_symbols = { symbol_width = 50 },
    lsp_dynamic_workspace_symbols = { layout_config = { preview_cutoff = 100 }, fname_width = 60 },
  },
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
}
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>s/', function()
  builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
end, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

vim.api.nvim_create_autocmd('User', {
  pattern = 'TelescopePreviewerLoaded',
  callback = function(args)
    if args.match ~= 'help' then vim.wo.number = true end
  end,
})

-- [[ LSP Configuration ]]
require('fidget').setup {}

vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local msg = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return msg[diagnostic.severity]
    end,
  },
}

-- Note: Because we removed nvim-cmp, we no longer need cmp_nvim_lsp default_capabilities.
-- Neovim 0.12 has native capability resolution.
-- [[ Native LSP Configuration (Neovim 0.12+) ]]

-- 1. Define custom overrides for servers that need them
vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = { analysis = { typeCheckingMode = 'basic' } }
  }
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT', -- Neovim uses LuaJIT natively
      },
      diagnostics = {
        globals = { 'vim' }, -- Permanently silences the "Undefined global `vim`" warnings
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME, -- Injects Neovim's core API documentation for autocomplete
          "${3rd}/luv/library", -- Injects vim.uv (libuv) types natively
        },
        checkThirdParty = false, -- Stops lua_ls from prompting you to configure unknown environments
      },
      completion = { callSnippet = 'Replace' },
    }
  }
})

vim.lsp.config('qml_lsp', {
  cmd = { '/home/sami/Qt/6.11.0/gcc_64/bin/qmlls' },
  filetypes = { 'qml' },
})

-- 2. Enable all your language servers at once
vim.lsp.enable({
  'clangd',
  'cmake',
  'basedpyright',
  'lua_ls',
  'qml_lsp'
})

-- Native LSP Keymaps mapping function
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = false }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, { bufnr = event.buf }) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, { bufnr = event.buf }) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})
