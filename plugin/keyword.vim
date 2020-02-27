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

let g:keyword_ctermbg = get(g:, 'keyword_ctrembg', ['002', '004', '005', '006', '013', '009'])
let g:keyword_guibg = get(g:, 'keyword_guibg',
            \             ['LightGreen', 'DarkYellow', 'Violet', 'Cyan', 'Purple', 'Orange'])

let g:keyword_keep_cursor_pos = get(g:, 'keyword_keep_cursor_pos', 1)
let g:keyword_magic_match_id = get(g:, 'keyword_magic_match_id', 13520)

function s:Navigate(is_forward) abort
    if exists('g:keyword_init') && keyword#NavigatePrepare(a:is_forward)
        return "\<Plug>(keyword-navigate)"
    endif
    if a:is_forward
        return "\<Plug>(keyword-forward-fallback)"
    else
        return "\<Plug>(keyword-backward-fallback)"
    endif
endfunction

xnoremap <expr><silent> <Plug>(keyword-highlight) keyword#Command(1)
nnoremap <expr><silent> <Plug>(keyword-highlight) keyword#Command(0)

nnoremap <expr><silent> <Plug>(keyword-clear)
            \ exists('g:keyword_init') ? ":\<C-u>call keyword#Clear()\<CR>" : ''

nmap <expr> <Plug>(keyword-forward) <SID>Navigate(1)
nmap <expr> <Plug>(keyword-backward) <SID>Navigate(0)

if empty(maparg('<Plug>(keyword-forward-fallback)', 'n'))
    nnoremap <Plug>(keyword-forward-fallback) n
endif
if empty(maparg('<Plug>(keyword-backward-fallback)', 'n'))
    nnoremap <Plug>(keyword-backward-fallback) N
endif
