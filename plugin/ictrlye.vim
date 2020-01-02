" vim-ictrlye.vim
" ---------------------------------------------
" author : GrepSuzette
" date   : 2017-10-19
" license: Public domain
" ---------------------------------------------
"
"  BUG when Space or C-e or C-y is continuously pressed.
"      As if a quote were inserted, would need to maybe ask
"      advice on #vim IRC to know if possible to prevent
"      vim bindings to trigger between the time of the 1st pending operation
"      and the 2nd.

let s:col = 0
let s:pos = []              " where we started, and where to insert
let s:poson2ndctrlye = []   " where cursor was on 2nd ctrly/e 

function! s:ICtrlYE(upOrDown)
    let s:pos = getcurpos()
    let s:col = col(".") == 1 ? col(".") : col(".") + 1
	let l:pat = '\%'.(s:col).'c\%'.(line(".")).'l'
    execute "2match Cursor /".l:pat."/"
    let [l:buf, l:line, l:col, l:off, l:curswant] = s:pos
    call cursor([l:line + (a:upOrDown == "up" ? -1 : 1), s:col])
    call ictrlye#printstatus() 
    set opfunc=ictrlye#opfunc
    call feedkeys("g@")
endfunction

function! ictrlye#printstatus()
    echohl None | echon "  Line"| echohl Title| echon " {motion}"| echohl None| echon " such as"
    echohl ModeMsg | echon " $, i', ib, f]" | echohl None | echon " to insert text. " | echohl Title | echon "Ctrl-Y" 
    echohl None | echon "/" | echohl Title | echon "k" | echohl None| echon " to move up. "
    echohl Title | echon "J/K" | echohl None | echon " to go BOL." 
endfunction

function! ictrlye#opfunc(type)
    let saved_unnamed_register = @@
    call ictrlye#savecursorpos()
    try
        if a:type ==# 'char'
            normal! `[v`]y
        elseif a:type ==# 'line'
            throw "multi-line not allowed. Aborted."
        else
            throw a:type 
        endif
        call setpos(".", s:pos)
        execute "normal! a".@@."\<Esc>"
        echon "   Inserted '" @@ "'."
    catch /^.*/
        echohl ErrorMsg
        echo v:exception
        echohl NONE
        call setpos(".", s:pos)
    finally
        :2match
        let @@ = saved_unnamed_register
    endtry
endfunction

function! s:OrigCol()
    return s:col
endfunction

function! s:OrigPos()
    return s:pos
endfunction

function! ictrlye#cancel()
    echo "  Cancelled."
    call setpos(".", s:pos)
    :2match 
endfunction

function! ictrlye#moveorigposright()
    return s:pos
endfunction

function! ictrlye#savecursorpos()
    " let [l:buf, l:line, l:col, l:off, l:curswant] = s:pos
    let s:poson2ndctrlye = getcurpos()
    let s:poson2ndctrlye[2] += 1
endfunction


function! ictrlye#after2ndctrlye()
    " char has been put with "l"
    " - update col of origpos, such as +1
    " - 2match origpos
    " - beware multibyte chars!
    let s:pos[2] += 1
    let s:col += 1
	let l:pat = '\%'.(s:col).'c\%'.(line(".")).'l'
    execute "2match Cursor /".l:pat."/"
    " - set cursor where it was, col+1
    " let [l:buf, l:line, l:col, l:off, l:curswant] = s:pos
    " echomsg len(s:poson2ndctrlye)
    if s:col <= len(getline(s:poson2ndctrlye[1]))
        call ictrlye#printstatus()
        call cursor(s:poson2ndctrlye[1], s:poson2ndctrlye[2])
        set opfunc=ictrlye#opfunc
        call feedkeys("g@")
        return v:true
    else
        " return and quit operator pending
        echo " End of line reached."
        :2match
        return v:false
    endif
endfunction

