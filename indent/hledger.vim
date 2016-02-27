
if exists('b:did_indent')
  finish
endif


setlocal autoindent
setlocal indentexpr=hledger#indent#expr()
setlocal indentkeys=!^F,o,O

setlocal expandtab
setlocal tabstop<
setlocal softtabstop=4
setlocal shiftwidth=4

let b:undo_indent = 'setlocal '.join([
\   'autoindent<',
\   'expandtab<',
\   'indentexpr<',
\   'indentkeys<',
\   'shiftwidth<',
\   'softtabstop<',
\   'tabstop<',
\ ])


let b:did_indent = 1
