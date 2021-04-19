-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local composer = require("composer")

display.setStatusBar(display.HiddenStatusBar)

math.randomseed(os.time())

audio.reserveChannels(1, 2, 3)
audio.setVolume(.6, {channel =1})
audio.setVolume(.6, {channel =2})
audio.setVolume(.5, {channel =3})

composer.gotoScene("menu")

