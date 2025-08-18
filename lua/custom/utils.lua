local M = {}

local function log(...)
  local args = { ... }
  local chunks = {}
  for i, v in ipairs(args) do
    chunks[i] = { vim.inspect(v) }
  end
  vim.api.nvim_echo(chunks, true, {})
end
M.log = log

-- TODO: make the doc put `@return` at the bottom in lsp hover.

-- Gets the contents of the last selection.
--
-- If you run this function while still in visual mode, this will return the contents
-- of the last selection. You must first exit visual mode to get the contents. You
-- can do so like this, for example: `vim.api.nvim_command(':normal v')`.
--
--- @return string contents include newline characters (`\n`) if the selection spanned multiple lines.
M.get_selection = function()
  local mark_start = vim.api.nvim_buf_get_mark(0, '<')
  local mark_end = vim.api.nvim_buf_get_mark(0, '>')
  assert(mark_start[1] ~= 0 and mark_end[1] ~= 0, 'no last selection')
  local start = mark_start
  local end_ = mark_end
  -- orders by column if on the same line
  if mark_start[1] == mark_end[1] then
    start = mark_start[2] < mark_end[2] and mark_start or mark_end
    end_ = mark_start[2] < mark_end[2] and mark_end or mark_start
  else
    start = mark_start[1] < mark_end[1] and mark_start or mark_end
    end_ = mark_start[1] < mark_end[1] and mark_end or mark_start
  end
  -- if you pass a bigger index to string.sub, it will return an empty string
  local string_sub_max = 2147483647 - 1
  start[2] = start[2] > string_sub_max and string_sub_max or start[2]
  end_[2] = end_[2] > string_sub_max and string_sub_max or end_[2]

  local lines = vim.api.nvim_buf_get_lines(0, start[1] - 1, end_[1], false)
  assert(lines[0] == nil)
  assert(lines[#lines] ~= nil)
  if #lines == 1 then
    local line = lines[1]:sub(start[2] + 1, end_[2] + 1)
    return line
  end

  assert(#lines >= 2)
  local content = lines[1]:sub(start[2] + 1) .. '\n'
  local line_last = lines[#lines]:sub(0, end_[2] + 1)
  table.remove(lines, 1)
  table.remove(lines, #lines)
  for _, v in ipairs(lines) do
    content = content .. v .. '\n'
  end
  content = content .. line_last
  return content
end

--- @param str string
--- @param search string
--- @return boolean
M.string_starts_with = function(str, search)
  return str:sub(1, search:len()) == search
end

--- @param str string
--- @param search string
--- @return boolean
M.string_ends_with = function(str, search)
  return str:sub(str:len() + 1 - search:len()) == search
end

return M
