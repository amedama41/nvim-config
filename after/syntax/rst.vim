syn region rstExplicitMarkup keepend
      \ start=+^\z(\s*\)\.\.\s+
      \ skip=+^\(\(\z1\s\+\)\@>\S\|\s*$\)+
      \ end=+^\ze\s*\S+
      \ contains=rstExplicitMarkupDot,@rstDirectives,rstSubstitutionDefinition,rstComment
syn match rstExplicitMarkupDot '^\s*\.\.\_s' contained
      \ nextgroup=@rstDirectives,rstSubstitutionDefinition,rstComment

let s:rst_directive_list = {
      \ 'list-table': 'rstDirectiveListTable',
      \ 'figure': 'rstDirectiveFigure',
      \ 'topic' : 'rstDirectiveTopic',
      \ 'sidebar': 'rstDirectiveSidebar',
      \ 'hlist': 'rstDirectiveHList',
      \ }
for s:directive in keys(s:rst_directive_list)
    let s:group_name = s:rst_directive_list[s:directive]
    exe 'syn region '.s:group_name.' contained matchgroup=rstDirective fold'
          \. ' start=+'.s:directive.'::\%(\s\+.*\)\=\_s*\n\ze\z(\s\+\)+'
          \. ' skip=+^$+'
          \. ' end=+^\z1\@!+'
          \. ' contains=@rstCruft,rstExplicitMarkup,@Spell'
    exe 'syn cluster rstDirectives add='.s:group_name
endfor

syn region rstDirectiveTable contained matchgroup=rstDirective fold
      \ start=+table::\%(\s\+.*\)\=\_s*\n\ze\z(\s\+\)+
      \ skip=+^$+
      \ end=+^\z1\@!+
      \ contains=@rstTable,@Spell
syn cluster rstDirectives add=rstDirectiveTable

let s:rst_directive_list = {
      \ 'attention': 'rstDirectiveAttention',
      \ 'caution': 'rstDirectiveCaution',
      \ 'danger': 'rstDirectiveDanger',
      \ 'error': 'rstDirectiveError',
      \ 'hint': 'rstDirectiveHint',
      \ 'important': 'rstDirectiveImportant',
      \ 'note': 'rstDirectiveNote',
      \ 'tip': 'rstDirectiveTip',
      \ 'warning': 'rstDirectiveWarning',
      \ 'todo': 'rstDirectiveTodo',
      \ 'seealso': 'rstDirectiveSeealso',
      \ }
for s:directive in keys(s:rst_directive_list)
    let s:group_name = s:rst_directive_list[s:directive]
    exe 'syn region '.s:group_name.' contained matchgroup=rstDirective' .
          \ ' start=+'.s:directive.'::\_s+' .
          \ ' skip=+^$+' .
          \ ' end=+^\s\@!+'
          \ ' contains=@rstCruft,rstExplicitMarkup,@Spell'
    exe 'syn cluster rstDirectives add='.s:group_name
endfor

unlet! b:current_syntax
syn include @rstdot syntax/dot.vim
syn region rstGraphviz contained matchgroup=rstDirective fold
      \ start=+graphviz::\%(\s\+.*\)\=\_s*\n\ze\z(\s\+\)+
      \ skip=+^$+
      \ end=+^\z1\@!+
      \ contains=@NoSpell,@rstdot
syn cluster rstDirectives add=rstGraphviz
