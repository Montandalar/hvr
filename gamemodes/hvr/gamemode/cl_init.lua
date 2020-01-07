HVR = {}
include("player_classes/hvr_baseclass.lua")
include("cl_hud.lua")
include("shared.lua")
include("cl_sound.lua")

tStatSounds = {
	["Hunger"] = {
		"npc/barnacle/barnacle_digesting1.wav",
		"npc/barnacle/barnacle_digesting2.wav"
	},
	["humanEnergy"] = {
		"ambient/voices/cough1.wav",
		"ambient/voices/cough2.wav",
		"ambient/voices/cough3.wav",
		"ambient/voices/cough4.wav"
	},
	["robotEnergy"] = "ambient/energy/electric_loop.wav",
	["Oil"] = "doors/gate_move1.wav"
}

ownSecondary = 0
ownTertiary = 0
ownClass = -1

RoundState = 0
RoundTime = 0
RoundsLeft = 0

function HVR.StatDamageNoise()
	if (ownSecondary == 0) then
		print("Will call PlaySoundStat(2)")
		HVR.PlayStatSound(2)
	end
	if (ownTertiary == 0) then
		print("Will call PlaySoundStat(3)")
		HVR.PlayStatSound(3)
	end
end

net.Receive("ply_stats",
function(length, ply)
	ownSecondary = net.ReadDouble()
	ownTertiary = net.ReadDouble()
	if ((ownSecondary == 0) or (ownTertiary == 0)) then
		print("Will call StatDamageNoise()")
		HVR.StatDamageNoise()
	else
		timer.Stop("statdamage_noise")
	end
end
)

net.Receive("ply_class", 
function(ln, ply)
	ownClass = net.ReadInt(2)
end
)

net.Receive("rnd_status",
function(ln, ply)
	RoundState = net.ReadUInt(2)
	RoundTime = net.ReadUInt(14)
	RoundsLeft = net.WriteUInt(8)
end
)

net.Receive("team_win",
function(ln, ply)
	wonTeam = net.ReadString()
	hook.Add("HUDPaint", "HUDPaint_TeamWin",
	function()
		if (wonTeam == "Humans" or wonTeam == "Robots") then
			draw.SimpleText("The " .. wonTeam .. " have won the round!", "StatFont", ScrW()/2, ScrH()/2, Color(255,255,255,255), 1, 1)
		else
			draw.SimpleText(wonTeam .. " has won the round ", "StatFont", ScrW()/2, ScrH()/2, Color(255,255,255,255), 1, 1)
		end
	end
	)
	ownClass = -1
	timer.Simple(5, function() hook.Remove("HUDPaint", "HUDPaint_TeamWin") end)
end
)

net.Receive("end_game",
function(ln, ply)
	local HumanWins = net.ReadUInt(8)
	local RobotWins = net.ReadUInt(8)
	local WonTeam = ""
	local HumanPlural = ""
	local RobotPlural = ""

	if (HumanWins > RobotWins) then
		WonTeam = "the Humans"
	elseif (RobotWins > HumanWins) then
		WonTeam = "the Robots"
	else
		WonTeam = "Nobody"
	end
	
	if (HumanWins > 1) then HumanPlural = "s" end
	if (RobotWins > 1) then RobotPlural = "s" end

	local EndFrame
	EndFrame = vgui.Create("DFrame")
	EndFrame:SetSize(ScrW() * 0.7 , ScrH() * 0.7)
	EndFrame:Center()
	EndFrame:SetDraggable(false)
	EndFrame:SetSizable(false)
	EndFrame:SetTitle("HVR: End of Map")

	EndText = vgui.Create("RichText", EndFrame)
	EndText:Dock(FILL)
	EndText:SetText(string.format("In this match of Humans versus Robots, the Humans won %d round%s, while the Robots won %d round%s. Overall, %s won the game.",
	HumanWins, HumanPlural, RobotWins, RobotPlural, WonTeam))

	EndFrame:MakePopup()
end
)
