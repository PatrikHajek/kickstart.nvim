-- TODO: Remove? Only really useful for languages I can't easily run in the terminal - in
-- vim-dispatch, like neovim lua code.

return {
  'artemave/workspace-diagnostics.nvim',
  config = function()
    vim.keymap.set('n', '<leader>lwd', function()
      for _, client in ipairs(vim.lsp.get_clients()) do
        require('workspace-diagnostics').populate_workspace_diagnostics(client, 0)
      end
      vim.api.nvim_command ':Trouble diagnostics open_no_results=true'
    end, { desc = '[L]ist [W]orkspace [D]iagnostics' })
  end,
}
