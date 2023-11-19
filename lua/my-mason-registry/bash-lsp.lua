local Pkg = require "mason-core.package"

return Pkg.new {
  schema = "registry+v1",
  name = "bash-language-server-mod",
  description = "bash language server (mod)",
  homepage = "https://github.com/amedama41/bash-language-server",
  licenses = { "MIT" },
  categories = { "LSP" },
  languages = { "bash" },
  source = {
    id = "pkg:npm/@amedama41/bash-language-server-mod@5.0.0-beta.1",
  },
  schemas = {
    lsp = "vscode:https://raw.githubusercontent.com/bash-lsp/bash-language-server/server-5.0.0/vscode-client/package.json",
  },
  bin = {
    ["bash-language-server-mod"] = "npm:bash-language-server-mod",
  },
}
