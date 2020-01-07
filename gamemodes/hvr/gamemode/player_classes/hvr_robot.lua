DEFINE_BASECLASS("player_hvr_baseclass")

local PLAYER = {}
PLAYER.SecondaryName = "Energy"
PLAYER.TertiaryName = "Oil"

player_manager.RegisterClass("player_hvr_robot", PLAYER, "player_hvr_baseclass")
