local M = {}

-- [[ Types ]]

--- @class picker_treesitter_Capture
--- @field kind string
--- @field name string
--- @field hl? string
--- @field trim? fun(text: string): string

--- @class picker_treesitter_Entry
--- @field text string
--- @field kind string
--- @field lnum integer
--- @field col integer
--- @field priority integer

-- [[ Config ]]

--- @param text string
--- @return string
local function trim_var(text)
  return text:match '^[%w_]+' or text
end

local query_files = {
  'highlights',
  'locals',
  'textobjects',
}

--- The order matters. Values with lower index are prioritized if there is a conflict.
--- Multiple matches with the same text are compared and the value with the lower index wins.
--- @type picker_treesitter_Capture[]
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
  { kind = 'local.definition.var', name = 'variable', hl = '@variable', trim = trim_var },
  { kind = 'variable.parameter', name = 'param' },
  { kind = 'local.definition.parameter', name = 'param', hl = '@variable.parameter' },
  { kind = 'variable.member', name = 'member' },
  { kind = 'tag', name = 'tag' },
  { kind = 'tag.attribute', name = 'attribute' },
  { kind = 'string.regexp', name = 'regexp' },
  { kind = 'punctuation.special', name = 'punc' }, -- template strings?
  { kind = 'comment', name = 'comment' },
  { kind = 'comment.documentation', name = 'documentation' },
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
    local capture_name = captures_by_kind[entry.kind].name

    local text = entry.text:sub(entry.col)
    if captures_by_kind[entry.kind].trim then
      text = captures_by_kind[entry.kind].trim(text)
    end

    return {
      value = entry,
      ordinal = ('%s<>%s<>%s'):format(capture_name, text, capture_name),
      lnum = entry.lnum,
      col = entry.col,
      filename = vim.api.nvim_buf_get_name(opts.bufnr),
      display = function(ent)
        local capture = captures_by_kind[ent.value.kind]
        local hl_group = '@' .. ent.value.kind
        if capture.hl then
          hl_group = capture.hl
        end

        local icon = capture.name:sub(1, 1):upper()
        return opts.displayer {
          { icon, hl_group },
          ent.value.text:sub(ent.value.col),
          ent.value.lnum .. ':' .. ent.value.col,
          { capture.name, hl_group },
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
            local row, col, _ = node:start()
            local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''

            table.insert(results, {
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

  --- @type picker_treesitter_Entry[]
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
