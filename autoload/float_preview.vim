if get(s:, 'loaded')
    finish
endif
let s:loaded = 1

" TODO
" let g:float_preview#min_width = get(g:, 'float_preview#max_width', 30)

" TODO
" create empty windows to simulate padding

" TODO
" allow customized completion item resolve

let s:timer = 0
let g:float_preview#win = 0
let s:event = {}
let s:item = {}

let s:last_event = {}
let s:last_winargs = []

let s:buf = 0

func! float_preview#_insert_leave()
    call s:auto_close()
endfunc

func! float_preview#_menu_popup_changed()
    let s:event = copy(v:event)
    let s:item = copy(v:event.completed_item)
    call float_preview#start_check()
endfunc

func! float_preview#_complete_done()
    let s:item = copy(v:completed_item)
    call float_preview#start_check()
endfunc

func! float_preview#start_check()
    " use timer_start since nvim_buf_set_lines is not allowed in
    " CompleteChanged
    if s:timer
        call timer_stop(s:timer)
        let s:timer = 0
    endif
    let s:timer = timer_start(0, function('s:check'))
endfunc

let s:log_id = 0
func s:log(msg)
    let s:log_id += 1
    echom s:log_id . ' ' . a:msg
endfunc

func! s:check(...)
    let s:timer = 0

    if empty(s:item) || !pumvisible()
        call s:auto_close()
        " call s:log('empty item')
        return
    endif

    if g:float_preview#win && s:event == s:last_event
        " let s:skip_cnt = get(s:, 'skip_cnt', 0) + 1
        " echom 'already opened, skip ' . s:skip_cnt
        return
    endif
    let s:last_event = s:event

    let info = trim(get(s:item, 'info', ''))
    if empty(info)
        call float_preview#close()
        " call s:log('empty info')
        return
    endif

    let info = split(info, "\n", 1)

    if !s:buf
        " unlisted-buffer & scratch-buffer (nobuflisted, buftype=nofile,
        " bufhidden=hide, noswapfile)
        let s:buf = nvim_create_buf(0, 1)
        call nvim_buf_set_option(s:buf, 'syntax', 'OFF')
    endif
    call nvim_buf_set_lines(s:buf, 0, -1, 0, info)

    if g:float_preview#docked
        let prevw_width = winwidth(0)
    else
        let prevw_width = float_preview#display_width(info, g:float_preview#max_width)
    endif
    let prevw_height = float_preview#display_height(info, prevw_width) + 1

    let opt = { 'focusable': v:false,
                \ 'width': prevw_width,
                \ 'height': prevw_height
                \}

    if g:float_preview#docked
        let opt.relative = 'win'

        let winline = winline()
        let winheight = winheight(0)

        let down_avail = winheight - winline - prevw_height
        let up_avail = winline - 1 - prevw_height
        if up_avail <= 0 && down_avail <= 0
            " no enough space to displace the preview window
            call float_preview#close()
            return
        endif

        if down_avail < 0 || up_avail > down_avail * 2
            let opt.row = 0
        else
            " use down
            let opt.row = winheight - prevw_height
        endif
        let opt.col  = 0
    else
        let opt.relative = 'editor'

        if s:event.scrollbar
            let right_avail_col  = s:event.col + s:event.width + 1
        else
            let right_avail_col  = s:event.col + s:event.width
        endif
        " -1 for zero-based indexing, -1 for vim's popup menu padding
        let left_avail_col = s:event.col - 2

        let right_avail = &co - right_avail_col
        let left_avail = left_avail_col + 1

        if right_avail >= prevw_width
            let opt.col = right_avail_col
        elseif left_avail >= prevw_width
            let opt.col = left_avail_col - prevw_width + 1
        else
            " no enough space to displace the preview window
            call float_preview#close()
            return
        endif

        let opt.row = s:event.row
    endif

    let winargs = [s:buf, 0, opt]

    " close the old one if already opened
    call float_preview#close()

    let g:float_preview#win = call('nvim_open_win', winargs)
    call nvim_win_set_option(g:float_preview#win, 'foldenable', v:false)
    call nvim_win_set_option(g:float_preview#win, 'wrap', v:true)
    call nvim_win_set_option(g:float_preview#win, 'statusline', '')
    call nvim_win_set_option(g:float_preview#win, 'winhl', g:float_preview#winhl)
    call nvim_win_set_option(g:float_preview#win, 'number', v:false)
    call nvim_win_set_option(g:float_preview#win, 'relativenumber', v:false)
    call nvim_win_set_option(g:float_preview#win, 'cursorline', v:false)

    silent doautocmd <nomodeline> User FloatPreviewWinOpen
endfunc

func! s:auto_close()
    if g:float_preview#auto_close || !g:float_preview#docked
        call float_preview#close()
    endif
endfunc

func! float_preview#reopen()
    " call s:log('reopen')
    call float_preview#close()
    call float_preview#start_check()
endfunc

func! float_preview#close()
    if g:float_preview#win
        let id = win_id2win(g:float_preview#win)
        if id > 0
            execute id . 'close!'
        endif
        let g:float_preview#win = 0
        let s:last_winargs = []
    endif
endfunc

func! float_preview#display_width(lines, max_width)
    let width = 0
    for line in a:lines
        let w = strdisplaywidth(line)
        if w < a:max_width
            if w > width
                let width = w
            endif
        else
            let width = a:max_width
        endif
    endfor
    return width
endfunc

func! float_preview#display_height(lines, width)
    " 1 for padding
    let height = 1

    for line in a:lines
        let height += (strdisplaywidth(line) + a:width - 1) / a:width
    endfor

    let max_height = g:float_preview#max_height ?
                \ g:float_preview#max_height : &previewheight

    return height > max_height ? max_height : height
endfunc

func! float_preview#_s(name, ...)
    if len(a:000)
        execute 'let s:' . a:name ' = a:1'
    endif
    return get(s:, a:name)
endfunc

