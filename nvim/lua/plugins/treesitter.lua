return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "rust",
        "gitignore",
        "python",
        "regex",
        "vim",
        "bash",
        "html",
      },
    },
    config = function(_, opts)
			local TS = require("nvim-treesitter")
			TS.setup(opts)

			-- MDX
			vim.filetype.add({
				extension = {
					mdx = "mdx",
				},
			})
			vim.treesitter.language.register("markdown", "mdx")
    end,
  },
}
