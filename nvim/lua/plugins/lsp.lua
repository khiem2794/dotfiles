return {
  "williamboman/mason.nvim",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, {
      "stylua",
      "selene",
      "shfmt",
      "shellcheck",
      "luacheck",
      "rust-analyzer",
      "tailwindcss-language-server",
      "typescript-language-server",
      "css-lsp",
    })
  end,
}
