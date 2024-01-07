syntax match scallopEditConcealOne contained /\S/ conceal cchar=* oneline display
syntax match scallopEditConcealMulti contained /\S\+/ contains=scallopEditConcealOne oneline display

syntax match scallopEditConcealGithubToken /\<ghp_\S\{3}/ nextgroup=scallopEditConcealMulti oneline display
syntax match scallopEditConcealAWSAccessKeys /\<AWS_\(ACCESS_KEY_ID\|SECRET_ACCESS_KEY\|SESSION_TOKEN\)="\?\S\{3}/ nextgroup=scallopEditConcealMulti oneline display

setl conceallevel=2
setl concealcursor=nvic
