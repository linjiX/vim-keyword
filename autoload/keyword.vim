""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"    https://github.com/linjiX/vim-keyword                               "
"           _                 _                                    _     "
"    __   _(_)_ __ ___       | | _____ _   ___      _____  _ __ __| |    "
"    \ \ / / | '_ ` _ \ _____| |/ / _ \ | | \ \ /\ / / _ \| '__/ _` |    "
"     \ V /| | | | | | |_____|   <  __/ |_| |\ V  V / (_) | | | (_| |    "
"      \_/ |_|_| |_| |_|     |_|\_\___|\__, | \_/\_/ \___/|_|  \__,_|    "
"                                      |___/                             "
"                                                                        "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function s:HighlightInit()
    let l:fg = s:color_mode .'fg='. s:fg_color
    let l:index = 0
    for l:color in s:bg_colors
        let l:group = 'KeywordHighlight'. l:index
        let l:bg = s:color_mode .'bg='. l:color
        execute 'highlight default '. join([l:group, l:fg, l:bg])
        let l:index += 1
    endfor
endfunction

function s:Init() abort
    if exists('g:keyword_init')
        return
    endif
    let g:keyword_init = 1

    let s:match_info = []
    let s:match_stack = []
    if has('gui_running') || (has('termguicolors') && &termguicolors == 1)
        let s:color_mode = 'gui'
        let s:bg_colors = g:keyword_guibg
        let s:fg_color = g:keyword_guifg
    else
        let s:color_mode = 'cterm'
        let s:bg_colors = g:keyword_ctermbg
        let s:fg_color = g:keyword_ctermfg
    endif
    call s:HighlightInit()
    let l:index = 0
    for l:color in s:bg_colors
        let l:id = g:keyword_magic_match_id + l:index
        let l:group = 'KeywordHighlight'. l:index
        let l:match = {'index':l:index, 'group': l:group, 'pattern': '', 'id': l:id}
        call add(s:match_info, l:match)
        let l:index += 1
    endfor
endfunction

call s:Init()

function s:Word(is_visual) abort
    let l:reg = getreg('"')
    let l:regtype = getregtype('"')
    try
        let l:cmd = a:is_visual ? 'gv""y' : '""yiw'
        execute 'noautocmd silent normal! '. l:cmd
        return @"
    finally
        call setreg('"', l:reg, l:regtype)
    endtry
endfunction

function s:EscapedVword() abort
    return '\V'. substitute(escape(s:Word(1), '\'), '\n', '\\n', 'g')
endfunction

function s:EscapedCword() abort
    let l:cword = s:Word(0)
    if empty(l:cword)
        return '\V\n'
    endif
    if match(l:cword, '\w') == -1
        return '\V'. escape(l:cword, '\')
    else
        return '\<'. l:cword .'\>'
    endif
endfunction

function s:GetPattern(is_visual) abort
    return a:is_visual ? s:EscapedVword()
                \      : s:EscapedCword()
endfunction

function s:SearchMatchInfo(pattern) abort
    for l:match in s:match_info
        if l:match.pattern == a:pattern
            return l:match
        endif
    endfor
    return {}
endfunction

function s:MatchAdd(group, pattern, id) abort
    let l:pattern =  &ignorecase ? '\c'. a:pattern
                \                : a:pattern
    call matchadd(a:group, l:pattern, 10, a:id)
endfunction

function s:Match(is_add, match) abort
    if s:WinMatchInit()
        return
    endif
    if a:is_add
        call s:MatchAdd(a:match.group, a:match.pattern, a:match.id)
    else
        call matchdelete(a:match.id)
    endif
endfunction

function s:WindoMatch(is_add, match) abort
    let l:winid = win_getid()
    try
        if a:is_add
            call add(s:match_stack, a:match.index)
        else
            call remove(s:match_stack, index(s:match_stack, a:match.index))
        endif
        noautocmd tabdo windo call s:Match(a:is_add, a:match)
    finally
        noautocmd call win_gotoid(l:winid)
    endtry
endfunction

function s:PatternAdd(pattern) abort
    let l:match = s:SearchMatchInfo('')
    if empty(l:match)
        echomsg 'No more keyword highlight groups'
        return
    endif
    let l:match.pattern = a:pattern
    call s:WindoMatch(1, l:match)
endfunction

function s:PatternDelete(pattern) abort
    let l:match = s:SearchMatchInfo(a:pattern)
    if empty(l:match)
        return v:false
    endif
    let l:match.pattern = ''
    call s:WindoMatch(0, l:match)
    return v:true
endfunction

function keyword#Clear() abort
    for l:index in s:match_stack
        let l:match = s:match_info[l:index]
        let l:match.pattern = ''
        call s:WindoMatch(0, l:match)
    endfor
endfunction

function keyword#Highlight(is_visual) abort
    let l:pattern = s:GetPattern(a:is_visual)
    if s:PatternDelete(l:pattern)
        return
    endif
    call s:PatternAdd(l:pattern)
endfunction

function keyword#Command(is_visual) abort
    if &lazyredraw == 0
        set lazyredraw
        let l:setlz = ":set nolazyredraw\<CR>"
    else
        let l:setlz = ''
    endif
    if g:keyword_keep_cursor_pos
        let l:setpos = ":noautocmd call setpos('.', ". string(getcurpos()) .")\<CR>"
    else
        let l:setpos = ''
    endif

    let l:matchcmd = ":\<C-u>call keyword#Highlight(". a:is_visual . ")\<CR>"

    return l:matchcmd . l:setpos . l:setlz
endfunction

function s:CursorPatternCheck(pattern) abort
    let l:curpos = getcurpos()
    try
        noautocmd if !search(a:pattern, 'cbW')
            return v:false
        endif

        noautocmd let l:endpos = searchpos(a:pattern, 'ceW')
        let l:pos = l:curpos[1:2]
        if l:pos[0] > l:endpos[0]
            return v:false
        elseif l:pos[0] < l:endpos[0]
            return v:true
        endif

        if l:pos[1] > l:endpos[1]
            return v:false
        endif
        return v:true
    finally
        noautocmd call setpos('.', l:curpos)
    endtry
endfunction

function keyword#NavigatePrepare(is_forward) abort
    for l:index in s:match_stack
        let l:match = s:match_info[l:index]
        if s:CursorPatternCheck(l:match.pattern)
            let s:navigate_pattern = l:match.pattern
            let s:navigate_forward = a:is_forward
            return v:true
        endif
    endfor
    return v:false
endfunction

function keyword#Navigate() abort
    let l:flag = s:navigate_forward ? '' : 'b'
    let l:count = v:count1
    while l:count
        call search(s:navigate_pattern, l:flag)
        let l:count -= 1
    endwhile
endfunction

nnoremap <silent> <Plug>(keyword-navigate) :<C-u>call keyword#Navigate()<CR>

function s:WinMatchInit() abort
    if exists('w:keyword_init')
        return v:false
    endif
    let w:keyword_init = 1
    for l:index in s:match_stack
        let l:match = s:match_info[l:index]
        call s:MatchAdd(l:match.group, l:match.pattern, l:match.id)
    endfor
    return v:true
endfunction

augroup VimKeyword
    autocmd!
    autocmd WinNew,WinEnter * call s:WinMatchInit()
    autocmd ColorScheme * call s:HighlightInit()
augroup END
