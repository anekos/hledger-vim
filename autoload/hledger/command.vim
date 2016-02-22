
let s:save_cpo = &cpo
set cpo&vim


function! hledger#command#clone_transaction() abort
  let l:start = line('.')

  while match(getline(l:start), '^\d\+/\d\+/\d\+') < 0
    let l:start -= 1
  endwhile

  let l:transaction = ['']

  let l:end = l:start
  while match(getline(l:end), '^$') < 0
    call add(l:transaction, getline(l:end))
    let l:end += 1
  endwhile

  call append(line('$'), l:transaction)
  normal Gzz
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
