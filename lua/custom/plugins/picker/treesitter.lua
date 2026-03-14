local M = {}

-- [[ Types ]]

--- @class picker_treesitter_Capture
--- Treesitter capture.
--- @field kind string
--- Name to replace `kind` in the results.
--- @field name string
--- Highlight group to apply to the `kind`.
--- @field hl? string
--- Controls how many characters are inserted into the query. The more characters
--- there is, the worse the search priority of this item will be. Use this option
--- to prioritize some captures over others.
---
--- Default value for all captures is 0.
--- @field chars? integer
--- Whether to get the full line of just the identifier.
---
--- Defaults to false.
--- @field full? boolean

--- @class picker_treesitter_Entry
--- @field text string
--- @field kind string
--- @field lnum integer
--- @field col integer
--- @field priority integer

-- [[ Config ]]

local query_files = {
  'highlights',
  'locals',
  'textobjects',
}

--- The order matters. Values with lower index are prioritized if there is a conflict.
--- Multiple matches with the same text are compared and the value with the lower index wins.
--- @type picker_treesitter_Capture[]
local captures = {
  { kind = 'local.definition.import', name = 'import', hl = '@keyword.import', chars = 100 },
  { kind = 'module', name = 'module' },
  { kind = 'class.outer', name = 'class', hl = '@type', chars = 4 },
  { kind = 'function', name = 'function' },
  { kind = 'function.method', name = 'method' },
  { kind = 'function.call', name = 'call fn', full = true },
  { kind = 'function.method.call', name = 'call mtd', full = true },
  { kind = 'keyword.coroutine', name = 'coroutine' },
  { kind = 'loop.outer', name = 'loop', hl = '@keyword.repeat' },
  { kind = 'conditional.outer', name = 'condition', hl = '@keyword.conditional' },
  { kind = 'keyword.conditional.ternary', name = 'cond ternany' },
  { kind = 'label', name = 'label' },
  { kind = 'keyword.exception', name = 'exception' },
  { kind = 'constant', name = 'constant' },
  { kind = 'local.definition.var', name = 'variable', hl = '@variable' },
  { kind = 'variable.parameter', name = 'parameter', chars = 8 },
  { kind = 'local.definition.parameter', name = 'parameter', hl = '@variable.parameter', chars = 8 },
  { kind = 'variable.member', name = 'member', chars = 10 },
  { kind = 'tag', name = 'tag' },
  { kind = 'tag.attribute', name = 'attribute' },
  { kind = 'string.regexp', name = 'regexp', char = 100 },
  { kind = 'punctuation.special', name = 'punc' }, -- template strings?
  { kind = 'comment', name = 'comment', chars = 200 },
  { kind = 'comment.documentation', name = 'documentation', chars = 190 },
}

--- @type string[]
local capture_kinds = {}
for _, capture in ipairs(captures) do
  table.insert(capture_kinds, capture.kind)
end

--- @type { [string]: picker_treesitter_Capture }
local captures_by_kind = {}
for _, capture in ipairs(captures) do
  captures_by_kind[capture.kind] = capture
end

-- [[ Implementation ]]

--- @param opts { bufnr: integer, displayer: fun(items: (string | [string, string])[]) }
local function make_entry(opts)
  --- @param entry picker_treesitter_Entry
  return function(entry)
    local capture = captures_by_kind[entry.kind]

    local icon = capture.name:sub(1, 1):upper()

    local text = entry.text
    if capture.chars then
      text = text .. ('_'):rep(capture.chars)
    end

    local cord = entry.lnum .. ':' .. entry.col

    local hl = '@' .. entry.kind
    if capture.hl then
      hl = capture.hl
    end

    return {
      ordinal = ('%s %s'):format(capture.name, text, capture.name),
      lnum = entry.lnum,
      col = entry.col,
      filename = vim.api.nvim_buf_get_name(opts.bufnr),

      icon = icon,
      text = entry.text,
      cord = cord,
      kind = capture.name,
      hl = hl,
      display = function(ent)
        return opts.displayer {
          { ent.icon, ent.hl },
          ent.text,
          ent.cord,
          { ent.kind, ent.hl },
        }
      end,
    }
  end
end

local telescope_pickers = require 'telescope.pickers'
local telescope_finders = require 'telescope.finders'
local telescope_extensions = require('telescope').extensions
local telescope_config = require('telescope.config').values
local telescope_entry_display = require 'telescope.pickers.entry_display'

M.treesitter = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local parser = vim.treesitter.get_parser(bufnr, ft)
  if not parser then
    return
  end
  -- Force a full parse of the whole buffer.
  parser:parse(true)

  --- @type picker_treesitter_Entry[]
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
            local identifier_node = node
            local text = ''
            local row = 0
            local col = 0

            if captures_by_kind[name].full then
              row, col = identifier_node:start()
              text = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''

              local prefix = text:sub(1, col):match '[^%s]+$' or ''
              text = prefix .. text:sub(col + 1)
            else
              for child in node:iter_children() do
                if child:type():find 'identifier' then
                  identifier_node = child
                  break
                end
              end

              row, col = identifier_node:start()
              text = vim.treesitter.get_node_text(identifier_node, bufnr)
            end

            text = text:match '([^\n]*)'
            table.insert(results, {
              text = text,
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

  --- @type { [string]: picker_treesitter_Entry }
  local winners = {}
  for _, result in ipairs(results) do
    local key = result.lnum .. ':' .. result.col
    if not winners[key] or result.priority < winners[key].priority then
      winners[key] = result
    end
  end
  --- @type picker_treesitter_Entry[]
  results = vim.tbl_values(winners)

  table.sort(results, function(a, b)
    if a.lnum == b.lnum then
      return a.col < b.col
    else
      return a.lnum < b.lnum
    end
  end)

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

  local displayer = telescope_entry_display.create {
    separator = '  ',
    items = {
      { width = icon_width },
      { width = text_width },
      { width = cord_width },
      { width = kind_width },
    },
  }

  local opts = {}

  telescope_pickers
    .new(opts, {
      prompt_title = 'Treesitter',
      finder = telescope_finders.new_table {
        results = results,
        entry_maker = make_entry { bufnr = bufnr, displayer = displayer },
      },
      sorter = telescope_extensions.fzf.native_fzf_sorter(),
      previewer = telescope_config.qflist_previewer(opts),
    })
    :find()
end

return M
