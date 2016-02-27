
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

  let l:transaction[1] = substitute(l:transaction[1], '^\S\+', strftime("%Y/%m/%d"), '')

  call append(line('$'), l:transaction)
  normal Gzz
  call hledger#buffer#select_date()
endfunction

function! hledger#buffer#select_date() abort
  let l:start = hledger#buffer#search_transaction_start()
  execute l:start
  normal vE
endfunction

function! hledger#buffer#go_next() abort
  let l:line = getline('.')

  if l:line =~ '^\s\+\S\+\s*$'
    let l:spaces = printf('%' . (50 - max([2, len(l:line)])) .'s', '')
    return 'A' . l:spaces
  else
    return "\<Esc>WvE"
  endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
