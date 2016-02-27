let s:save_cpo = &cpo
set cpo&vim


let s:cache = {'accounts': {}, 'titles': []}
let s:initialized = 0

function! s:initialize() abort
  if s:initialized
    return
  endif

  let l:title_counter = {}
  let l:result = {}

  let l:title_max = get(g:, 'hledger_title_completion_max', 20)

  for l:lnum in range(1, line('$'))

    let l:account_name = matchstr(getline(l:lnum), '^ \+[^ ]\+')

    if len(l:account_name) > 0
      let l:account = l:result
      for l:path in split(substitute(l:account_name, '^ *', '', ''), ':')
        if !has_key(l:account, l:path)
          let l:account[l:path] = {}
        endif
        let l:account = l:account[l:path]
      endfor
    endif

    let l:title = substitute(matchstr(getline(l:lnum), '^\d\+/\d\+/\d\+ \+.\+$'), '^.* \+', '', '')
    if len(l:title) > 0
      if has_key(l:title_counter, l:title)
        let l:title_counter[l:title] += 1
      else
        let l:title_counter[l:title] = 1
      endif
    endif
  endfor

  let l:title_counts = []
  for l:title in keys(l:title_counter)
    call add(l:title_counts, string(l:title_counter[l:title]) . ':' . l:title)
  endfor
  call sort(l:title_counts, 'N')

  let s:cache.accounts = l:result
  let s:cache.titles = reverse(map(l:title_counts[-l:title_max : ], 'substitute(v:val, ".*:", "", "")'))

  let s:initialized = 1

  return
endfunction

function! s:date (base) abort
  let l:result = []

  let l:cur_lnum = line('.')
  let l:prev = ''
  for l:lnum_d in range(1, 30)
    let l:line = getline(l:cur_lnum - l:lnum_d)
    let l:matched = matchstr(l:line, '^\d\+/\d\+/\d\+')
    if len(l:matched) > 0
      call add(l:result, l:matched)
    endif
  endfor

  call add(l:result, strftime("%Y/%m/%d "))

  return l:result
endfunction

function! s:account_add (result, account, path, prefix)
  if len(a:path) <= 0
    return
  endif

  let l:pattern = printf('.*%s.*', a:path[0])
  let l:last = len(a:path) == 1

  for l:key in keys(a:account)
    if l:key =~ l:pattern
      if l:last
        call add(a:result, join(a:prefix + [l:key], ':'))
      else
        call s:account_add(a:result, a:account[l:key], a:path[1:], a:prefix + [l:key])
      endif
    endif
  endfor
endfunction

function! s:account (base) abort
  let l:result = []
  call s:account_add(l:result, s:cache.accounts, split(a:base, ':', -1), [])
  return l:result
endfunction

function! s:title(base) abort
  return s:cache.titles
endfunction

function! s:getlist (base) abort
  let l:line = getline('.')
  let l:col = col('.')
  if l:col > 1
    let l:matched = matchlist(l:line, '^\(\s\+\S\+\)\s\+')
    if len(l:matched) && len(l:matched[1]) < l:col
      return []
    endif
    return s:account(a:base)
  elseif l:line =~ '^\d\+/\d\+/\d\+ \+'
    return s:title(a:base)
  else
    return s:date(a:base)
  endif
endfunction

function! s:getpos (base) abort
  let l:line = getline('.')
  let l:start = col('.') - 1
  while l:start > 0 && line[l:start - 1] != ' '
    let l:start -= 1
  endwhile
  return l:start
endfunction

function! hledger#complete#omnifunc (findstart, base) abort
  if a:findstart == 1
    return s:getpos(a:base)
  else
    call s:initialize()
    return s:getlist(a:base)
  endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
