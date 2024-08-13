vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"

-- 文字コード・改行コード設定
vim.opt.fileencodings = {
    "utf-8", "iso-2022-jp", "euc-jp", "cp932", "ucs-bom", "default", "latin1"
}
vim.opt.fileformats = {"unix", "dos", "mac"}
vim.opt.spelllang:append({"cjk"})

-- 表示設定
vim.opt.title = true    -- タイトルバー上のタイトル表示
vim.opt.showcmd = true  -- 入力中コマンドのステータスライン表示
vim.opt.showmode = true -- モードの表示
vim.opt.laststatus = 2  -- ステータスラインの常時表示
vim.opt.statusline = "%n:%m%r%w%q%t"
.. "%=[%{(&fileencoding!=''?&fileencoding:&encoding)}/%{&fileformat}]"
.. "[%Y][%04l,%03v][%p%%]"
vim.opt.guicursor = "a:block"
vim.opt.cursorline = true   -- カレント行のハイライト
vim.opt.scrolloff = 3       -- カーソル上下に必ず表示する行数
vim.opt.wrap = true         -- ウィンドウ幅より長い行の折り返し
-- vim.opt.textwidth = 80   -- テキストの最大幅
vim.opt.listchars = "eol:$,tab:>_,trail:-"  -- 非表示文字
vim.opt.list = true     -- 非表示文字の可視化
-- vim.opt.showmatch = true -- 括弧入力時に対応する括弧の表示
-- vim.opt.matchtime = 1    -- 対応する括弧を表示する時間 (0.1s 単位)
if vim.fn.exists("&ambiwidth") ~= 0 then
    -- vim.opt.ambiwidth = "double"
    vim.opt.ambiwidth = "single" -- NeoVimだとsingleの方がよいらしい
end

-- インデント設定
vim.opt.tabstop = 4     -- タブの幅
vim.opt.shiftwidth = 4  -- シフト時のタブの幅
vim.opt.softtabstop = 0 -- <Tab>挿入時のタブの幅
vim.opt.expandtab = true    -- タブをスペースに展開しない
vim.opt.smarttab = true
vim.opt.smartindent = true  -- オートインデント

vim.opt.backspace = {"indent", "eol", "start"}  -- 改行/インデント/挿入区間前の削除可能化
vim.opt.hidden = true   -- 編集中バッファの非表示化可能
vim.opt.visualbell = true   -- 音声ベルの代わりに表示ベルを使用
-- vim.api.nvim_set_option("t_vb", "")

-- 補完設定
vim.opt.complete:remove({"i"})  -- 補完候補からインクルードファイルの除去
vim.opt.pumheight = 16  -- 補完ポップアップメニューの高さ

-- コマンドライン設定
vim.opt.wildmenu = true -- コマンドライン補間の拡張モード
vim.opt.history = 500   -- コマンドライン履歴個数

-- 検索設定
vim.opt.ignorecase = true   -- 大文字小文字を区別せず検索
vim.opt.smartcase = true    -- 大文字が含まれている場合の区別
vim.opt.incsearch = true    -- インクリメンタルサーチ
vim.opt.hlsearch = true -- 検索結果のハイライト
vim.opt.wrapscan = true -- 検索時の最初と最後のループ

-- 折り畳み設定
--vim.opt.foldmethod = "expr"
--vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 10

-- バックアップファイル・Swapファイル設定
vim.opt.backup = false  -- バックアップファイルの非作成
vim.opt.swapfile = false    -- swapファイルを非作成

-- タグ設定
vim.opt.tags:append({"~/.tags"})   -- ctagsファイルディレクトリの指定
vim.opt.tagbsearch = false  -- タグを二分探索しない

--- ターミナルのスクロールバッファ
vim.opt.scrollback = 100000

local keymap_opt = { noremap = true, silent = true }
vim.keymap.set({"n", "x", "o"}, "j", "gj", keymap_opt)
vim.keymap.set({"n", "x", "o"}, "k", "gk", keymap_opt)
vim.keymap.set({"n", "x", "o"}, "gj", "j", keymap_opt)
vim.keymap.set({"n", "x", "o"}, "gk", "k", keymap_opt)
vim.keymap.set({"n", "x", "o"}, "n", "nzz", keymap_opt)
vim.keymap.set({"n", "x", "o"}, "N", "Nzz", keymap_opt)
vim.keymap.set("n", "<C-l>", ":<C-u>nohlsearch<CR><C-l>", keymap_opt)
vim.keymap.set("n", "r", "gr", keymap_opt)
vim.keymap.set("n", "gr", "r", keymap_opt)
vim.keymap.set("n", "R", "gR", keymap_opt)
vim.keymap.set("n", "gR", "R", keymap_opt)
vim.keymap.set("n", "gK", "K", keymap_opt)
vim.keymap.set("c", "<C-n>", "<Down>", { noremap = true })
vim.keymap.set("c", "<C-p>", "<Up>", { noremap = true })

