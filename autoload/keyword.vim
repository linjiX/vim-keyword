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

function s:Init() abort
    if !empty(s:match_info)
        return
    endif
    let l:index = 0
    for l:color in g:keyword_colors
        let l:id = g:keyword_magic_match_id + l:index
        let l:group = 'Star'. l:index
        execute 'highlight default '. l:group .' ctermfg=0 ctermbg='. l:color
        let l:match = {'group': l:group, 'pattern': '', 'id': l:id}
        call add(s:match_info, l:match)
        let l:index += 1
    endfor
endfunction

let s:match_info = []
call s:Init()

function s:Vword() abort
    let l:temp = @s
    noautocmd silent normal! gv"sy
    let [l:temp, @s] = [@s, l:temp]
    return l:temp
endfunction

function s:Cword() abort
    let l:temp = @s
    noautocmd silent normal! "syiw
    let [l:temp, @s] = [@s, l:temp]
    return l:temp
endfunction

function s:EscapedVword() abort
    return '\V'. substitute(escape(s:Vword(), '\'), '\n', '\\n', 'g')
endfunction

function s:EscapedCword() abort
    let l:cword = s:Cword()
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

function s:WindoMatchAdd(group, pattern, id) abort
    let l:winid = win_getid()
    try
        noautocmd tabdo windo call matchadd(a:group, a:pattern, 10, a:id)
    finally
        noautocmd call win_gotoid(l:winid)
    endtry
endfunction

function s:WindoMatchDelete(id) abort
    let l:winid = win_getid()
    try
        noautocmd silent! tabdo windo call matchdelete(a:id)
    finally
        noautocmd call win_gotoid(l:winid)
    endtry
endfunction

function s:Highlight(pattern) abort
    let l:match = s:SearchMatchInfo('')
    if empty(l:match)
        echomsg 'No more keyword highlight groups'
        return
    endif
    call s:WindoMatchAdd(l:match.group, a:pattern, l:match.id)
    let l:match.pattern = a:pattern
endfunction

function s:HighlightDisable(pattern) abort
    let l:match = s:SearchMatchInfo(a:pattern)
    if empty(l:match)
        return v:false
    endif
    call s:WindoMatchDelete(l:match.id)
    let l:match.pattern = ''
    return v:true
endfunction

function keyword#ClearMatches() abort
    for l:match in s:match_info
        if !empty(l:match.pattern)
            call s:WindoMatchDelete(l:match.id)
            let l:match.pattern = ''
        endif
    endfor
endfunction

function keyword#Keyword(is_visual) abort
    let l:pattern = s:GetPattern(a:is_visual)
    if s:HighlightDisable(l:pattern)
        return
    endif
    call s:Highlight(l:pattern)
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

    let l:matchcmd = ":\<C-u>call keyword#Keyword(". a:is_visual . ")\<CR>"

    return l:matchcmd . l:setpos . l:setlz
endfunction

function s:WinNewMatch() abort
    for l:match in s:match_info
        if !empty(l:match.pattern)
            call matchadd(l:match.group, l:match.pattern, 10, l:match.id)
        endif
    endfor
endfunction

augroup VimKeyword
    autocmd!
    autocmd WinNew * call s:WinNewMatch()
augroup END
