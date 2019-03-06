# float-preview.nvim

- Completion preview window based on neovim's [floating window](https://github.com/neovim/neovim/pull/6619)

Note that this is a general purpose plugin instead of ncm2 only, it applies to
`:help complete-items` with `info` field available.

## Why ？

Vim's builtin completion preview window is annoying. When the preview window
gets opened, it simply pumps the text out of my eye spot. Which makes it very
disturbing and actually unusable.

This plugin uses neovim's floating Window, it never pumps the text out of your
eye spot.

## Config && API

### `g:float_preview#winhl`

Custom highlights for preview window. See `:help 'winhl'` for more
information.

### `g:float_preview#height`

Height of the preview window. Defaults to `:help 'previewheight'`.

### `g:float_preview#auto_close`

Defaults to 1. If you don't want this plugin auto closing the preview window,
use `:let g:float_preview#auto_close = 0` and `call float_preview#close()` by
yourself.

