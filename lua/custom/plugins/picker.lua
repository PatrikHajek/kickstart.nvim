return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          mappings = {
            i = {
              ['<C-q>'] = require('telescope.actions').smart_send_to_qflist,
              ['<C-x>'] = require('telescope.actions').delete_buffer,
              ['<C-i>'] = require('telescope.actions.layout').toggle_preview,
            },
            n = {
              ['<C-q>'] = require('telescope.actions').smart_send_to_qflist,
              ['<C-x>'] = require('telescope.actions').delete_buffer,
              ['<C-i>'] = require('telescope.actions.layout').toggle_preview,
            },
          },
          vimgrep_arguments = {
            'rg',
            '--follow', -- Follow symbolic links
            '--hidden', -- Search for hidden files
            '--glob=!.git',
            -- INFO: required by telescope
            '--color=never',
            '--no-heading', -- Don't group matches by each file
            '--with-filename', -- Print the file path with the matched lines
            '--line-number', -- Show line numbers
            '--column', -- Show column numbers
            '--smart-case', -- Smart case search
          },
          -- INFO: sets default theme (vertical) for all pickers
          results_title = false,
          sorting_strategy = 'ascending',
          layout_strategy = 'vertical',
          layout_config = {
            prompt_position = 'top',
            preview_cutoff = 1, -- Preview should always show (unless previewer = false)
            vertical = {
              preview_height = function(_, _, max_lines)
                local BORDER = 1
                local QUERY = 1
                local height = (max_lines - 6 * BORDER - QUERY) / 2
                return math.floor(height)
              end,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = {
              'rg',
              '--files',
              '--follow',
              '--hidden',
              '--glob=!.git',
              -- INFO: including `.env` file like this doesn't work
              -- '--glob=.env',
            },
          },
          lsp_dynamic_workspace_symbols = {
            -- INFO: fixed by GitHub [comment](https://github.com/nvim-telescope/telescope.nvim/issues/2104#issuecomment-1223790155)
            sorter = require('telescope').extensions.fzf.native_fzf_sorter(),
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
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

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        local make_entry = require 'telescope.make_entry'
        local entry_display = require 'telescope.pickers.entry_display'

        builtin.live_grep {
          prompt_title = 'Live Grep in Current Buffer',
          search_dirs = { '%' },
          path_display = { 'hidden' },

          entry_maker = function(entry)
            local displayer = entry_display.create {
              separator = ' │ ',
              items = {
                { width = 4 },
                { remaining = true },
              },
            }

            local e = make_entry.gen_from_vimgrep {}(entry)
            e.display = function(ent)
              return displayer {
                ent.lnum,
                ent.text,
              }
            end

            return e
          end,
        }
      end, { desc = '[/] Search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      -- vim.keymap.set('n', '<leader>sn', function()
      --   builtin.find_files { cwd = vim.fn.stdpath 'config' }
      -- end, { desc = '[S]earch [N]eovim files' })

      local query_files = {
        'highlights',
        'locals',
        'textobjects',
      }
      --- The order matters. Values with lower index are prioritized if there is a conflict.
      --- Multiple matches with the same text are compared and the value with the lower index wins.
      --- @type { kind: string, name: string, hl: string? }[]
      local captures = {
        { kind = 'local.definition.import', name = 'import', hl = '@keyword.import' },
        { kind = 'module', name = 'module' },
        { kind = 'class.outer', name = 'class', hl = '@type' },
        { kind = 'function', name = 'function' },
        { kind = 'function.method', name = 'method' },
        { kind = 'function.call', name = 'call fn' },
        { kind = 'function.method.call', name = 'call mtd' },
        { kind = 'keyword.coroutine', name = 'coroutine' },
        { kind = 'loop.outer', name = 'loop', hl = '@keyword.repeat' },
        { kind = 'conditional.outer', name = 'condition', hl = '@keyword.conditional' },
        { kind = 'keyword.conditional.ternary', name = 'cond ternany' },
        { kind = 'label', name = 'label' },
        { kind = 'type', name = 'type' },
        { kind = 'keyword.exception', name = 'exception' },
        { kind = 'constant', name = 'constant' },
        { kind = 'local.definition.var', name = 'variable', hl = '@variable' },
        { kind = 'local.definition.parameter', name = 'param', hl = '@variable.parameter' },
        { kind = 'variable.parameter', name = 'param' },
        { kind = 'string.regexp', name = 'regexp' },
        { kind = 'punctuation.special', name = 'punc' }, -- template strings?
        { kind = 'comment', name = 'comment' },
        { kind = 'comment.documentation', name = 'documentation' },
      }

      vim.keymap.set('n', '<leader>st', function()
        --- @type string[]
        local capture_kinds = {}
        for _, capture in ipairs(captures) do
          table.insert(capture_kinds, capture.kind)
        end

        --- @type { [string]: { kind: string, name: string, hl: string? } }
        local captures_by_kind = {}
        for _, capture in ipairs(captures) do
          captures_by_kind[capture.kind] = capture
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local ft = vim.bo[bufnr].filetype
        local parser = vim.treesitter.get_parser(bufnr, ft)
        if not parser then
          return
        end

        local results = {}
        parser:for_each_tree(function(tstree, lang_tree)
          local tree_lang = lang_tree:lang()
          local root = tstree:root()

          for _, query_file in ipairs(query_files) do
            local query = vim.treesitter.query.get(tree_lang, query_file)
            if query then
              for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
                local name = query.captures[id]

                if vim.list_contains(capture_kinds, name) then
                  local row, col, _ = node:start()
                  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''

                  table.insert(results, {
                    display = string.format('[%s] %s', name, vim.trim(line)),
                    text = line,
                    kind = name,
                    lnum = row + 1,
                    col = col + 1,
                    priority = vim.fn.indexof(capture_kinds, function(_, c)
                      return name == c
                    end),
                  })
                end
              end
            end
          end
        end)

        -- PERF:
        results = vim.tbl_filter(function(result)
          local winners = vim.tbl_filter(function(r)
            return r.lnum == result.lnum and r.col == result.col and r.priority < result.priority
          end, results)
          return #winners == 0
        end, results)

        table.sort(results, function(a, b)
          if a.lnum == b.lnum then
            return a.col < b.col
          else
            return a.lnum < b.lnum
          end
        end)

        local pickers = require 'telescope.pickers'
        local finders = require 'telescope.finders'
        local conf = require('telescope.config').values
        local entry_display = require 'telescope.pickers.entry_display'

        local opts = {}

        pickers
          .new(opts, {
            prompt_title = 'Treesitter',
            finder = finders.new_table {
              results = results,
              entry_maker = function(entry)
                local max_cord_width = 0
                for _, result in ipairs(results) do
                  local cord_width = #(result.lnum .. ':' .. result.col)
                  if cord_width > max_cord_width then
                    max_cord_width = cord_width
                  end
                end

                local max_kind_width = 0
                for _, result in ipairs(results) do
                  local kind_width = #result.kind
                  if kind_width > max_kind_width then
                    max_kind_width = kind_width
                  end
                end

                local icon_width = 1
                local text_width = 60
                local cord_width = max_cord_width
                local kind_width = math.min(max_kind_width, 1000)
                local displayer = entry_display.create {
                  separator = '  ',
                  items = {
                    { width = icon_width },
                    { width = text_width },
                    { width = cord_width },
                    { width = kind_width },
                  },
                }

                return {
                  value = entry,
                  display = function(ent)
                    local capture = captures_by_kind[ent.value.kind]
                    local hl_group = '@' .. ent.value.kind
                    if capture.hl then
                      hl_group = capture.hl
                    end

                    local icon = captures_by_kind[ent.value.kind].name:sub(1, 1):upper()
                    return displayer {
                      { icon, hl_group },
                      ent.value.text:sub(ent.value.col),
                      ent.value.lnum .. ':' .. ent.value.col,
                      { captures_by_kind[ent.value.kind].name, hl_group },
                    }
                  end,
                  ordinal = captures_by_kind[entry.kind].name .. '<>' .. entry.text:sub(entry.col),
                  lnum = entry.lnum,
                  col = entry.col,
                  filename = vim.api.nvim_buf_get_name(bufnr),
                }
              end,
            },
            sorter = require('telescope').extensions.fzf.native_fzf_sorter(),
            previewer = conf.qflist_previewer(opts),
          })
          :find()
      end, { desc = '[S]earch [T]reesitter' })

      vim.keymap.set('n', '<leader>saf', function()
        require('telescope.builtin').find_files {
          find_command = {
            'rg',
            '--files',
            '--follow',
            '--hidden',
            '--no-ignore',
            '--glob=!.git',
            '--glob=!node_modules',
          },
        }
      end, { desc = '[S]earch [A]ll [F]iles' })
      vim.keymap.set('n', '<leader>sag', function()
        require('telescope.builtin').live_grep {
          additional_args = { '--no-ignore' },
          glob_pattern = { '!node_modules' },
        }
      end, { desc = '[S]earch [A]ll files using [G]rep' })

      ---@param prefix string
      ---@param path string
      ---@param name string
      local function map_search(prefix, path, name)
        vim.keymap.set('n', '<leader>s' .. prefix .. 'f', function()
          require('telescope.builtin').find_files { cwd = vim.fn.expand(path) }
        end, { desc = '[S]earch ' .. name .. ' [F]iles' })
        vim.keymap.set('n', '<leader>s' .. prefix .. 'g', function()
          require('telescope.builtin').live_grep { cwd = vim.fn.expand(path) }
        end, { desc = '[S]earch ' .. name .. ' by [G]rep' })
      end
      map_search('p', '$HOME/notes/', '[P]KM')
      map_search('o', '$HOME/notes-tomake/', '[O]rganization')
      map_search('n', vim.fn.stdpath 'config', '[N]eovim')
    end,
  },
}
