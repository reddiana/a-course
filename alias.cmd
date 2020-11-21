@echo off

:: commands
doskey alias   = doskey $*
doskey cat     = type $*
doskey clear   = cls
doskey grep    = find $*
doskey history = doskey /history
doskey man     = help $*
::
doskey kill    = taskkill /PID $*
doskey ls      = dir $*
doskey ll      = dir $*
::
doskey cp      = copy $*
doskey cpr     = xcopy $*
doskey mv      = move $*
doskey rm      = del $*
doskey rmr     = deltree $*
::
doskey ps      = tasklist $*
doskey pwd     = cd
::
doskey sudo    = runas /user:administrator $*
::
doskey m       = multipass $*
