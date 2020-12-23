
local PLUGIN = PLUGIN

PLUGIN.name = "Vortigaunts"
PLUGIN.author = "Nforce"
PLUGIN.description = "Adds the Vortigaunt faction, along with their needed things."

ix.anim.vortigaunt.broom = table.Copy(ix.anim.vortigaunt.melee)
ix.anim.vortigaunt.broom = {
	[ACT_MP_STAND_IDLE] = {"sweep_idle"},
	[ACT_MP_WALK] = {"Walk_all_HoldBroom"}
}
ix.util.Include("cl_arclib.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")

if (SERVER) then
	function PLUGIN:PlayerIsVortigaunt(player)
		local faction = player:GetFaction()
		if (string.find(player:GetModel(), "vortigaunt") or faction == FACTION_VORTIGAUNT) then
			return true
		end
		return false
	end
end
