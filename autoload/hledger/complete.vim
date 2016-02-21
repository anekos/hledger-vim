
let s:cache = {'accounts': [], 'titles': []}
let s:initialized = 0

function! s:initialize()
  if s:initialized
    return
  endif

  let l:found_accounts = {}
  let l:title_counter = {}
  let l:result = []

  let l:title_max = get(g:, 'hledger_title_completion_max', 20)

  for l:lnum in range(1, line('$'))

    let l:account_name = matchstr(getline(l:lnum), '^ \+[^ ]\+')
    if len(l:account_name) > 0 && !has_key(l:found_accounts, l:account_name)
      call add(l:result, substitute(l:account_name, '^ *', '', ''))
      let l:found_accounts[l:account_name] = 1
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
      call add(l:result, l:matched . ' ')
    endif
  endfor

  call add(l:result, strftime("%Y/%m/%d "))

  return l:result
endfunction

function! s:account (base) abort
  let l:pattern = substitute(a:base, ':', '[^: ]*:', 'g')

  if a:base !~ ':'
    let l:short = ''
    for l:c in split(a:base, '\zs')
      let l:short .= l:c . '[^: ]*:'
    endfor
    let l:pattern .= '\|' . l:short[: -2]
  endif

  let l:pattern = '^\(' . l:pattern . '\).*'

  let l:result = []
  for l:account in s:cache.accounts
    if match(l:account, l:pattern) >= 0
      call add(l:result, l:account)
    endif
  endfor
  return l:result
endfunction

function! s:title(base) abort
  return s:cache.titles
endfunction

function! s:getlist (base) abort
  let l:line = getline('.')
  if l:line =~ '^ \+'
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
