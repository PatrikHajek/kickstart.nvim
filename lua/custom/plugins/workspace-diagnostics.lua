return {
  'artemave/workspace-diagnostics.nvim',
  config = function()
    vim.keymap.set('n', '<leader>ld', function()
      for _, client in ipairs(vim.lsp.get_clients()) do
        require('workspace-diagnostics').populate_workspace_diagnostics(client, 0)
      end
      vim.api.nvim_command ':Trouble diagnostics'
    end, { desc = '[L]ist Workspace [D]iagnostics' })
  end,
}
