# float-preview.nvim

- Completion preview window based on neovim's [floating window](https://github.com/neovim/neovim/pull/6619)

With `let g:float_preview#docked = 1`:

[![asciicast](https://asciinema.org/a/232057.svg)](https://asciinema.org/a/232057)

With `let g:float_preview#docked = 0`:

[![asciicast](https://asciinema.org/a/234259.svg)](https://asciinema.org/a/234259)

Note that this is a general purpose plugin instead of ncm2 only, it applies to
`:help complete-items` with `info` field available.

## Why ？

Vim's builtin `set completeopt+=preview` is annoying. When the preview window
is opened, it simply pumps text out of my eye spot. Which makes it very
disturbing and actually unusable.

This plugin uses neovim's floating Window, it should never pumps text out of
your eye spot.

## Config && API

### `g:float_preview#win`

When the floating window opens, float-preview.nvim will emit a custom autocommand which you can use to further configure the opened window. The window ID will be exposed through `g:float_preview#win`.

Example: a function that disables numbers and the cursor line in the opened window.

```
function! DisableExtras()
  call nvim_win_set_option(g:float_preview#win, 'number', v:false)
  call nvim_win_set_option(g:float_preview#win, 'relativenumber', v:false)
  call nvim_win_set_option(g:float_preview#win, 'cursorline', v:false)
endfunction

autocmd User FloatPreviewWinOpen call DisableExtras()
```

### `g:float_preview#docked`

If set to 0, the preview window will be displayed beside the popup menu.
Defaults to `1`.

### `g:float_preview#winhl`

Custom highlights for preview window. See `:help 'winhl'` for more
information.

### `g:float_preview#max_height`

Height of the preview window. Defaults to `:help 'previewheight'`.

### `g:float_preview#max_width`

Only used when `g:float_preview#docked == 0`. Max width of the preview window.
Defaults to `50`.

### `g:float_preview#auto_close`

Defaults to 1. Only used when `g:float_preview#docked == 1`.

If you don't want this plugin auto closing the preview window,
use `:let g:float_preview#auto_close = 0` and `call float_preview#close()` by
yourself.

