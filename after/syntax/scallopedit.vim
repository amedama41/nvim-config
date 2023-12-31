syntax match scallopEditConcealOne contained /\w/ conceal cchar=* oneline display
syntax match scallopEditConcealMulti contained /\w\+/ contains=scallopEditConcealOne oneline display

syntax match scallopEditConcealGithubToken /\<ghp_\w\{3}/ nextgroup=scallopEditConcealMulti oneline display
syntax match scallopEditConcealAWSAccessKeys /\<AWS_\(ACCESS_KEY\|SECRET_ACCESS_KEY\|SESSIO_TOKEN\)=\w\{3}/ nextgroup=scallopEditConcealMulti oneline display

setl conceallevel=2
setl concealcursor=nvic
