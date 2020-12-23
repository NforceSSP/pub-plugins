-- luacheck: globals FACTION_VORTIGAUNT

FACTION.name = "Vortigaunt"
FACTION.description = "A vortigaunt."
FACTION.color = Color(0, 128, 61, 255)
FACTION.whitelist = true
FACTION.vortigauntVoices = true
FACTION.useFullName = true
FACTION.material = "halfliferp/factions/vortigaunt"

FACTION.models = {
	"models/vortigaunt.mdl"
}

FACTION.npcRelations = {
	["npc_turret_floor_rebel"] = D_NU,
	["npc_antlion"] = D_HT,
	["npc_antlionguard"] = D_HT,
	["npc_citizen"] = D_LI,
	["npc_fastzombie"] = D_HT,
	["npc_fastzombie_torso"] = D_HT,
	["npc_headcrab"] = D_HT,
	["npc_headcrab_black"] = D_HT,
	["npc_headcrab_fast"] = D_HT,
	["npc_poisonzombie"] = D_HT,
	["npc_strider"] = D_HT,
	["npc_vortigaunt"] = D_LI,
	["npc_zombie"] = D_HT,
	["npc_zombie_torso"] = D_HT
}

FACTION.weapons = {"ix_vortbeam"}

FACTION.bNotAddictive = true

FACTION_VORTIGAUNT = FACTION.index

function FACTION:OnSpawn(client)
	client:SetWalkSpeed(80)
	client:SetRunSpeed(180)
end

