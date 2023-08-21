@echo OFF

REM // build the ROM
call build

REM  // run fc against Sonic 2 Nick Arcade
echo -------------------------------------------------------------
if exist s2built.bin ( fc /b s2built.bin s2.na.bin
) else echo s2built.bin does not exist, probably due to an assembly error

REM // if someone ran this from Windows Explorer, prevent the window from disappearing immediately
pause
