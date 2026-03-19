local M = {}

-- [[ Types ]]

--- @class picker_treesitter_Opts
--- @field query_files string[]
--- The order matters. Values with lower index are prioritized if there is a conflict.
--- Multiple matches with the same text are compared and the value with the lower index wins.
--- @field captures picker_treesitter_Capture[]

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
--- Either `include` this capture in only the specified languages or `exclude` this capture from
--- only the specified languages.
--- @field filters ["include" | "exclude", table<string, true>]?

--- @class picker_treesitter_Entry
--- @field text string
--- @field kind string
--- @field lnum integer
--- @field col integer
--- @field priority integer
--- @field capture picker_treesitter_Capture

-- [[ Implementation ]]

--- @param opts { bufnr: integer, displayer: fun(items: (string | [string, string])[]) }
local function make_entry(opts)
  --- @param entry picker_treesitter_Entry
  return function(entry)
    local icon = entry.capture.name:sub(1, 1):upper()

    local text = entry.text
    if entry.capture.chars then
      text = text .. ('_'):rep(entry.capture.chars)
    end

    local cord = entry.lnum .. ':' .. entry.col

    local hl = '@' .. entry.kind
    if entry.capture.hl then
      hl = entry.capture.hl
    end

    return {
      ordinal = ('%s %s'):format(entry.capture.name, text, entry.capture.name),
      lnum = entry.lnum,
      col = entry.col,
      filename = vim.api.nvim_buf_get_name(opts.bufnr),

      icon = icon,
      text = entry.text,
      cord = cord,
      kind = entry.capture.name,
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

--- @param opts picker_treesitter_Opts
M.treesitter = function(opts)
  --- @type { [string]: picker_treesitter_Capture[] }
  local captures_by_kind = {}
  for _, capture in ipairs(opts.captures) do
    if captures_by_kind[capture.kind] then
      table.insert(captures_by_kind[capture.kind], capture)
    else
      captures_by_kind[capture.kind] = { capture }
    end
  end

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

    for _, query_file in ipairs(opts.query_files) do
      local query = vim.treesitter.query.get(tree_lang, query_file)
      if query then
        for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
          local name = query.captures[id]

          if captures_by_kind[name] ~= nil then
            for i, capture in ipairs(captures_by_kind[name]) do
              local filters = capture.filters or {}
              local filter_type = filters[1]
              local filter_list = filters[2]
              local is_kept = #filters == 0 or filter_type == 'include' and filter_list[tree_lang] or filter_type == 'exclude' and not filter_list[tree_lang]

              if is_kept then
                local identifier_node = node
                local text = ''
                local row = 0
                local col = 0

                if capture.full then
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
                  priority = i,
                  capture = capture,
                })
              end
            end
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

  local telescope_opts = {}

  telescope_pickers
    .new(telescope_opts, {
      prompt_title = 'Treesitter',
      finder = telescope_finders.new_table {
        results = results,
        entry_maker = make_entry { bufnr = bufnr, displayer = displayer },
      },
      sorter = telescope_extensions.fzf.native_fzf_sorter(),
      previewer = telescope_config.qflist_previewer(telescope_opts),
    })
    :find()
end

return M
