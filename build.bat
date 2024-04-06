@echo off

IF EXIST s2built.bin move /Y s2built.bin s2built.prev.bin >NUL

build_tools\asw -xx -q -A -L -U -E -i . s2.asm
build_tools\p2bin -p=0 -z=0,kosinski,Size_of_DAC_driver_guess,after s2.p s2built.bin

del s2.p