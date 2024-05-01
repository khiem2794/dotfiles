-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if vim.g.neovide then
  vim.g.neovide_remember_window_size = false
  vim.g.neovide_scale_factor = 1
  vim.g.neovide_transparency = 0.8
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.o.guifont = "Maple Mono,JetBrainsMono Nerd Font:h12"
end
