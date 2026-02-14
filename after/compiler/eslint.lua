vim.api.nvim_buf_set_var(0, 'current_compiler', 'eslint')

-- Transform JSON into `filename:line:column: message`.
vim.opt_local.makeprg =
  [[pnpm eslint --max-warnings 0 --format json . | jq -r '.[] | .filePath as $f | .messages[] | "\($f):\(.line):\(.column): \(.message)"']]

vim.opt_local.errorformat = '%f:%l:%c: %m'
