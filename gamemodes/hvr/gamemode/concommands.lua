function HVR.PrintGameStatus()
	local rstate = ""
	if (RoundState == ROUND_PRE) then rstate = "Pre-round" end
	if (RoundState == ROUND_PREP) then rstate = "Preparation" end
	if (RoundState == ROUND_CURRENT) then rstate = "In progress" end
	if (RoundState == ROUND_POST) then rstate = "Post-round" end
	print(string.format("Round state: %s Time left: %d:%.2d", rstate, math.floor(RoundTime/60), RoundTime%60))
	-- The sum of RoundsLeft and RoundsPlayed is the total number of rounds
	print(string.format("Currently on round: %d/%d", RoundsPlayed+1, RoundsLeft+RoundsPlayed))
	print(string.format("Team wins (H|R): %d|%d (ratio: %.2f)", HumanWins, RobotWins, HumanWins/RobotWins))

	for id, ply in pairs(player.GetAll()) do
		local living
		if (ply:Alive()) then living = "Alive" else living = "Dead" end
		print(ply, player_manager.GetPlayerClass(ply), living)
	end
end

concommand.Add("hvr_status", HVR.PrintGameStatus, nil, "Prints the important variables that control the round state as well as a list of connected players and their player classes", 0)

function HVR.ForceEndRound(ply, cmd, tArgs, sArgs)
	if (RoundState == ROUND_CURRENT) then HVR.TeamWin(tArgs[1]) end
end

concommand.Add("hvr_endround", HVR.ForceEndRound, nil, "Forcibly ends the round by making its argument win", 0)
