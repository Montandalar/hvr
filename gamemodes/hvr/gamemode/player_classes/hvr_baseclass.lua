AddCSLuaFile()
-- Necessary for inheritance
DEFINE_BASECLASS("player_default")

local PLAYER = {}

PLAYER.DisplayName = "HvR Base Class"


function PLAYER:Loadout()
	if (RoundState == ROUND_CURRENT) then
		self.Player:Give("weapon_rpg")
		self.Player:Give("weapon_fists")
		self.Player:Give("weapon_medkit")
		self.Player:GiveAmmo(10, "rpg", true)
	end
end

function PLAYER:SetModel()
	if (tobool(math.random(0,1))) then
		-- Male
		self.Player:SetModel("models/player/group01/male_0" .. math.random(1,9) .. ".mdl")
	else
		-- Female
		self.Player:SetModel("models/player/group01/female_0" .. math.random(1,6) .. ".mdl")
	end
end

function PLAYER:GetHandsModel()
	return player_manager.TranslatePlayerHands(player_manager.TranslateToPlayerModelName(self.Player:GetModel()))
end

player_manager.RegisterClass("player_hvr_baseclass", PLAYER, "player_default")
