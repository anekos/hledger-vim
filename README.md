
# Support writing hldeger journal

This plugin provides

- Omni completion (dates, accounts)
- Unite source "hledger"
- Some mappings


## In your .vimrc

```
autocmd FileType hledger setlocal omnifunc=hledger#complete#omnifunc
```
