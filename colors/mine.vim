"%% SiSU Vim color file
" Slate Maintainer: Name <mail>
:set background=dark
:highlight clear
if version > 580
 hi clear
 if exists("syntax_on")
 syntax reset
 endif
endif
let colors_name = "mine"
:hi Normal guifg=White ctermfg=White
" :hi Cursor guibg=khaki guifg=slategrey
:hi CursorLine gui=underline guibg=none cterm=underline
" :hi VertSplit guibg=#c2bfa5 guifg=grey40 gui=none cterm=reverse
:hi Folded guibg=grey guifg=darkgrey ctermfg=grey ctermbg=darkgrey
:hi FoldColumn guibg=#6c6c6c guifg=#00ffff ctermfg=14 ctermbg=242
:hi SignColumn guibg=#6c6c6c guifg=#00ffff ctermfg=14 ctermbg=242
:hi IncSearch guibg=#ff6d67 ctermbg=red
" :hi ModeMsg guifg=goldenrod cterm=none ctermfg=brown
" :hi MoreMsg guifg=SeaGreen ctermfg=darkgreen
:hi NonText guifg=darkgray ctermfg=darkgray
" :hi Question guifg=springgreen ctermfg=green
" :hi Search guibg=peru guifg=wheat cterm=none ctermfg=grey ctermbg=blue
:hi SpecialKey guifg=darkgray ctermfg=darkgray
:hi StatusLine guifg=black guibg=yellow gui=bold cterm=bold,reverse ctermfg=yellow
:hi StatusLineNC gui=reverse cterm=reverse
:hi Title guifg=#FFFF55 gui=bold cterm=bold ctermfg=yellow
:hi Statement guifg=#FFFF55 gui=bold ctermfg=yellow cterm=bold
:hi Visual guibg=darkyellow ctermbg=darkyellow term=reverse
:hi WarningMsg guifg=#ffd7d7 ctermfg=224
" :hi String guifg=SkyBlue ctermfg=grey
:hi Comment term=bold ctermfg=darkgray guifg=darkgray
:hi Constant guifg=#ff76ff ctermfg=magenta
:hi Special guifg=#d7ff00 ctermfg=190 " yellow2
:hi Identifier guifg=white ctermfg=white
:hi Include guifg=darkcyan gui=bold ctermfg=darkcyan cterm=bold
:hi PreProc guifg=darkcyan gui=bold ctermfg=darkcyan cterm=bold
:hi Operator guifg=lightgreen ctermfg=lightgreen
" :hi Define guifg=gold gui=bold ctermfg=yellow
:hi Type guifg=#A4FEFF gui=bold ctermfg=lightcyan cterm=bold
:hi Function guifg=#57FFFF gui=bold cterm=bold ctermfg=14 " aqua
:hi Structure guifg=lightgreen ctermfg=lightgreen
:hi LineNr guifg=darkgray ctermfg=darkgray
:hi Pmenu guibg=black guifg=white ctermbg=black ctermfg=white
:hi PmenuSel guibg=#c91b00 guifg=white ctermbg=DarkRed ctermfg=white
" :hi Ignore guifg=grey40 cterm=bold ctermfg=7
" :hi Todo guifg=orangered guibg=yellow2
:hi Directory guifg=#A4FEFF ctermfg=lightcyan
" :hi ErrorMsg cterm=bold guifg=White guibg=Red cterm=bold ctermfg=7 ctermbg=1
" :hi VisualNOS cterm=bold,underline
:hi WildMenu guifg=white guibg=#c91b00 ctermfg=White ctermbg=DarkRed
" :hi DiffAdd ctermbg=4
" :hi DiffChange ctermbg=5
:hi DiffChange term=bold guibg=#000000 ctermbg=16 " grey0
" :hi DiffDelete cterm=bold ctermfg=4 ctermbg=6
" :hi DiffText cterm=bold ctermbg=1
:hi DiffText term=reverse gui=bold guibg=#5f0000 cterm=bold ctermbg=52 " DarkRed
:hi diffAdded guifg=#5ff967 ctermfg=10
:hi diffRemoved guifg=#ff6d67 ctermfg=9
:hi Underlined gui=underline guifg=purple cterm=underline ctermfg=5
:hi Error guifg=#141313 guibg=#ff6d67 ctermfg=15 ctermbg=9
" :hi SpellErrors guifg=White guibg=Red cterm=bold ctermfg=7 ctermbg=1
:hi SpellBad guibg=#ff6d67 guifg=black ctermbg=red ctermfg=black
:hi SpellCap guibg=#6871ff ctermbg=12
:hi SpellRare guibg=#ff76ff ctermbg=13
:hi SpellLocal guibg=#5ffdff ctermbg=14
:hi NormalFloat guifg=White guibg=Black ctermfg=White ctermbg=Black
:hi FloatBorder guibg=black ctermbg=black
:hi TelescopeNormal guibg=black ctermbg=black
:hi TelescopeBorder guibg=black ctermbg=black
:hi DiagnosticError guifg=#ff5f5f ctermfg=203 " indianred1
:hi DiagnosticWarn guifg=#ffd75f ctermfg=221 " lightgoldrod2
:hi DiagnosticInfo guifg=#afafff ctermfg=147 " lightsteelblud
:hi DiagnosticHint guifg=#c6c6c6 ctermfg=251 " grey78
:hi DiagnosticOK guifg=#87d700 ctermfg=112 " chartreuse2
:hi @variable.parameter gui=italic cterm=italic
:hi @variable.builtin guifg=#FFFF55 ctermfg=yellow " khaki1
:hi @keyword.operator guifg=lightgreen ctermfg=lightgreen
:hi @constant gui=bold guifg=#ffd7ff cterm=bold ctermfg=225 " thistle1
:hi link @constructor Type
:hi link @function.builtin Function
:hi link @string.documentation Comment
:hi link @constant.builtin @constant
:hi @markup.emphasis gui=italic guifg=lightgreen cterm=italic ctermfg=lightgreen
:hi @markup.strong gui=bold guifg=#ff6d67 cterm=bold ctermfg=red
:hi @markup.strike guifg=gray ctermfg=gray
:hi @markup.link gui=underline guifg=#ff76ff cterm=underline ctermfg=magenta
:hi @markup.escape guifg=gray ctermfg=gray
:hi @markup.raw guifg=#A4FEFF ctermfg=lightcyan
:hi @markup.quote guifg=gray ctermfg=gray
:hi link @markup.heading @text.title
:hi @markup.heading.1 guifg=#FFFF55 gui=bold,underline cterm=bold,underline ctermfg=yellow
