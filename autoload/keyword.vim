"""""""""""""""""""""""""""""""""""""""""""""""""""
"    https://github.com/linjiX/vim-keyword        "
"     _                                    _      "
"    | | _____ _   ___      _____  _ __ __| |     "
"    | |/ / _ \ | | \ \ /\ / / _ \| '__/ _` |     "
"    |   <  __/ |_| |\ V  V / (_) | | | (_| |     "
"    |_|\_\___|\__, | \_/\_/ \___/|_|  \__,_|     "
"              |___/                              "
"                                                 "
"""""""""""""""""""""""""""""""""""""""""""""""""""

function s:Init() abort
    if !empty(s:match_info)
        return
    endif
    let l:index = 0
    for l:color in g:star_keyword_colors
        let l:id = g:star_keyword_magic_match_id + l:index
        let l:group = 'Star'. l:index
        execute 'highlight default '. l:group .' ctermfg=0 ctermbg='. l:color
        let l:match = {'group': l:group, 'pattern': '', 'id': l:id}
        call add(s:match_info, l:match)
        let l:index += 1
    endfor
endfunction

let s:match_info = []
call s:Init()

function s:SearchMatchInfo(pattern) abort
    for l:match in s:match_info
        if l:match.pattern == a:pattern
            return l:match
        endif
    endfor
    return {}
endfunction

function s:Match(pattern) abort
    let l:match = s:SearchMatchInfo('')
    if empty(l:match)
        echomsg 'No more keyword highlight groups'
        return
    endif
    windo call matchadd(l:match.group, a:pattern, 10, l:match.id)
    let l:match.pattern = a:pattern
endfunction

function s:MatchDelete(pattern) abort
    let l:match = s:SearchMatchInfo(a:pattern)
    if empty(l:match)
        return v:false
    endif
    windo call matchdelete(l:match.id)
    let l:match.pattern = ''
    return v:true
endfunction

function keyword#ClearMatches() abort
    for l:match in s:match_info
        if !empty(l:match.pattern)
            windo call matchdelete(l:match.id)
            let l:match.pattern = ''
        endif
    endfor
endfunction

function keyword#Keyword(is_visual, is_g) abort
    let l:pattern = star#GetPattern(a:is_visual, a:is_g)
    if s:MatchDelete(l:pattern)
        return
    endif
    call s:Match(l:pattern)
endfunction

function keyword#Command(is_visual, is_g) abort
    if g:star_keyword_keep_cursor_pos
        let l:setpos = ":call setpos('.', ". string(getcurpos()) .")\<CR>"
    else
        let l:setpos = ''
    endif

    let l:args = join([a:is_visual, a:is_g], ',')
    let l:matchcmd = ":\<C-u>call keyword#Keyword(". l:args . ")\<CR>"

    return l:matchcmd . l:setpos
endfunction

function s:WinNewMatch() abort
    for l:match in s:match_info
        if !empty(l:match.pattern)
            call matchadd(l:match.group, l:match.pattern, 10, l:match.id)
        endif
    endfor
endfunction

augroup StarKeyword
    autocmd!
    autocmd WinNew * call s:WinNewMatch()
augroup END
