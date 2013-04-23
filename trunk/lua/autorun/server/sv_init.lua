AddCSLuaFile("autorun/client/cl_init.lua")
include("autorun/server/sv_cmd.lua")
include("autorun/server/sv_config.lua")
include("autorun/server/sv_meta.lua")

local Rev = "rev12";
local Host = "127.0.0.1" // Host(IP/Hostname)
local User = "root" // Username
local Pass = "" // Password
local DB = "mybb" // Databse to select
local Port = 3306 // Port, By default it's 3306.
database = {}
ForumUsers = {}

function ConnectToSQL()
	require("mysqloo")
	
	database = mysqloo.connect(Host, User, Pass, DB, Port)
	
	database.onConnected = function()
		database.connected = true
		print("Successfully to connected to database.")
	end
	
	database.onConnectionFailed = function()
		database.connected = false
		print("Failed to connect to the database.")
	end
	
	database:connect()
	
	timer.Simple(3, function()
		if !database.connected then return MsgC(Color(255, 0, 0), "Warning the gForum isn't connected to the database.\nYou will be unable to use gForum until your connect to the database.\n") end
		local query1 = database:query( "CREATE TABLE IF NOT EXISTS " .. Prefix .. "_link (`id` INTEGER NOT NULL, `steamid` TEXT NOT NULL)")
		query1:start()
		
		local query2 = database:query( "CREATE TABLE IF NOT EXISTS " .. Prefix .. "_rank (`id` INTEGER NOT NULL, `rank` TEXT NOT NULL, `steamid` TEXT NOT NULL)")
		query2:start()
	end)
end

function CheckVersion()
	local function Success( str, len, head, http )
		str = tostring(str)
		if Rev != str then
			MsgC(Color(255, 0, 0), "gForum(" .. str .. ") is out of date.\nUpdate via svn from https://garryforum.googlecode.com/svn/trunk/\n")
		else
			MsgC(Color(0, 255, 0), "gForum(" .. str .. ") is currently up to date.\n")
		end
	end
	http.Fetch("https://dl.dropbox.com/u/10790421/index.txt", Success, nil)
end

function escape( txt )
	if type( txt ) != "string" then
		txt = tostring(txt)
	end
	return database:escape( txt )
end

hook.Add("PlayerInitialSpawn", "PlayerInitialSpawn.GetUserID", function( p )
	p:ChatPrint("This server is running gForum allowing ingame registration. Type !gforum for help..")
	umsg.Start("cl_forum", p)
		umsg.String(Forum)
	umsg.End()
	p.Register = false
	p.Halt = false
	if Register then
		GetUserID(p)
	else
		umsg.Start("cl_setinfo", p)
			umsg.String("N A")
			umsg.String("N A")
			umsg.String(URL)
		umsg.End()
		p:ChatPrint("You can register or link a forum account at anytime by using !register or !link.")
	end
end)

hook.Add("InitPostEntity", "InitPostEntity.Tags", function( p )
	ConnectToSQL()
	CheckVersion()
end)

hook.Add("PlayerSay", "PlayerSay.ChatCommands", function( p, txt, tm )
	txt = txt:lower()
	if string.find(txt, "!register") or string.find(txt, "!link") then
		GetUserID(p)
		return ""
	end
	if string.find(txt, "!reset") then
		ResetUser(p)
		return ""
	end
	if string.find(txt, "!gforum") then
		p:ChatPrint("You can register or link a forum account at anytime by using !register or !link.")
		p:ChatPrint("You can reset your account link via the !reset chat command.")
		return ""
	end
end)
