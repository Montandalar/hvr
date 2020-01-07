HVR.Sound = {}

function HVR.Sound.HumanSecondaryDamageNoise()
	surface.PlaySound(tStatSounds["Hunger"][math.random(1,2)])
end

function HVR.Sound.HumanTertiaryDamageNoise()
	surface.PlaySound(tStatSounds["humanEnergy"][math.random(1,4)])
end

function HVR.Sound.RobotSecondaryDamageNoise()
	surface.PlaySound(tStatSounds["robotEnergy"])
end

function HVR.Sound.RobotTertiaryDamageNoise()
	surface.PlaySound(tStatSounds["Oil"])
end

function HVR.PlayStatSound(stat)
	print("PlayStatSound called. ownClass = " .. ownClass)
	--Human
	if (ownClass == 0) then
		if (stat == 2) then
			HVR.Sound.HumanSecondaryDamageNoise()
		elseif (stat == 3) then
			HVR.Sound.HumanTertiaryDamageNoise()
		end
	--Robot
	elseif (ownClass == 1) then
		if (stat == 2) then
			HVR.Sound.RobotSecondaryDamageNoise()
		elseif (stat == 3) then
			HVR.Sound.RobotTertiaryDamageNoise()
		end
	end
end