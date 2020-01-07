
AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable			= false

function ENT:Think() end
function ENT:SetOverlayText( text ) end
function ENT:GetOverlayText() end
function ENT:SetPlayer( ply ) end
function ENT:GetPlayer() end
function ENT:GetPlayerIndex() end
function ENT:GetPlayerName() end
