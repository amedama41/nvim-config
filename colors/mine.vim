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
:hi Normal guifg=White guibg=grey15 ctermfg=White
" :hi Cursor guibg=khaki guifg=slategrey
" :hi VertSplit guibg=#c2bfa5 guifg=grey40 gui=none cterm=reverse
:hi Folded guibg=black guifg=grey40 ctermfg=grey ctermbg=darkgrey
" :hi FoldColumn guibg=black guifg=grey20 ctermfg=4 ctermbg=7
:hi IncSearch guifg=green guibg=black cterm=none ctermbg=red
" :hi ModeMsg guifg=goldenrod cterm=none ctermfg=brown
" :hi MoreMsg guifg=SeaGreen ctermfg=darkgreen
:hi NonText guifg=RoyalBlue guibg=grey15 ctermfg=darkgray
" :hi Question guifg=springgreen ctermfg=green
" :hi Search guibg=peru guifg=wheat cterm=none ctermfg=grey ctermbg=blue
:hi SpecialKey guifg=yellowgreen ctermfg=darkgray
:hi StatusLine guibg=#c2bfa5 guifg=black gui=none cterm=bold,reverse ctermfg=yellow
:hi StatusLineNC guibg=#c2bfa5 guifg=grey40 gui=none cterm=reverse
:hi Title guifg=gold gui=bold cterm=bold ctermfg=yellow
:hi Statement guifg=CornflowerBlue ctermfg=yellow cterm=bold
:hi Visual gui=none guifg=khaki guibg=olivedrab ctermbg=darkyellow term=reverse
" :hi WarningMsg guifg=salmon ctermfg=1
" :hi String guifg=SkyBlue ctermfg=grey
:hi Comment term=bold ctermfg=darkgray guifg=grey40
:hi Constant guifg=#ffa0a0 ctermfg=magenta
:hi Special guifg=darkkhaki ctermfg=190 " yellow2
:hi Identifier cterm=none guifg=salmon ctermfg=white
:hi Include guifg=red ctermfg=darkcyan cterm=bold
:hi PreProc guifg=red guibg=White ctermfg=darkcyan cterm=bold
:hi Operator guifg=Red ctermfg=lightgreen
" :hi Define guifg=gold gui=bold ctermfg=yellow
:hi Type guifg=CornflowerBlue ctermfg=lightcyan cterm=bold
:hi Function guifg=navajowhite cterm=bold ctermfg=14 " aqua
:hi Structure guifg=green ctermfg=lightgreen
:hi LineNr guifg=grey50 ctermfg=darkgray
:hi Pmenu ctermbg=black ctermfg=white
:hi PmenuSel ctermbg=DarkRed ctermfg=white
" :hi Ignore guifg=grey40 cterm=bold ctermfg=7
" :hi Todo guifg=orangered guibg=yellow2
:hi Directory ctermfg=lightcyan
" :hi ErrorMsg cterm=bold guifg=White guibg=Red cterm=bold ctermfg=7 ctermbg=1
" :hi VisualNOS cterm=bold,underline
:hi WildMenu ctermfg=White ctermbg=DarkRed
" :hi DiffAdd ctermbg=4
" :hi DiffChange ctermbg=5
:hi DiffChange term=bold ctermbg=16
" :hi DiffDelete cterm=bold ctermfg=4 ctermbg=6
" :hi DiffText cterm=bold ctermbg=1
:hi DiffText term=reverse cterm=bold ctermbg=52
" :hi Underlined cterm=underline ctermfg=5
" :hi Error guifg=White guibg=Red cterm=bold ctermfg=7 ctermbg=1
" :hi SpellErrors guifg=White guibg=Red cterm=bold ctermfg=7 ctermbg=1
:hi SpellBad ctermbg=red ctermfg=black
:hi NormalFloat guifg=White guibg=grey15 ctermfg=White ctermbg=Black
:hi FloatBorder ctermbg=black
:hi TelescopeNormal ctermbg=black
:hi TelescopeBorder ctermbg=black
:hi DiagnosticError ctermfg=203 " indianred1
:hi DiagnosticWarn ctermfg=221 " lightgoldrod2
:hi DiagnosticInfo ctermfg=147 " lightsteelblud
:hi DiagnosticHint ctermfg=251 " grey78
:hi DiagnosticOK ctermfg=112 " chartreuse2
:hi @parameter cterm=italic
:hi @variable.builtin ctermfg=yellow " khaki1
:hi @keyword.operator ctermfg=lightgreen cterm=none
:hi @constant guifg=#ffa0a0 cterm=bold ctermfg=225 " thistle1
:hi link @constructor Type
:hi link @function.builtin Function
:hi link @string.documentation Comment
:hi link @constant.builtin @constant
:hi @markup.emphasis cterm=italic ctermfg=lightgreen
:hi @markup.strong cterm=bold ctermfg=red
:hi @markup.strike ctermfg=gray
:hi @markup.link cterm=underline ctermfg=magenta
:hi @markup.escape ctermfg=gray
:hi @markup.raw ctermfg=lightcyan
:hi @markup.quote ctermfg=gray
:hi link @markup.heading @text.title
:hi @markup.heading.1 guifg=gold gui=bold cterm=bold,underline ctermfg=yellow
