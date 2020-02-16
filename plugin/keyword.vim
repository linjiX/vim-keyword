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

if exists('g:loaded_keyword')
    finish
endif
let g:loaded_keyword = 1

let g:keyword_colors = get(g:, 'keyword_colors', ['002', '004', '005', '006', '013', '009'])
let g:keyword_navigate_fallback = get(g:, 'keyword_navigate_fallback', 1)
let g:keyword_keep_cursor_pos = get(g:, 'keyword_keep_cursor_pos', 1)
let g:keyword_magic_match_id = get(g:, 'keyword_magic_match_id', 13520)

function s:Navigate(is_forward) abort
    if exists('g:keyword_init')
        let l:index = keyword#CursorPatternIndex()
        if l:index != -1
            let l:args = join([a:is_forward, l:index], ',')
            return ":\<C-u>call keyword#Navigate(". l:args .")\<CR>"
        endif
    endif
    if g:keyword_navigate_fallback
        let l:normalcmd = a:is_forward ? 'n' : 'N'
        return ":\<C-u>normal! ". v:count1 . l:normalcmd ."\<CR>"
    endif
endfunction

function s:Clear() abort
    if exists('g:keyword_init')
        return ":\<C-u>call keyword#Clear()\<CR>"
    endif
endfunction

xnoremap <expr><silent> <Plug>(keyword-highlight) keyword#Command(1)
nnoremap <expr><silent> <Plug>(keyword-highlight) keyword#Command(0)
nnoremap <expr><silent> <Plug>(keyword-forward) <SID>Navigate(1)
nnoremap <expr><silent> <Plug>(keyword-backward) <SID>Navigate(0)
nnoremap <expr><silent> <Plug>(keyword-clear) <SID>Clear()
