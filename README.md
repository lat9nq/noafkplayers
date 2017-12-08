# noafkplayers
This is the repo where I will be keeping NoAFKPlayers, the Lua Script for Garry's Mod.

This is a small server-side script that auto-notifies players when they have been hanging idle for a set amount of time, and kicks them after a slightly longer amount of time.

Specifically, it warns players after 75% * 30 minutes (22.5 mintues), and kicks after 30 minutes. It watches Player:KeyPressed() to track idleness. This value can be changed, and there is a comment that points to the line in the Lua script.

This is based on my Expression 2 chip called "NoAFKPlayers", and the script was originally intended for use on Jinxy's Fun House Server here.

The Steam Workshop addon can be found [here](http://steamcommunity.com/sharedfiles/filedetails/?id=1224347209).
