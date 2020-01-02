Plugin that overrides CTRL-E and CTRL-Y in insert mode.
Vim default behaviour for those is to insert character which is below or above the cursor.

We want similar feature, but with:

1. operator-pending mode
2. with optional number prefix, that designate the nth line to the top/bottom instead.

Draft
=====

`:he operator` mentions **g@** calls function set with the `operatorfunc` option.

						*linewise* *characterwise*
The operator either affects whole lines, or the characters between the start and end position.  Generally, motions that move between lines affect lines (are linewise), and motions that move within a line affect characters (are characterwise).  However, there are some exceptions.

						*'operatorfunc'* *'opfunc'*
'operatorfunc' 'opfunc'	string	(default: empty) global
	This option specifies a function to be called by the |g@| operator.
	See |:map-operator| for more info and an example.

FORCING A MOTION TO BE LINEWISE, CHARACTERWISE OR BLOCKWISE
-----------------------------------------------------------

When a motion is not of the type you would like to use, you can force another type by using "v", "V" or CTRL-V just after the operator.
Example: 
	dj deletes two lines 
	dvj deletes from the cursor position until the character below the cursor >
	d<C-V>j deletes the character under the cursor and the character below the cursor. >

Be careful with forcing a linewise movement to be used characterwise or blockwise, the column may not always be defined.

MAPPING AN OPERATOR				*:map-operator*
--------------------------------------

An operator is used before a {motion} command.  To define your own operator
you must create mapping that first sets the 'operatorfunc' option and then
invoke the |g@| operator.  After the user types the {motion} command the
specified function will be called.

							*g@* *E774* *E775*
g@{motion}		Call the function set by the 'operatorfunc' option.
			The '[ mark is positioned at the start of the text
			moved over by {motion}, the '] mark on the last
			character of the text.
			The function is called with one String argument:
			    "line"	{motion} was |linewise|
			    "char"	{motion} was |characterwise|
			    "block"	{motion} was |blockwise-visual|
			Although "block" would rarely appear, since it can
			only result from Visual mode where "g@" is not useful.
			{not available when compiled without the |+eval|
			feature}

Here is an example that counts the number of spaces with <F4>: 

	nmap <silent> <F4> :set opfunc=CountSpaces<CR>g@ 
    vmap <silent> <F4> :<C-U>call CountSpaces(visualmode(), 1)<CR> 

    function! CountSpaces(type, ...) 
      let sel_save = &selection 
      let &selection = "inclusive" 
      let reg_save = @@

	  if a:0  " Invoked from Visual mode, use gv command.
	    silent exe "normal! gvy"
	  elseif a:type == 'line'
	    silent exe "normal! '[V']y"
	  else
	    silent exe "normal! `[v`]y"
	  endif

	  echomsg strlen(substitute(@@, '[^ ]', '', 'g'))

	  let &selection = sel_save
	  let @@ = reg_save
	endfunction

Note that the 'selection' option is temporarily set to "inclusive" to be able
to yank exactly the right text by using Visual mode from the '[ to the ']
mark.

Also note that there is a separate mapping for Visual mode.  It removes the
"'<,'>" range that ":" inserts in Visual mode and invokes the function with
visualmode() and an extra argument.

