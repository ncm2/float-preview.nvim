
let g:float_preview#winhl = get(g:, 'float_preview#winhl', 'Normal:Pmenu,NormalNC:Pmenu')
let g:float_preview#height = get(g:, 'float_preview#height', 0)
let g:float_preview#auto_close = get(g:, 'float_preview#auto_close', 1)

func! s:init()
    let s:win = 0
    let s:last_winargs = []

    " unlisted-buffer & scratch-buffer (nobuflisted, buftype=nofile,
    " bufhidden=hide, noswapfile)
    let s:buf = nvim_create_buf(0, 1)
    call nvim_buf_set_lines(s:buf, 0, -1, 0, [])
    call nvim_buf_set_option(s:buf, 'syntax', 'OFF')

    au TextChangedI,TextChangedP * call s:check()
    au InsertLeave * call s:auto_close()
    au VimResized,VimResume * call s:reopen()
endfunc

func! s:reopen()
    call float_preview#close()
    call s:check()
endfunc

func! s:check()
    if empty(v:completed_item) || !pumvisible()
        " echom 'emptyitem or !pumvisible()'
        call s:auto_close()
        return
    endif

    let info = get(v:completed_item, 'info', '')
    if empty(info)
        " echom 'empty info'
        call s:auto_close()
        return
    endif

    let info = split(info, "\n", 1)
    call nvim_buf_set_lines(s:buf, 0, -1, 0, info)

    let cwinid = win_getid()

    let winline = winline()
    let winheight = winheight(cwinid)
    let winwidth = winwidth(cwinid)

    let prevw_height = g:float_preview#height ? 
                \ g:float_preview#height : &previewheight

    let down_avail = winheight - winline - prevw_height
    let up_avail = winline - 1 - prevw_height
    if up_avail <= 0 && down_avail <= 0
        " no enough space to displace the preview window
        " echom 'no space avilable'
        call s:auto_close()
        return
    endif

    if down_avail < 0 || up_avail > down_avail * 2
        " ue up
        let prevw_row = 0
    else
        " use down
        let prevw_row = winheight - prevw_height
    endif

    let opt = { 'relative': 'win',
                \ 'focusable': v:false,
                \ 'row': prevw_row,
                \ 'col': 2,
                \}

    let winargs = [s:buf, 0, winwidth, prevw_height, opt]

    if !s:win || s:last_winargs != winargs
        " close the old one if already opened
        call float_preview#close()

        let s:win = call('nvim_open_win', winargs)
        let s:last_winargs = winargs
        call nvim_win_set_option(s:win, 'foldenable', v:false)
        call nvim_win_set_option(s:win, 'wrap', v:true)
        call nvim_win_set_option(s:win, 'statusline', '')
        call nvim_win_set_option(s:win, 'winhl', g:float_preview#winhl)
        " echom 'open'
    else
        " echom 'skip'
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
            execute id . 'close!'
        endif
        call nvim_buf_set_lines(s:buf, 0, -1, 0, [])
        let s:win = 0
        let s:last_winargs = []
    endif
endfunc

call s:init()
