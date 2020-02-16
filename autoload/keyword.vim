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
        let l:group = 'KeywordHighlight'. l:index
        execute 'highlight default '. l:group .' ctermfg=0 ctermbg='. l:color
        let l:match = {'index':l:index, 'group': l:group, 'pattern': '', 'id': l:id}
        call add(s:match_info, l:match)
        let l:index += 1
    endfor
endfunction

let s:match_info = []
let s:match_stack = []
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
        if l:match.pattern ==# a:pattern
            return l:match
        endif
    endfor
    return {}
endfunction

function s:Match(is_add, match) abort
    if s:WinMatchInit()
        return
    endif
    if a:is_add
        call matchadd(a:match.group, a:match.pattern, 10, a:match.id)
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

function s:MatchAdd(pattern) abort
    let l:match = s:SearchMatchInfo('')
    if empty(l:match)
        echomsg 'No more keyword highlight groups'
        return
    endif
    let l:match.pattern = a:pattern
    call s:WindoMatch(1, l:match)
endfunction

function s:MatchDelete(pattern) abort
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
    if s:MatchDelete(l:pattern)
        return
    endif
    call s:MatchAdd(l:pattern)
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

function s:WinMatchInit() abort
    if exists('w:keyword_init')
        return v:false
    endif
    let w:keyword_init = 1
    for l:index in s:match_stack
        let l:match = s:match_info[l:index]
        call matchadd(l:match.group, l:match.pattern, 10, l:match.id)
    endfor
    return v:true
endfunction

augroup VimKeyword
    autocmd!
    autocmd WinNew * call s:WinMatchInit()
    autocmd WinEnter * call s:WinMatchInit()
augroup END
