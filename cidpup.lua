
local PLUGIN = PLUGIN

PLUGIN.name = "CIDPUP"
PLUGIN.author = "Nforce"
PLUGIN.description = "Disallows pickup of extra CID's."

function PLUGIN:CanPlayerTakeItem(client, item)

	local char = client:GetCharacter()
	local inv = char:GetInventory()
	local ciditem = inv:HasItem("cid")

	if ciditem then
		hasID = true
	end

	if !ciditem then
		hasID = false
	end
	if hasID == true then
		if item:GetModel() == "models/gibs/metal_gib4.mdl" then -- cid index is 51
			return false
		end
	end
end
