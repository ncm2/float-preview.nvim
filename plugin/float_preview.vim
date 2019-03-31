if get(g:, 'float_preview#loaded')
    finish
endif
let g:float_preview#loaded = 1

let g:float_preview#winhl = get(g:, 'float_preview#winhl', 'Normal:Pmenu,NormalNC:Pmenu')
let g:float_preview#max_height = get(g:, 'float_preview#max_height', 0)
let g:float_preview#auto_close = get(g:, 'float_preview#auto_close', 1)
let g:float_preview#docked = get(g:, 'float_preview#docked', 1)

" only used for g:float_preview#docked == 0
let g:float_preview#max_width = get(g:, 'float_preview#max_width', 50)

au CompleteChanged * call float_preview#_menu_popup_changed()
au CompleteDone * call float_preview#_complete_done()

au InsertLeave * call float_preview#_insert_leave()
au VimResized,VimResume * call float_preview#reopen()