" onoremap: because we use g@ 
" <expr> will make operator that started the pending operator be in v:operator
" disable most
" j and k allow moving lines, same as subsequent C-y and C-e
" J and K allow moving lines but placing the cursor at BOL
" i,I,a,A are the classical inner and around selector (as in cib)
" Esc to cancel
" <space> to advance
" What is this <script> for?
" Before November 08, 2017 11:25 
" inoremap <script> <silent> <C-e> <Esc>:call <SID>ICtrlYE("down")<Cr>
" inoremap <script> <silent> <C-y> <Esc>:call <SID>ICtrlYE("up")<Cr>
"testing:
inoremap <silent> <C-e> <Esc>:call <SID>ICtrlYE("down")<Cr>
inoremap <silent> <C-y> <Esc>:call <SID>ICtrlYE("up")<Cr>
" onoremap <script> <silent> <expr> <C-e> v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call cursor(line('.')+".v:count1.", <SID>OrigCol())<Cr>:set opfunc=ictrlye#opfunc<Cr>g@" : "<C-e>"
" onoremap <script> <silent> <expr> <C-y> v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call cursor(line('.')-".v:count1.", <SID>OrigCol())<Cr>:set opfunc=ictrlye#opfunc<Cr>g@" : "<C-y>"
onoremap <script> <silent> <expr> j     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call cursor(line('.')+".v:count1.", <SID>OrigCol())<Cr>:set opfunc=ictrlye#opfunc<Cr>g@" : "j"
onoremap <script> <silent> <expr> k     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call cursor(line('.')-".v:count1.", <SID>OrigCol())<Cr>:set opfunc=ictrlye#opfunc<Cr>g@" : "k"
onoremap <script> <silent> <expr> J     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call cursor(line('.')+".v:count1.", 1)<Cr>:set opfunc=ictrlye#opfunc<Cr>g@" : ( v:operator == "g@" && &opfunc == "Join" ? "j" : "J" )
onoremap <script> <silent> <expr> K     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call cursor(line('.')-".v:count1.", 1)<Cr>:set opfunc=ictrlye#opfunc<Cr>g@" : "K"
onoremap <script> <silent> <expr> <Esc> v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "<Esc>"
onoremap <script> <silent> <expr> v     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "v"
onoremap <script> <silent> <expr> V     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "V"
onoremap <script> <silent> <expr> %     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "%"
onoremap <script> <silent> <expr> &     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "&"
onoremap <script> <silent> <expr> @     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "@"
onoremap <script> <silent> <expr> !     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "!"
onoremap <script> <silent> <expr> ~     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "~"
onoremap <script> <silent> <expr> [     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "["
onoremap <script> <silent> <expr> ]     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "]"
onoremap <script> <silent> <expr> =     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "="
onoremap <script> <silent> <expr> +     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "+"
onoremap <script> <silent> <expr> _     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "_"
onoremap <script> <silent> <expr> "     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : '"'
onoremap <script> <silent> <expr> :     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : ':'
onoremap <script> <silent> <expr> >     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : '>'
onoremap <script> <silent> <expr> <     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : '<'
onoremap <script> <silent> <expr> .     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : '.'
onoremap <script> <silent> <expr> c     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'c'
onoremap <script> <silent> <expr> C     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'C'
onoremap <script> <silent> <expr> d     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'd'
onoremap <script> <silent> <expr> D     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'D'
onoremap <script> <silent> <expr> m     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'm'
onoremap <script> <silent> <expr> M     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'M'
onoremap <script> <silent> <expr> o     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'o'
onoremap <script> <silent> <expr> O     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'O'
onoremap <script> <silent> <expr> p     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'p'
onoremap <script> <silent> <expr> P     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'P'
onoremap <script> <silent> <expr> q     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'q'
onoremap <script> <silent> <expr> Q     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'Q'
onoremap <script> <silent> <expr> r     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'r'
onoremap <script> <silent> <expr> R     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'R'
onoremap <script> <silent> <expr> u     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'u'
onoremap <script> <silent> <expr> U     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'U'
onoremap <script> <silent> <expr> x     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'x'
onoremap <script> <silent> <expr> X     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'X'
onoremap <script> <silent> <expr> y     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'y'
onoremap <script> <silent> <expr> Y     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'Y'
onoremap <script> <silent> <expr> z     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'z'
onoremap <script> <silent> <expr> Z     v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : 'Z'
onoremap <script> <silent> <expr> <Bar> v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>" : "<Bar>"

onoremap <script> <silent> <expr> <C-e> v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "l<Esc>:call ictrlye#after2ndctrlye()<Cr>" : ""
onoremap <script> <silent> <expr> <C-y> v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "l<Esc>:call ictrlye#after2ndctrlye()<Cr>" : ""
" <Space> to copy one character at a time
" <BS> cound delete last character and end pending 
" <CR> till end of line
onoremap <script> <silent> <expr> <Space> v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "l<Esc>:call ictrlye#after2ndctrlye()<Cr>" : "<Space>"
onoremap <script> <silent> <expr> <BS>    v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "<Esc>:call ictrlye#cancel()<Cr>x" : "<BS>"
onoremap <script> <silent> <expr> <Cr>    v:operator == "g@" && &opfunc == "ictrlye#opfunc" ? "$" : "<Cr>"

let s:a = [ 430 + ( 13 + 5 ), 59 ] 
let s:c = 34941151
let s:b = 3.1411519532511523 
let s:d = 32942397239 
let s:e = "this area is just for testing"
let s:f = 3.141519532511523 

