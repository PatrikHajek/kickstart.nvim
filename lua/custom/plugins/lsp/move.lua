local M = {}

M.goto_reference_next = function()
  vim.lsp.buf.references(nil, {
    on_list = function(r)
      local filename = vim.api.nvim_buf_get_name(0)
      local cursor = vim.api.nvim_win_get_cursor(0)
      local items = r.items
      local next_item = nil
      local fallback_item = nil
      for _, item in pairs(items) do
        if item.filename ~= filename then
          goto continue
        end

        if fallback_item == nil then
          fallback_item = item
        end

        -- lsp for some reason returns columns 1 bigger
        item.col = item.col - 1

        if item.lnum == cursor[1] and item.col > cursor[2] then
          next_item = item
          break
        elseif item.lnum > cursor[1] and item.lnum then
          next_item = item
          break
        end

        ::continue::
      end

      if next_item == nil then
        next_item = fallback_item
      end

      vim.cmd 'normal! m`'
      vim.api.nvim_win_set_cursor(0, { next_item.lnum, next_item.col })
    end,
  })
end

M.goto_reference_prev = function()
  vim.lsp.buf.references(nil, {
    on_list = function(r)
      local filename = vim.api.nvim_buf_get_name(0)
      local cursor = vim.api.nvim_win_get_cursor(0)
      local items = vim.fn.reverse(r.items)
      local prev_item = nil
      local fallback_item = nil
      for _, item in pairs(items) do
        if item.filename ~= filename then
          goto continue
        end

        if fallback_item == nil then
          fallback_item = item
        end

        -- lsp for some reason returns columns 1 bigger
        item.col = item.col - 1

        if item.lnum == cursor[1] and item.col < cursor[2] then
          prev_item = item
          break
        elseif item.lnum < cursor[1] then
          prev_item = item
          break
        end

        ::continue::
      end

      if prev_item == nil then
        prev_item = fallback_item
      end

      vim.cmd 'normal! m`'
      vim.api.nvim_win_set_cursor(0, { prev_item.lnum, prev_item.col })
    end,
  })
end

return M
