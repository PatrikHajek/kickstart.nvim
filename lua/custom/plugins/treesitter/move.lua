local M = {}

local ts_repeat_move = require 'nvim-treesitter-textobjects.repeatable_move'

--- @param node TSNode
--- @param query vim.treesitter.Query
--- @param captures string[]
--- @return string | nil capture The first capture from captures that is queried or nil.
local function get_capture(node, query, captures)
  local n_row, end_row = node:range()
  for id, matched_node in query:iter_captures(node, 0, n_row, end_row) do
    local capture = query.captures[id]
    local m_row = matched_node:range()
    if vim.list_contains(captures, capture) and n_row == m_row then
      return capture
    end
  end

  return nil
end

--- @class treesitter_goto_enclosing_opts
--- @field query_files string[]
--- @field captures string[]

--- Goes to the start of the innermost enclosing textobject specified in `captures`.
---
--- If `opts` is omitted, the innermost parent regardless of it's capture is targeted.
---
--- Ignores parents on the same line in all cases.
---
--- @param _ TSTextObjects.MoveOpts
--- @param opts treesitter_goto_enclosing_opts?
--- @type fun(opts: TSTextObjects.MoveOpts, opts: treesitter_goto_enclosing_opts?)
M.goto_enclosing = ts_repeat_move.make_repeatable_move(function(_, opts)
  local ts_utils = require 'nvim-treesitter.ts_utils'
  local node = ts_utils.get_node_at_cursor()
  local root_parser = vim.treesitter.get_parser(0)
  if not node or not root_parser then
    return
  end

  local start_row, start_col, end_row, end_col = node:range()
  local lang = root_parser:language_for_range({ start_row, start_col, end_row, end_col }):lang()

  --- @type { [string]: vim.treesitter.Query }
  local queries = {}
  if opts then
    for _, query_file in ipairs(opts.query_files) do
      local query = vim.treesitter.query.get(lang, query_file)
      if query then
        queries[query_file] = query
      end
    end
  end

  local node_row = node:range()
  local parent = node:parent()
  while parent do
    local parent_row, parent_col = parent:range()

    -- "block" nodes start on the first line in the block and are masking the real parent.
    if parent:type() ~= 'block' and node_row ~= parent_row then
      if opts then
        for _, query in pairs(queries) do
          if get_capture(parent, query, opts.captures) ~= nil then
            vim.cmd 'normal! m`'
            vim.api.nvim_win_set_cursor(0, { parent_row + 1, parent_col })
            return
          end
        end
      else
        vim.cmd 'normal! m`'
        vim.api.nvim_win_set_cursor(0, { parent_row + 1, parent_col })
        return
      end
    end
    parent = parent:parent()
  end
  print 'No parent context found'
end)

return M
