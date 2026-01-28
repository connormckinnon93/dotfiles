return {
  "snacks.nvim",
  keys = {
    {
      "<leader>dD",
      function()
        Snacks.terminal({ "lazydocker" }, { cwd = LazyVim.root() })
      end,
      desc = "Lazydocker (Root Dir)",
    },
    {
      "<leader>dd",
      function()
        Snacks.terminal({ "lazydocker" })
      end,
      desc = "Lazydocker (cwd)",
    },
  },
}
