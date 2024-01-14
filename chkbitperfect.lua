#!/usr/bin/env lua

local clownmd5 = require "build_tools.lua.clownmd5"

-- Prevent build.lua's calls to os.exit from terminating the program.
local os_exit = os.exit
os.exit = coroutine.yield

-- Build the ROM.
local co = coroutine.create(function() dofile("build.lua") end)
local _, _, abort = assert(coroutine.resume(co))

-- Restore os.exit back to normal.
os.exit = os_exit

if not abort then
	-- Hash the ROM.
	local hash = clownmd5.HashFile("s2built.bin")

	-- Verify the hash against build.
	print "-------------------------------------------------------------"

	if hash == "\xA4\x60\xBF\x63\x35\x79\xA8\x0E\xEB\xBC\x09\xD6\x80\x9E\x1B\x09" then
		print "ROM is bit-perfect with the Nick Arcade Prototype."
	else
		print "ROM is NOT bit-perfect with the Nick Arcade Prototype!"
	end
end
