-- ALE (Asynchronous Lint Engine): Grammar and style checking via Vale
-- Lazy-loaded: Only for prose writing filetypes
-- Features: Real-time style guide enforcement, grammar checking
return {
  "dense-analysis/ale",
  ft = { "markdown", "text", "tex", "rst" },
}
