let s:save_cpo = &cpo
set cpo&vim


function! hledger#indent#expr()
  let l:prev = getline(v:lnum - 1)

  if l:prev =~ '^\s*$'
    return 0
  elseif l:prev =~ '^\d\+/\d\+/\d\+ \+'
    return &l:shiftwidth
  else
    return -1
  endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
