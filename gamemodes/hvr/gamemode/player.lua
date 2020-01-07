local PlyMeta = FindMetaTable("Player")

function GM:PlayerConnect(name, address)
	HVR.CheckForConnectedPlayers("PlayerConnect")
end

function GM:PlayerDisconnected(ply)
	HVR.CheckForConnectedPlayers("PlayerDisconnected")
end

function PlyMeta:UpdateStats()
	net.Start("ply_stats")
	net.WriteDouble(self.secondary)
	net.WriteDouble(self.tertiary)
	net.Send(self)
end

function GM:PlayerSpawn(pl)
	pl.secondary = 100
	pl.tertiary  = 100

	if (RoundState ~= ROUND_CURRENT) then
		player_manager.SetPlayerClass(pl, "player_hvr_baseclass")
	end

	--[[--
	Previously this was used to call the Base Gamemode's PlayerSpawn(), but now the code has been merged
	so this function is just an override
	BEGIN self.BaseClass.PlayerSpawn(self, pl)
	--]]--
	pl:UnSpectate()
	player_manager.OnPlayerSpawn( pl )
	player_manager.RunClass( pl, "Spawn" )
	hook.Call( "PlayerLoadout", GAMEMODE, pl )
	hook.Call( "PlayerSetModel", GAMEMODE, pl )
	pl:SetupHands()
	-- END self.BaseClass.PlayerSpawn(self, pl)
end

function GM:PlayerDeathThink(pl)
	-- This will allow respawns by the standard rules before the round starts
	if (Roundstate == 0) then
		self.BaseClass.PlayerDeathThink(pl)
	end
end
