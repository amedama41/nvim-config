;; extends

(command_name
  (word) @ghp_token
  (#vim-match? @ghp_token "ghp_\\S+")
  (#set! "conceal" "🐙"))

(variable_assignment
  (variable_name) @aws_token_name
  (word) @aws_token_value
  (#vim-match? @aws_token_name "AWS_(ACCESS_KEY_ID|SECRET_ACCESS_KEY|SESSION_TOKEN)")
  (#set! @aws_token_value "conceal" "?"))
