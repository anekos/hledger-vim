
let s:save_cpo = &cpo
set cpo&vim


let s:unite_source = {
\ 'name': 'hledger',
\ 'max_candidates': 30
\ }

function! s:unite_source.gather_candidates(args, context)
  let l:cur_lnum = line('.')
  let l:descs = []
  let l:exist = {}

  for l:lnum in range(l:cur_lnum, max([1, l:cur_lnum - 500]), -1)
    let l:matches = matchlist(getline(l:lnum), '^\d\+/\d\+/\d\+\s\+\(.\+\)')
    if len(l:matches) > 0 && !has_key(l:exist, l:matches[1])
      call add(l:descs, {'lnum': l:lnum, "desc": l:matches[1]})
      let l:exist[l:matches[1]] = 1
    endif
  endfor

  return map(l:descs,
  \ '{ "word": v:val.desc,
  \    "lnum": v:val.lnum,
  \    "source": "hledger",
  \    "kind": "hledger"}')
endfunction

function! unite#sources#hledger#define() abort
  return s:unite_source
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
