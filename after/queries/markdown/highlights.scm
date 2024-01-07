;; extends

(paragraph
  (inline) @ghp_token
  (#vim-match? @ghp_token "ghp_\\S+")
  (#set! "conceal" "🐙"))
