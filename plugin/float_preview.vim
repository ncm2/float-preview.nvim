
func! s:init()
    " non listed buffer from scratch
    let s:buf = nvim_create_buf(0, 1)
    call nvim_buf_set_option(s:buf, 'buftype', 'nofile')
    call nvim_buf_set_option(s:buf, 'bufhidden', 'hide')
    call nvim_buf_set_lines(s:buf, 0, -1, 0, [])

    let s:win = 0
    let s:olditem = {}

    au TextChangedI,TextChangedP * call s:check()
    au InsertLeave * call s:close()
endfunc

func! s:check()
    let item = copy(v:completed_item)
    if empty(item) || !pumvisible()
        call s:close()
        return
    endif

    let info = get(item, 'info', '')
    if empty(info)
        call s:close()
        return
    endif

    let info = split(info, "\n", 1)
    call nvim_buf_set_lines(s:buf, 0, -1, 0, info)

    if !s:win
        let curwin_id = win_getid()
        let prevw_height = &previewheight
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
    endif
endfunc

func! s:close()
    if s:win
        let id = win_id2win(s:win)
        if id > 0
            execute id . 'close!'
        endif
        call nvim_buf_set_lines(s:buf, 0, -1, 0, [])
        let s:win = 0
    endif
endfunc

call s:init()
