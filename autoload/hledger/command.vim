
let s:save_cpo = &cpo
set cpo&vim


function! hledger#command#clone_transaction() abort
  call hledger#buffer#clone_transaction(hledger#buffer#search_transaction_start())
endfunction


function! hledger#command#unite_transactions() abort
  call unite#custom#source('hledger', 'matchers', 'matcher_migemo')
  call unite#start([['hledger']])
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
