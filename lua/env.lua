return {
    prompt_pattern = "Macbook\\$\\s",
    python_env = {
        "PATH=./test_modules/bin:./.venv/bin:" .. vim.env.PATH,
        "PYTHONPATH=./test_modules",
    },
    enable_copilot = false,
    project_tabs_config = {
        root_dirs = {
            "~/.local/share/nvim/lazy",
            "~/repos",
            "~/work",
            "~/Codes",
            "~/.config/nvim",
        },
        max_depth = 3,
    }
}
