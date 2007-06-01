DBGP Notepad++ plugin

ABSTRACT

This is a plugin for Notepad++ 4.1. It is a debugger client that talks DBGP 
protocol. It was built mostly for PHP (XDebug) but may/should/will work with 
other languages as well.

HISTORY

I was looking for a good PHP debugger for a long time. I tried most of what’s 
out there and finally found XDebug. Server side part was good and the only 
thing left was to find a decent client. Tuff luck! Most editors listed on the 
site were either too big or did not work as I expected (mostly editor wise) or 
I could not test them at all.
We are heavy users of Notepad++ (yes… like a drug). The editor behaves just as 
we want it and it is blazing fast. I started experimenting with the plugin 
interface and ended up writing this plugin in Delphi.

FEATURES
 
+ a dockable main form with child dialogs that dock
/ configuration dialog
+ stack child
+ properties child
+ context child
+ eval child
- raw child (for debugging) 
- breakpoint child
- breakpoint indicator (SCI)
+ tracing command (step into, over, out, run)
+ tracing indicator (SCI)
- fast eval on mouse dwell
- STDOUT redirect (log child)
- STDERR redirect
? watch
+ NL convert
/ toolbar icons (step into, over,out, run, add (remove) breakpoint, child icons [eval,raw,stack,global ctn, local ctx .. maybe not all of them])
- DBGp proxy support
/ file mapping (server ip based)
/ dbgpp error processing...
- interface for context depth (maye on the stack child, and floating?)

( - todo, / started, + done, ? don't know if I'll do it )
