DEFINE_BASECLASS("player_hvr_baseclass")

local PLAYER = {}
PLAYER.SecondaryName = "Hunger"
PLAYER.TertiaryName = "Energy"

player_manager.RegisterClass("player_hvr_human", PLAYER, "player_hvr_baseclass")
