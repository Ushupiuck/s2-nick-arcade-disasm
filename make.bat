@echo off
IF EXIST s2built.bin move /Y s2built.bin s2built.prev.bin >NUL
tool\asw -xx -q -A -L -U -E -i . main.asm
tool\p2bin -p=0 -z=0,kosinski,Size_of_DAC_driver_guess,after main.p s2built.bin
del main.p