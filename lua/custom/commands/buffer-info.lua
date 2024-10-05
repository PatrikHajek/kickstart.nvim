vim.keymap.set('n', '<leader>bi', function()
  local lines = {}
  local insert = function(line)
    table.insert(lines, line)
  end

  local path = vim.fn.expand '%'
  local file = vim.fn.expand '%:t'
  local file_dir = ''
  local split_path = vim.fn.split(path, '/')
  if #split_path > 1 then
    file_dir = split_path[#split_path - 1]
  end
  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local buffer_options = vim.bo.modified and '+' or ''

  insert('/' .. file_dir)
  insert(file)
  insert(path)
  insert(line_number .. ' ' .. buffer_options)

  vim.cmd 'new'
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(0, 'modifiable', false)
  vim.bo.modified = false
  vim.api.nvim_win_set_cursor(0, { 3, 7 })

  vim.api.nvim_create_autocmd('BufLeave', {
    buffer = 0,
    callback = function()
      vim.cmd 'bd'
    end,
  })
end, { desc = 'Show [B]uffer [I]nfo in a new buffer' })
