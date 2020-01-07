fs = 32
surface.CreateFont("StatFont", {font = "Coolvetica", size = 32})
surface.CreateFont("HVR_SmallFont", {font = "Sans Serif", size = 16})

local sw = ScrW();
local sh = ScrH();

function drawStatBox(rnd, x, y, w, h, sw, sh, col, statName, statVal)
	-- Because we needed less boilerplate in HUDPaintStats()
	draw.RoundedBox(rnd, (x-0.005)*sw, (y-0.005)*sh, (w+0.01)*sw,          (h+0.01)*sh, Color(0, 0, 0, 0.5*(col.a)))
	draw.RoundedBox(rnd, x*sw,          y*sh,        w*sw,                 h*sh,       Color(0, 0, 0, col.a))
	if (statVal > 0 ) then
	draw.RoundedBox(rnd, x*sw,          y*sh,       (w*sw)*(0.01*statVal), h*sh,       col)
	end
	draw.SimpleText(string.format("%s: %d", statName, statVal), "StatFont", (x+(w/2))*sw, (y+(h/2))*sh, Color(255,255,255,a), 1, 1)
end

function HVR.HUDPaintStats()
	-- Important local vars
	local boxWidth = 0.25
	local boxHeight = 0.04
	local boxYPos = 0.92
	local rnd = math.floor(0.005*sw)
	local ply = LocalPlayer()
	local alpha = 220

	-- Stat/temporary testing variables
	local hp = ply:Health()
	local alpha = 220

	-- Health
	drawStatBox(rnd, 0.0625, boxYPos, boxWidth, boxHeight, sw, sh, Color(150, 0, 0, alpha), "Health", hp)

	if (RoundState > ROUND_PREP) then
		-- Twop
		local secondaryName = ""
		local secondaryCol  = 0
		if (player_manager.GetPlayerClass(ply) == "player_hvr_robot") then
			secondaryName = "Energy"
			secondaryCol  = Color(15, 167, 147, alpha)
		else
			secondaryName = "Hunger"
			secondaryCol = Color(121, 34, 11, alpha)
		end
		drawStatBox(rnd, 0.375, boxYPos, boxWidth, boxHeight, sw, sh, secondaryCol, secondaryName, ownSecondary)

		-- Threep
		local tertiaryname = ""
		local tertiaryCol = 0
		if (player_manager.GetPlayerClass(ply) == "player_hvr_robot") then
			tertiaryName = "Oil"
			tertiaryCol = Color(162, 164, 12, alpha)
		else
			tertiaryName = "Energy"
			tertiaryCol = Color(53, 7, 137, alpha)
		end
		drawStatBox(rnd, 0.6875, boxYPos, boxWidth, boxHeight, sw, sh, tertiaryCol, tertiaryName, ownTertiary)
	end
end

function HVR.HUDPaintPlayerClass()
	if (ownClass == 1) then 
		draw.SimpleText("You are a robot", "HVR_SmallFont", 0.9*sw, 0.9*sh, Color(255,255,255,255), 1, 1)
	elseif (ownClass == 0) then
		draw.SimpleText("You are a human", "HVR_SmallFont", 0.9*sw, 0.9*sh, Color(255,255,255,255), 1, 1)
	end
end

function HVR.HUDPaintRoundState()
	-- RoundTime
	draw.SimpleText(string.format("%d:%.2d", math.floor(RoundTime/60), RoundTime%60), "StatFont", (0.5*sw), fs, Color(255,255,255,255), 1, 1)

	-- Round State
	if (RoundState == ROUND_PRE) then
		draw.SimpleText("The round will begin when there are more players", "HVR_SmallFont", 32, 32, Color(255,255,255,255), 0, 4)
	elseif (RoundState == ROUND_PREP) then
		draw.SimpleText("The round is beginning soon", "HVR_SmallFont", 32, 32, Color(255,255,255,255), 0, 4)
	elseif (RoundState == ROUND_CURRENT) then
		draw.SimpleText("The round has begun", "HVR_SmallFont", 32, 32, Color(255,255,255,255), 0, 4)
	elseif (RoundState == ROUND_POST) then
		draw.SimpleText("The round has finished and might begin again shortly", "HVR_SmallFont", 32, 32, Color(255,255,255,255), 0, 4)
	end
end

function HVR.HUDPaint()
	-- A check to see if the hud should be drawn
	local shouldDraw = GetConVar("cl_drawhud")
	if (shouldDraw:GetInt() == 0 or !(LocalPlayer():Alive())) then return end

	HVR.HUDPaintStats()
	HVR.HUDPaintPlayerClass()
	HVR.HUDPaintRoundState()
end

hook.Add("HUDPaint", "HVR_HUDPaint", HVR.HUDPaint)

function HUDBlockElements(name)
	-- The gamemode calls this function to determine whether it will draw parts of the default HL2 UI
	local blockedElements = {CHudAmmo = true, CHudBattery = true, CHudHealth = true, CHudSecondaryAmmo = true}
	if (blockedElements[name]) then
		return false
	end
end

hook.Add("HUDShouldDraw", "HUDBlockElements", HUDBlockElements)
