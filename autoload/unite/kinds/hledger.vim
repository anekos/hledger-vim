let s:save_cpo = &cpo
set cpo&vim


let s:kind = {
\ 'name' : 'hledger',
\ 'default_action' : 'clone',
\ 'action_table' : {},
\ 'alias_table' : {},
\}


let s:kind.action_table.clone = {
\ 'description' : 'Clone transaction',
\}
function! s:kind.action_table.clone.func(candidate) abort
  call hledger#buffer#clone_transaction(a:candidate.word)
endfunction

function! unite#kinds#hledger#define()
  return s:kind
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
