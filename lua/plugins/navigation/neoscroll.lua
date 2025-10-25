-- Neoscroll: Smooth scrolling animations
-- Lazy-loaded: Loads after UI ready for enhanced UX
-- Features: Easing functions, customizable scroll behavior
return {
  "karb94/neoscroll.nvim",
  event = "VeryLazy",
  config = function()
    require("neoscroll").setup({})
  end,
}
