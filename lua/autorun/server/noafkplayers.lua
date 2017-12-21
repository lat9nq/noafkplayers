--[[
 * noafkplayers.lua
 * Lua
 * Written by Toast Unlimited
 * 6 December 2017
 *
 * This is a small script that will monitor player keyboard activity,
 * warn when the player is at 75% of their way to being kicked,
 * and kick after a specified time of absence.
 *
 * This is based on my Expression 2 chip: NoAFKPlayers.txt.
 *
 * The default AFK time is 30 minutes, but it should work for any time given.
--]]

afk_time = {}
local ind = 0
local kick = 0
local prep = 0
local warn = 0
local delay = 0.500
local last_ran = 0

local function GetTag(ply)
	if (!(ply:IsValid() and not ply:IsBot())) then return "0" end
	local id = ply:SteamID()
	local ids = string.Explode(":", id)
	return ids[2] .. ids[3]
end

function PrintTag(ply)
	if (ply:IsValid()) then
		ply:PrintMessage(HUD_PRINTCONSOLE,GetTag(ply))
	end
end

local function FindPlayer(ply_name)
	local players = player.GetAll()
	local ply = nil
	for _,x in pairs(players) do
		if (string.find(string.lower(x:GetName()), string.lower(ply_name)) ~= nil) then
			ply = x
			break
		end
	end
	return ply
end

function SetAfkTime(me, command, arguments)
	if (me:IsValid()) then
		if (!me:IsAdmin()) then 
			me:PrintMessage(HUD_PRINTCONSOLE, "You do not have access to this command, " .. me:GetName() .. ".")
			return
		end
	end
	
	local ply_name = arguments[1]
	local res = arguments[2]
	local ply = FindPlayer(ply_name)
	if (ply ~= nil) then
		local tag = tonumber(GetTag(ply))
		afk_time[tag] = SysTime() - tonumber(res)
		if (ply:IsValid()) then
			ply:PrintMessage(HUD_PRINTCONSOLE, "You set the AFK time for " .. ply:GetName() .. " to " .. tostring(res) .. " seconds.")
		else
			print("You set the AFK time for " .. ply:GetName() .. " to " .. tostring(res) .. " seconds.")
		end
	end
end

local function AFKStatus(caller)
	caller:PrintMessage(HUD_PRINTCONSOLE, "NoAfkPlayers last ran " .. tostring(SysTime() - last_ran) .. " seconds ago...")
	for id,x in pairs(afk_time) do
		caller:PrintMessage(HUD_PRINTCONSOLE, tostring(id) .. ": " .. tostring(math.floor(SysTime() - x)))
	end
end

local function Clk()
	ind = (ind % player.GetCount()) + 1
	local players = player.GetAll()
	local ply = players[ind]
	local tag = tonumber(GetTag(ply))
	local t = afk_time[tag]
	--[[if (ind == 1) then
		PrintMessage(HUD_PRINTCONSOLE, "noafkplayers: reiterating on " .. tostring(ply:GetName()) .. " who moved at " .. tostring(t))
	end--]]
	if (t == nil) then return end --not completely joined in
	if (t + warn > SysTime() - delay and t + warn < SysTime() + delay) then
		ply:ChatPrint("You will be kicked in " .. tostring(math.floor((kick-warn)/60)) .. " minutes if you do not do anything.")
	--elseif (t + prep > SysTime() - delay and t + prep < SysTime() + delay) then
	elseif (t + kick < SysTime() + delay) then
		ply:Kick("Detected AFK after " .. tostring(math.floor(kick/60)).. " minutes")
	end
	last_run = SysTime()
end

local function First() 
	print("noafkplayers: starting...")
	kick = 30 --EDIT THIS LINE TO CHANGE THE AFK TIME
	kick = kick*60
	prep = kick - 60
	warn = kick*0.75

	for _, p in pairs(player.GetAll()) do
		afk_time[tonumber(GetTag(p))] = SysTime()
	end

	hook.Add( "KeyPress", "keypress_last_atk", function(ply, key)
		afk_time[tonumber(GetTag(ply))] = SysTime()
	end )

	timer.Create("interval", delay*2/player.GetCount(), 0, Clk)
	if (player.GetCount() > 0) then
		print("noafkplayers: created timer on Clk for every " .. tostring(delay*2/player.GetCount()) .. " seconds")
	end
end

local function updateTimer(count)
	timer.Remove("interval")
	if (count > 0) then
		timer.Create("interval", delay*2/count, 0, Clk)
	end
	--PrintMessage(HUD_PRINTCONSOLE, "noafkplayers: updated timer on Clk for every " .. tostring(0.500/player.count()) .. " seconds")
end

hook.Add("PlayerInitialSpawn", "AFK_Add_on_connect", function(ply)
	afk_time[tonumber(GetTag(ply))] = SysTime()

	updateTimer(player.GetCount())
end)

hook.Add("PlayerDisconnected", "AFK_rem_on_leave", function(ply)
	table.remove(afk_time,tonumber(GetTag(ply)))

	updateTimer(player.GetCount() - 1)
end)

First()
concommand.Add("gettag", PrintTag)
concommand.Add("setafktime", SetAfkTime)
concommand.Add("afkstatus", AFKStatus)
