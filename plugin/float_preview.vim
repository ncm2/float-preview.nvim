
let g:float_preview#winhl = get(g:, 'float_preview#winhl', 'Normal:Pmenu,NormalNC:Pmenu')
let g:float_preview#height = get(g:, 'float_preview#height', 0)
let g:float_preview#auto_close = get(g:, 'float_preview#auto_close', 1)

func! s:init()
    " non listed buffer from scratch
    let s:buf = nvim_create_buf(0, 1)
    call nvim_buf_set_option(s:buf, 'buftype', 'nofile')
    call nvim_buf_set_option(s:buf, 'bufhidden', 'hide')
    call nvim_buf_set_lines(s:buf, 0, -1, 0, [])

    let s:win = 0
    let s:olditem = {}

    au TextChangedI,TextChangedP * call s:check()
    au InsertLeave * call s:auto_close()
endfunc

func! s:check()
    let item = copy(v:completed_item)
    if empty(item) || !pumvisible()
        call s:auto_close()
        return
    endif

    let info = get(item, 'info', '')
    if empty(info)
        call s:auto_close()
        return
    endif

    let info = split(info, "\n", 1)
    call nvim_buf_set_lines(s:buf, 0, -1, 0, info)

    if !s:win
        let curwin_id = win_getid()
        if g:float_preview#height == 0
            let prevw_height = &previewheight
        else
            let prevw_height = g:float_preview#height
        endif
        let curw_width = nvim_win_get_width(curwin_id)
        let curw_height = nvim_win_get_height(curwin_id)
        let prevw_row = curw_height - prevw_height
        let opt = { 'relative': 'win',
                    \ 'focusable': v:false,
                    \ 'row': prevw_row,
                    \ 'col': 2,
                    \}
        let s:win = nvim_open_win(s:buf, 0, curw_width, prevw_height, opt)
        call nvim_win_set_option(s:win, 'foldenable', v:false)
        call nvim_win_set_option(s:win, 'wrap', v:true)
        call nvim_win_set_option(s:win, 'statusline', '')
        call nvim_win_set_option(s:win, 'winhl', g:float_preview#winhl)
    endif
endfunc

func! s:auto_close()
    if g:float_preview#auto_close
        call float_preview#close()
    endif
endfunc

func! float_preview#close()
    if s:win
        let id = win_id2win(s:win)
        if id > 0
            silent! execute id . 'close!'
        endif
        call nvim_buf_set_lines(s:buf, 0, -1, 0, [])
        let s:win = 0
    endif
endfunc

call s:init()
