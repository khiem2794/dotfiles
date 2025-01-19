return {
  {
    { 
      "sainnhe/gruvbox-material", 
      priority = 100, 
      config = function()
        vim.cmd("colorscheme gruvbox-material")
        vim.g.gruvbox_material_background = "hard"
        vim.g.gruvbox_material_enable_italic = true
        vim.g.gruvbox_material_enable_bold = true
        vim.opt.background = "dark"
      end
    },
    { "LazyVim/LazyVim", opts = {
      colorscheme = "gruvbox-material",
    } },
  },
}
