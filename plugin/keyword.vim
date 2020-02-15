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
let g:keyword_keep_cursor_pos = get(g:, 'keyword_keep_cursor_pos', 1)
let g:keyword_magic_match_id = get(g:, 'keyword_magic_match_id', 13524)

vnoremap <expr><silent> <Plug>(keyword-*) keyword#Command(1, 0)
nnoremap <expr><silent> <Plug>(keyword-*) keyword#Command(0, 0)
nnoremap <expr><silent> <Plug>(keyword-g*) keyword#Command(0, 1)
nnoremap <silent> <Plug>(keyword-clear) :<C-u>call keyword#ClearMatches()<CR>
