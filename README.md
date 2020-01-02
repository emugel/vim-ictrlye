# Operator-pending CTRL-E and CTRL-Y in insert mode

Public domain 

Beta-version, usable but still not very perfect 
(you have to wait a second or so before entering the {motion})

This plugins replaces good old insert mode CTRL-E and CTRL-Y 
with more powerful operator-pending, enable {motion}. 

Classic behaviour for those is that while in insert mode, *i_CTRL-E* inserts
the character which is below the cursor, while *i_CTRL-Y* inserts the character
which is above the cursor. For instance:

    > wigums slaps around with a large trout.
    > wigums|

It takes 12 keypress on CTRL-Y in the above example to copy 2 words:

    > wigums slaps around

With this plugin, you CTRL-Y 2w would have the same effect. 
Any {motion} that would make sense in the context of a line can be used ($, ib, 4E etc).
It's also possible to use j an k while in pending operator mode to move up or
down and then use a {motion}.

## EXAMPLES   

    Some simple examples. 
    1st line represents the above line, 2nd line is the current line, with the
pipe representing the cursor. 3rd line is the input, 4th line is the result.

    > wigums slaps around with a large trout.   > Been working all day (tired)
    > wigums|                                   > Sparing no efforts |
    CTRL-Y $                                    CTRL-Y ab (around brackets)
    > wigums slaps around with a large trout.   > Sparing no efforts (tired)

    > People can fly, anything can happen
    > |
    CTRL-Y t,  (till comma)
    > People can fly
    