local vimrc_settings_group = "vimrc-settings"
vim.api.nvim_create_augroup(vimrc_settings_group, { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
    group = vimrc_settings_group,
    pattern = "*",
    callback = function()
        if vim.opt.fileencoding:get() == "iso-2022-jp"
            and vim.fn.search("[^\x01-\x7e]", "n") == 0 then
            vim.opt.fileencoding = vim.opt.encoding:get()
        end
    end
})
vim.api.nvim_create_autocmd("TabClosed", {
    group = vimrc_settings_group,
    pattern = "*",
    callback = function()
        local current = vim.fn.tabpagenr()
        if current ~= 1 and current == tonumber(vim.fn.expand("<afile>")) then
            vim.cmd [[tabprevious]]
        end
    end
})
vim.api.nvim_create_autocmd("FileType", {
    group = vimrc_settings_group,
    pattern = {"rst", "gitcommit", "markdown", "octo"},
    callback = function()
        vim.opt_local.spell = true
        vim.opt_local.concealcursor = ""
    end
})
if vim.fn.executable("im-select") then
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = vimrc_settings_group,
        pattern = "*",
        callback = function()
            vim.cmd [[silent !im-select com.apple.keylayout.ABC]]
        end
    })
end
if vim.fn.executable("gh") then
    vim.api.nvim_create_user_command("GhBrowseURL", function(args)
        local file = vim.fn.bufname("%")
        if args.range == 2 then
            if args.line1 ~= args.line2 then
                file = file .. (":%d-%d"):format(args.line1, args.line2)
            else
                file = file .. (":%d"):format(args.line1)
            end
        end
        local result = vim.system({ "gh", "browse", "--no-browser", "-c", file }, { text = true }):wait()
        if result.code == 0 then
            local url = vim.trim(result.stdout)
            vim.print("yank: " .. url)
            vim.fn.setreg("+", url, "")
        else
            vim.print(vim.trim(result.stderr))
        end
    end, { range = true, force = true })
    vim.api.nvim_create_user_command("GhBrowse", function(args)
        local file = vim.fn.bufname("%")
        if args.range == 2 then
            if args.line1 ~= args.line2 then
                file = file .. (":%d-%d"):format(args.line1, args.line2)
            else
                file = file .. (":%d"):format(args.line1)
            end
        end
        vim.system({ "gh", "browse", "-c", file }, {}):wait()
    end, { range = true, force = true })
end

vim.api.nvim_create_user_command("GitEdit", function(info)
    if #info.fargs == 0 then
        local file = vim.fn.expand("%:p")
        if file == "" and vim.env.NVIM == "" then
            return
        end
        local channel = vim.fn.sockconnect("pipe", vim.env.NVIM, {
            rpc = true,
        })
        if channel <= 0 then
            return
        end
        vim.rpcrequest(channel, 'nvim_cmd', {
            cmd = "GitEdit",
            args = { file, vim.v.servername },
        }, {})
        vim.fn.chanclose(channel)
    elseif #info.fargs == 2 then
        local bufnr = vim.fn.bufadd(info.fargs[1])
        local winid = vim.api.nvim_open_win(bufnr, true, {
            relative = 'editor',
            row = 20,
            col = 1,
            width = vim.o.columns - 6,
            height = vim.o.lines - 26,
            border = "rounded",
        })
        vim.fn.win_execute(winid, 'stopinsert', true)

        vim.bo[bufnr].bufhidden = "delete"
        vim.bo[bufnr].buflisted = true
        vim.api.nvim_create_autocmd("BufDelete", {
            group = vim.api.nvim_create_augroup("vimrc-gitedit-settings", { clear = true }),
            buffer = bufnr,
            callback = function()
                local channel = vim.fn.sockconnect("pipe", info.fargs[2], {
                    rpc = true,
                })
                if channel > 0 then
                    pcall(vim.rpcrequest, channel, 'nvim_cmd', {
                        cmd = "quit",
                        args = {},
                    }, {})
                    vim.fn.chanclose(channel)
                end
            end,
            once = true,
        })
    end
end, { nargs = '*', force = true })

if vim.fn.executable("cat") then
    vim.env.GIT_PAGER = "cat"
end
vim.env.GIT_EDITOR = "nvim -c GitEdit "

vim.cmd "colorscheme mine"
vim.opt.termguicolors = true

require "lazynvim"
