local function get_lines()
	local lines = vim.split(vim.api.nvim_exec('ls +', true), '\n', { plain = true })
	if #lines == 1 and lines[1] == '' then
		return {}
	end

	for i, line in pairs(lines) do
		local end_index = line.find(line, '"', line.find(line, '"') + 1)
		if (end_index == nil) then
			goto continue
		end

		lines[i] = vim.fn.trim(line.sub(line, 0, end_index))
		::continue::
	end

	return lines
end

local function set_lines(start, end_, strict_indexing, replacement)
	vim.api.nvim_buf_set_option(0, 'modifiable', true)
	vim.api.nvim_buf_set_lines(0, start, end_, strict_indexing, replacement)
	vim.api.nvim_buf_set_option(0, 'modifiable', false)
	vim.opt.modified = false
end

vim.api.nvim_create_user_command('UnsavedBuffers', function()
	local lines = get_lines()
	if #lines == 0 then
		print('No unsaved buffers')
		return
	end

	vim.cmd('new')
	vim.api.nvim_buf_set_name(0, 'Unsaved Buffers')
	set_lines(0, -1, false, lines)

	-- don't know if autocmds are getting removed
	-- probably not since buffers are being unlisted instead of removed
	vim.api.nvim_create_autocmd('BufLeave', {
		buffer = 0,
		callback = function()
			vim.cmd('bd')
		end,
	})

	vim.keymap.set('n', 'S', function()
		vim.cmd(':wa')
		set_lines(0, -1, false, {})
	end, { desc = 'Save all buffers', buffer = 0 })
end, {})

vim.keymap.set('n', '<leader>bu', ':UnsavedBuffers<cr>', { desc = 'Show unsaved buffers' })
