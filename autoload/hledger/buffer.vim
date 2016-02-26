
let s:save_cpo = &cpo
set cpo&vim


function! hledger#buffer#search_transaction_start() abort
  let l:start = line('.')

  while match(getline(l:start), '^\d\+/\d\+/\d\+') < 0
    let l:start -= 1
  endwhile

  return l:start
endfunction

function! hledger#buffer#clone_transaction(start) abort
  let l:transaction = ['']

  let l:end = a:start
  while match(getline(l:end), '^$') < 0
    call add(l:transaction, getline(l:end))
    let l:end += 1
  endwhile

  let l:transaction[1] = substitute(l:transaction[1], '^\S\+', strftime("%Y/%m/%d "), '')

  call append(line('$'), l:transaction)
  normal Gzz
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
