
if exists('g:loaded_hledger')
  finish
endif
let g:loaded_hledger = 1

let s:save_cpo = &cpo
set cpo&vim


nnoremap <silent> <Plug>(hledger-clone-transaction) :<C-u>call hledger#command#clone_transaction()<CR>
nnoremap <silent> <Plug>(hledger-unite-transactions) :<C-u>call hledger#command#unite_transactions()<CR>
nnoremap <silent> <expr> <Plug>(hledger-go-next) hledger#buffer#go_next()


let &cpo = s:save_cpo
unlet s:save_cpo
