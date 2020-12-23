local PLUGIN = PLUGIN

function PLUGIN:Think()
	for _, v in pairs(player.GetAll()) do
		if (v:Team() == FACTION_VORTIGAUNT and v:GetNetVar("vortFlashlight")) then
			local claw = v:LookupAttachment("rightclaw")

			if (v:GetAttachment(claw)) then
				local dlight = DynamicLight(v:EntIndex())

				if (dlight) then
					dlight.pos = v:GetAttachment(claw).Pos
					dlight.r = 30
					dlight.g = 255
					dlight.b = 20
					dlight.brightness = 1.5
					dlight.Decay = 1500
					dlight.Size = 700
					dlight.DieTime = CurTime() + 1
				end
			end
		end
	end
end

do
	local green = Color(20, 250, 0, 190)
	local cachedCrosshair = PLUGIN:PrecacheArc(ScrW() / 2, ScrH() / 2, 10, 2, 0, 360, 3)

	function PLUGIN:HUDPaint()
		if (IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon())) then
			local weapon = LocalPlayer():GetActiveWeapon()

			if (weapon:GetClass() == "ix_vortbeam") then
				surface.SetDrawColor(255, 255, 255, 60)
				self:DrawPrecached(cachedCrosshair)

				if (weapon.chargeStart) then
					local elapsed = SysTime() - weapon.chargeStart
					local ang = math.Clamp((elapsed / (weapon.chargeTime or 0.7)) * 360, 0, 359.5)

					if (weapon.isPunching) then
						self:DrawArc(ScrW() / 2, ScrH() / 2, 10, 2, 90, -270 + ang, 3, green)
					else
						self:DrawArc(ScrW() / 2, ScrH() / 2, 10, 2, 90, 90 - ang, 3, green)
					end
				end
			end
		end
	end
end

function PLUGIN:PlayerBindPress(client, bind, bPressed)
	if (client:Team() == FACTION_VORTIGAUNT and bind:lower():find("impulse 100") and bPressed) then
		net.Start("VortLight")
		net.SendToServer()

		return true
	end
end

net.Receive("PrimaryFire", function(length, client)
	local weapon = net.ReadEntity()

	if (IsValid(weapon) and weapon.Owner != LocalPlayer()) then
		weapon:PrimaryAttack()
	end
end)

net.Receive("SecondaryFire", function(length, client)
	local weapon = net.ReadEntity()

	if (IsValid(weapon) and weapon.Owner != LocalPlayer()) then
		weapon:SecondaryAttack()
	end
end)

net.Receive("PlaceDecal", function(length, client)
	local name = net.ReadString()
	local startPos = net.ReadVector()
	local hitPos = net.ReadVector()
	local normal = net.ReadVector()

	if (isstring(name) and isvector(startPos) and isvector(hitPos) and isvector(normal)) then
		util.Decal(name, startPos + normal * 5, hitPos + normal * 5)
	end
end)

