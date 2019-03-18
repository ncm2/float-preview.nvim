if get(g:, 'float_preview#loaded')
    finish
endif
let g:float_preview#loaded = 1

au MenuPopupChanged * call float_preview#_menu_popup_changed()
au CompleteDone * call float_preview#_complete_done()

au InsertLeave * call float_preview#_insert_leave()
au VimResized,VimResume * call float_preview#reopen()
