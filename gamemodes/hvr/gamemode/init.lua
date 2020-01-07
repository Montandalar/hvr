HVR = {}
util.AddNetworkString("ply_stats")
util.AddNetworkString("ply_class")
util.AddNetworkString("rnd_status")
util.AddNetworkString("team_win")
util.AddNetworkString("end_game")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_sound.lua")
include("shared.lua")
include("player.lua")
include("concommands.lua")
include("player_classes/hvr_baseclass.lua")
include("player_classes/hvr_human.lua")
include("player_classes/hvr_robot.lua")

-- Config globals (config NYI)
robot_human_ratio = 0.5
min_players = 2
prep_time = 10
rndtime = 300

-- Globals that change
RoundState = ROUND_PRE
RoundTime = 0
RoundsLeft = 5
RoundsPlayed = 0
HumanWins = 0
RobotWins = 0

function HVR.BeginRoundPrep()
	RoundState = ROUND_PREP
	RoundTime = prep_time
	timer.Create("round_prep", 10, 1, HVR.BeginRound)
end

function HVR.BeginRound()
	RoundState = ROUND_CURRENT
	RoundTime = rndtime
	HVR.ChoosePlayerRoles()
	timer.Create("stats_attrition", 1, 0, HVR.StatsAttrition)

	for id, ply in pairs(player.GetAll()) do
		player_manager.RunClass(ply, "Loadout")
	end
end

function HVR.EndGame()
	net.Start("end_game")
	net.WriteUInt(HumanWins, 8)
	net.WriteUInt(RobotWins, 8)
	net.Broadcast()

	RoundTime = 20
	timer.Simple(20, game.LoadNextMap)
end

function HVR.CheckForConnectedPlayers(source)
	local source = source or nil
	local modifier = 0
	if (source == "PlayerConnect") then modifier = 1 end
	if (source == "PlayerDisconnected") then modifier = -1 end
	if ((#player.GetAll()+modifier) >= min_players) then
		if (RoundState == ROUND_PRE) then
			HVR.BeginRoundPrep()
		end
	else
		if (RoundState == ROUND_CURRENT) then
				HVR.TeamWin("Nobody")
			end
	end
end

function HVR.CheckForLiving()
	local humans = 0
	local robots = 0
	for id, ply in pairs(player.GetAll()) do
		if (ply:Alive()) then
			if (player_manager.GetPlayerClass(ply) == "player_hvr_human") then
				humans = humans + 1
			elseif (player_manager.GetPlayerClass(ply) == "player_hvr_robot") then
				robots = robots + 1
			end
		end
	end

	if (humans == 0) then
		HVR.TeamWin("Robots")
	elseif (robots == 0) then
		HVR.TeamWin("Humans")
	end

	return humans, robots
end

hook.Add("PostPlayerDeath", "PlayerDeath_CheckForLiving", HVR.CheckForLiving)

function HVR.TeamWin(team)
	RoundState = ROUND_POST
	RoundTime = 10
	if (team == "Robots") then RobotWins = RobotWins + 1 end
	if (team == "Humans") then HumanWins = HumanWins + 1 end
	RoundsPlayed = RoundsPlayed + 1
	net.Start("team_win")
	net.WriteString(team)
	net.Broadcast()
	HVR.PostRound()
end

function HVR.PreRound()
	RoundState = ROUND_PRE
	HVR.CheckForConnectedPlayers()

	for id, ply in pairs(player.GetAll()) do
		ply:Spawn()
	end
end

function HVR.PostRound()
	timer.Stop("stats_attrition")
	for id, ply in pairs(player.GetAll()) do
		ply.secondary = 100
		ply.tertiary = 100
		ply:UpdateStats()
		ply:StripAmmo()
		ply:StripWeapons()
	end

	RoundsLeft = RoundsLeft - 1

	if (RoundsLeft < 1) then
		HVR.EndGame()
		return
	end
	timer.Simple(10, HVR.PreRound)
end


function HVR.StatsAttrition()
	for id, ply in pairs(player.GetAll()) do
		ply.secondary = math.max(ply.secondary - 0.8, 0)
		ply.tertiary = math.max(ply.tertiary - 0.45, 0)
		ply:UpdateStats()
		if (ply.secondary == 0) then ply:TakeDamage(10) end
		if (ply.tertiary == 0) then ply:TakeDamage(5) end
	end
end

function HVR.RoundStatusUpdate()
		RoundTime = math.max(RoundTime - 1, 0)
		if (RoundTime == 0 and RoundState == ROUND_CURRENT) then
			local h
			local r
			h,r = HVR.CheckForLiving()
			if (h == r) then HVR.TeamWin("Nobody") end
		end
		net.Start("rnd_status")
		net.WriteUInt(RoundState, 2)
		net.WriteUInt(RoundTime, 14)
		net.WriteUInt(RoundsLeft, 8)
		net.Send(player.GetAll())
end

timer.Create("rnd_status_update", 1, 0, HVR.RoundStatusUpdate)

function HVR.ChoosePlayerRoles()
	local robot_quota = math.floor(#player.GetAll() * robot_human_ratio)
	local player_class
	local tblPlys = {}

	for id, ply in pairs(player.GetAll()) do table.insert(tblPlys, ply) end

	while (tblPlys) do
		index = math.random(1, #tblPlys)
		local ply = tblPlys[index]

		local num_humans, num_robots = 0, 0
		for id, ply in pairs(player.GetAll()) do
			if (player_manager.GetPlayerClass(ply) == "player_hvr_human") then
				num_humans = num_humans + 1
			elseif (player_manager.GetPlayerClass(ply) == "player_hvr_robot") then
				num_robots = num_robots + 1
			end
		end

		if (num_robots >= robot_quota) then
			player_class = 0
			player_manager.SetPlayerClass(ply, "player_hvr_human")
		else
			player_class = 1
			player_manager.SetPlayerClass(ply, "player_hvr_robot")
		end

		net.Start("ply_class")
		net.WriteInt(player_class, 2)
		net.Send(ply)

		table.remove(tblPlys, index)
		if (tblPlys[1] == nil) then tblPlys = nil end
	end
end
