return {
    prompt_pattern = "Macbook\\$\\s",
    python_env = {
        "PATH=./test_modules/bin:./.venv/bin:" .. vim.env.PATH,
        "PYTHONPATH=./test_modules",
    },
}
