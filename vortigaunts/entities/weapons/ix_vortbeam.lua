if (CLIENT) then
	SWEP.Slot = 0
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = false
	SWEP.PrintName = "Vortibeam"
	SWEP.DrawCrosshair = true
	game.AddParticles("particles/Vortigaunt_FX.pcf")
end

PrecacheParticleSystem("vortigaunt_beam")
PrecacheParticleSystem("vortigaunt_beam_b")
PrecacheParticleSystem("vortigaunt_charge_token")

sound.Add({
	name = "NPC_Vortigaunt.ShootExplode",
	channel = CHAN_WEAPON,
	volume = 0.9,
	level = 80,
	pitch = {100, 110},
	sound = {"npc/vort/vort_explode1.wav", "npc/vort/vort_explode2.wav"}
});

SWEP.Instructions = "Primary Fire: Fire Beam\nSecondary Fire: Ground Pound\nReload: Melee"
SWEP.Purpose = "Roleplay"
SWEP.Contact = ""
SWEP.Author = "Nforce"
SWEP.WorldModel = ""
SWEP.ViewModel = ""

SWEP.HoldType = "beam"
SWEP.AdminSpawnable = false
SWEP.Spawnable = false
SWEP.DrawCrosshair = false

SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 170
SWEP.Primary.Delay = 1.8
SWEP.Primary.Ammo = ""
SWEP.Primary.Stamina = 30

SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 300
SWEP.Secondary.Ammo = ""
SWEP.Secondary.Radius = 230
SWEP.Secondary.Stamina = 80

SWEP.NoIronSightFovChange = true
SWEP.NoIronSightAttack = true
SWEP.LoweredAngles = Angle(60, 60, 60)
SWEP.IronSightPos = Vector(0, 0, 0)
SWEP.IronSightAng = Vector(0, 0, 0)
SWEP.IsAlwaysRaised = true

function SWEP:Holster(switchingTo)
	return true
end

function SWEP:Initialize()

end

function SWEP:PrimaryAttack()
	if (self.Owner:OnGround()) then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay);

		if (SERVER) then
			local _, duration = self.Owner:LookupSequence("zapattack1");

			net.Start("PrimaryFire")
				net.WriteEntity(self)
			net.Broadcast()

			self.Owner:ForceSequence("zapattack1", nil, duration);
		else
			if (self.Owner == LocalPlayer() and !IsFirstTimePredicted()) then return; end;

			if (!self.charge) then
				self.charge = CreateSound(self.Owner, "NPC_Vortigaunt.ZapPowerup");
			end;

			self.chargeStart = SysTime();
			self.chargeTime = 0.7;

			self.charge:Stop();

			self.charge:PlayEx(1, 150);

			if (self.Owner:LookupAttachment("leftclaw") != 0) then
				ParticleEffectAttach("vortigaunt_charge_token", PATTACH_POINT_FOLLOW, self.Owner, self.Owner:LookupAttachment("leftclaw"));
				ParticleEffectAttach("vortigaunt_charge_token", PATTACH_POINT_FOLLOW, self.Owner, self.Owner:LookupAttachment("rightclaw"));

				local leftCharge = CreateParticleSystem(self.Owner, "vortigaunt_beam_charge", PATTACH_POINT_FOLLOW, self.Owner:LookupAttachment("leftclaw"))
				local randVec = VectorRand();
				randVec.z = 0;

				leftCharge:SetControlPoint(1, self.Owner:WorldSpaceCenter() + self.Owner:GetRight() * -math.random(30, 70) - Vector(0, 0, 40) + randVec * math.random(5, 30) + self.Owner:GetForward() * math.random(5, 35))

				local rightCharge = CreateParticleSystem(self.Owner, "vortigaunt_beam_charge", PATTACH_POINT_FOLLOW, self.Owner:LookupAttachment("rightclaw"))
				randVec = VectorRand();
				randVec.z = 0;

				rightCharge:SetControlPoint(1, self.Owner:WorldSpaceCenter() + self.Owner:GetRight() * math.random(30, 70) - Vector(0, 0, 40) + randVec * math.random(5, 30) + self.Owner:GetForward() * math.random(5, 35))
			end;
		end;

		timer.Simple(0.7, function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:Alive()) then return; end;
			if (SERVER) then
				local shootTrace = {
					start = self.Owner:EyePos(),
					endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 16000,
					mask = MASK_SHOT,
					mins = Vector(-3, -3, -3),
					maxs = Vector(3, 3, 3),
					filter = self.Owner
				};

				self.Owner:LagCompensation(true)
					shootTrace = util.TraceHull(shootTrace)
				self.Owner:LagCompensation(false)

				local dmgInfo = DamageInfo();
				dmgInfo:SetDamage(self.Primary.Damage);
				dmgInfo:SetDamagePosition(shootTrace.HitPos);
				dmgInfo:SetDamageForce(shootTrace.Normal * 6000);
				dmgInfo:SetDamageType(DMG_SHOCK);
				dmgInfo:SetAttacker(self.Owner);
				dmgInfo:SetInflictor(self);

				util.BlastDamageInfo(dmgInfo, shootTrace.HitPos, 30);

				self.Owner:SetLocalVar("stm",
					self.Owner:GetLocalVar("stm", 0) - self.Primary.Stamina
				)
			else
				local shootTrace = {
					start = self.Owner:EyePos(),
					endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 16000,
					mask = MASK_SHOT,
					mins = Vector(-3, -3, -3),
					maxs = Vector(3, 3, 3),
					filter = self.Owner
				};

				self.Owner:LagCompensation(true)
					shootTrace = util.TraceHull(shootTrace)
				self.Owner:LagCompensation(false)

				local leftClaw = self.Owner:LookupAttachment("leftclaw");
				local rightClaw = self.Owner:LookupAttachment("rightclaw");

				self.charge:Stop();
				self.Owner:EmitSound("NPC_Vortigaunt.Shoot");
				self.Owner:StopParticles();

				sound.Play("NPC_Vortigaunt.ShootExplode", shootTrace.HitPos);

				util.Decal("fadingscorch", shootTrace.StartPos + shootTrace.Normal * 5, shootTrace.HitPos + shootTrace.Normal * 10);

				local effectData = EffectData();
				effectData:SetOrigin(shootTrace.HitPos);
				effectData:SetNormal(shootTrace.HitNormal);
			    effectData:SetMagnitude(3);
			    effectData:SetScale(1);
			    effectData:SetRadius(2);

				util.Effect("ElectricSpark", effectData, true, true);

				if (leftClaw != 0) then
					util.ParticleTracerEx("vortigaunt_beam", self.Owner:GetAttachment(leftClaw).Pos, shootTrace.HitPos, true, self.Owner:EntIndex(), leftClaw);
				else
					util.ParticleTracerEx("vortigaunt_beam", self.Owner:EyePos(), shootTrace.HitPos, true, self.Owner:EntIndex(), 1);
				end;

				if (rightClaw != 0) then
					util.ParticleTracerEx("vortigaunt_beam", self.Owner:GetAttachment(rightClaw).Pos, shootTrace.HitPos, true, self.Owner:EntIndex(), rightClaw);
				end;

				self.chargeStart = nil;
			end;
		end);
	end;
end;

function SWEP:SecondaryAttack()
	if (self.Owner:OnGround()) then
		self:SetNextSecondaryFire(CurTime() + 5);

		if (SERVER) then
			net.Start("SecondaryFire")
				net.WriteEntity(self)
			net.Broadcast()

			local _, duration = self.Owner:LookupSequence("dispel");

			self.Owner:ForceSequence("dispel", nil, duration);
		else
			timer.Simple(0.5, function()
				if (IsValid(self) and IsValid(self.Owner) and self.Owner:Alive()) then
					self.Owner:EmitSound("NPC_Vortigaunt.DispelImpact");
				end;
			end);

			self.chargeStart = SysTime();
			self.chargeTime = 1.8;

			if (self.Owner:LookupAttachment("leftclaw") != 0) then
				ParticleEffectAttach("vortigaunt_charge_token", PATTACH_POINT_FOLLOW, self.Owner, self.Owner:LookupAttachment("leftclaw"));
				ParticleEffectAttach("vortigaunt_charge_token", PATTACH_POINT_FOLLOW, self.Owner, self.Owner:LookupAttachment("rightclaw"));

				local leftCharge = CreateParticleSystem(self.Owner, "vortigaunt_beam_charge", PATTACH_POINT_FOLLOW, self.Owner:LookupAttachment("leftclaw"))
				local randVec = VectorRand();
				randVec.z = 0;

				leftCharge:SetControlPoint(1, self.Owner:WorldSpaceCenter() + self.Owner:GetRight() * -math.random(30, 70) - Vector(0, 0, 40) + randVec * math.random(5, 30) + self.Owner:GetForward() * math.random(5, 35))

				local rightCharge = CreateParticleSystem(self.Owner, "vortigaunt_beam_charge", PATTACH_POINT_FOLLOW, self.Owner:LookupAttachment("rightclaw"))
				randVec = VectorRand();
				randVec.z = 0;

				rightCharge:SetControlPoint(1, self.Owner:WorldSpaceCenter() + self.Owner:GetRight() * math.random(30, 70) - Vector(0, 0, 40) + randVec * math.random(5, 30) + self.Owner:GetForward() * math.random(5, 35))
			end;
		end;

		timer.Simple(1.8, function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:Alive()) then return; end;
			if (SERVER) then
				self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay);

				for _, v in pairs(ents.FindInSphere(self.Owner:GetPos(), self.Secondary.Radius * 2.5)) do
					if (IsValid(v) and v != self.Owner) then
						if (!(v:IsPlayer() or v:IsNPC() or v:Health() > 0 or v:GetClass() == "prop_physics")) then
							continue;
						end;

						if (v:IsPlayer() and v:Team() == FACTION_VORTIGAUNT) then
							continue;
						end;

						if (v:GetNoDraw()) then
							continue;
						end;

						local dmgTrace = {
							start = self.Owner:WorldSpaceCenter(),
							endpos = v:WorldSpaceCenter(),
							mask = MASK_ALL,
							filter = function(ent) if IsValid(ent) then return false; else return true; end; end;
						};

						self.Owner:LagCompensation(true)
							dmgTrace = util.TraceLine(dmgTrace)
						self.Owner:LagCompensation(false)

						if (dmgTrace.Fraction < 1.0 and dmgTrace.Entity != v) then
							continue;
						end;

						local vecDir = v:WorldSpaceCenter() - dmgTrace.StartPos;
						vecDir:Normalize()

						local flDist = vecDir:Length();
						local flFalloff = math.Remap(flDist, 0, self.Secondary.Radius * 0.75, 1.0, 0.1);
						local flDamage = math.Clamp(math.Remap(v:WorldSpaceCenter():Distance(dmgTrace.StartPos), 0, self.Secondary.Radius, 300, 0), 0, 300);

						vecDir = vecDir * (self.Secondary.Radius * 2 * flFalloff);

						if (v:IsPlayer() or v:IsNPC()) then
							v:SetLocalVelocity(vecDir);
						else
							if (IsValid(v:GetPhysicsObject())) then
								v:GetPhysicsObject():ApplyForceOffset(vecDir * 50, dmgTrace.HitPos);
							end;
						end;

						if (v:GetPos():Distance(self.Owner:GetPos()) <= self.Secondary.Radius) then
							local dmgInfo = DamageInfo();
							dmgInfo:SetAttacker(self.Owner);
							dmgInfo:SetInflictor(self.Owner);
							dmgInfo:SetDamageForce(vecDir);
							dmgInfo:SetDamagePosition(v:WorldSpaceCenter());
							dmgInfo:SetReportedPosition(self.Owner:GetPos());
							dmgInfo:SetDamage(v:GetClass() == "npc_antlion" and 500 or flDamage);
							dmgInfo:SetDamageType(DMG_SHOCK);

							v:TakeDamageInfo(dmgInfo);

							local effectData = EffectData();
							effectData:SetEntity(v);
							effectData:SetScale(1);
							effectData:SetMagnitude(1);

							for i = 0, 5 do
								timer.Simple(1 / i, function()
									util.Effect("TeslaHitBoxes", effectData, true, true);
								end);
							end;
						else
							-- flips antlions
							if (v:GetClass() == "npc_antlion" and v:Health() > 0 and v:IsFlagSet(FL_ONGROUND)) then
								v:SetCondition(71);
								v:EmitSound("NPC_Antlion.Pain");
							end;
						end;
					end;
				end;

				util.ScreenShake(self.Owner:GetPos(), 20, 150, 1, 1250);

				self.Owner:SetLocalVar("stm",
					self.Owner:GetLocalVar("stm", 0) - self.Secondary.Stamina
				)
			else
				local effectData = EffectData();
				effectData:SetOrigin(self.Owner:GetPos());
				util.Effect("vortdispel", effectData, true, true);
				self.Owner:StopParticleEmission();

				self.chargeStart = nil;

				for _, v in pairs(ents.FindInSphere(self.Owner:GetPos(), self.Secondary.Radius)) do
					if (IsValid(v) and v != self.Owner) then

						if (!(v:IsPlayer() or v:IsNPC() or v:Health() > 0 or v:GetClass() == "prop_physics")) then
							continue;
						end;

						if (v:IsPlayer() and v:Team() == FACTION_VORTIGAUNT) then
							continue;
						end;

						if (v:GetNoDraw()) then
							continue;
						end;

						local dmgTrace = {
							start = self.Owner:WorldSpaceCenter(),
							endpos = v:WorldSpaceCenter(),
							mask = MASK_ALL,
							filter = function(ent) if IsValid(ent) then return false; else return true; end; end;
						};

						self.Owner:LagCompensation(true)
							dmgTrace = util.TraceLine(dmgTrace)
						self.Owner:LagCompensation(false)

						if (dmgTrace.Fraction < 1.0 and dmgTrace.Entity != v) then
							continue;
						end;

						local charge = CreateParticleSystem(self.Owner, "vortigaunt_beam_charge", PATTACH_ABSORIGIN, 0);
						charge:SetControlPoint(1, v:WorldSpaceCenter());
					end;
				end;
			end;
		end);
	end;
end;

function SWEP:Reload()
	if (!IsFirstTimePredicted()) then return; end;

	if (!self.isPunching) then
		if ((self.punchCooldown or 0) > CurTime()) then return; end;

		self.punchCooldown = CurTime() + 20;
		self.nextPunch = CurTime() + 1;

		self.isPunching = true;

		timer.Simple(10, function()
			if (IsValid(self)) then
				self.isPunching = false;

				self.chargeStart = nil;

				if (SERVER) then
					SafeRemoveEntity(self.leftGlow);
					SafeRemoveEntity(self.rightGlow);
				end;
			end;
		end);

		if (CLIENT) then
			self.chargeStart = SysTime();
			self.chargeTime = 10;
		else
			self.leftGlow = ents.Create("vort_charge_token");
			self.leftGlow:Spawn();
			self.leftGlow:SetParent(self.Owner);
			self.leftGlow:Fire("SetParentAttachment", "leftclaw");

			self.rightGlow = ents.Create("vort_charge_token");
			self.rightGlow:Spawn();
			self.rightGlow:SetParent(self.Owner);
			self.rightGlow:Fire("SetParentAttachment", "rightclaw");

			self:CallOnRemove("clearGlow", function(wep)
				SafeRemoveEntity(wep.leftGlow);
				SafeRemoveEntity(wep.rightGlow);
			end);
		end;
	else
		if ((self.nextPunch or 0) < CurTime()) then
			self.nextPunch = CurTime() + 1;

			if (SERVER) then
				local punchTrace = {
					start = self.Owner:EyePos(),
					endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 90,
					mask = MASK_SOLID,
					filter = self.Owner,
					mins = Vector(-2, -2, -2),
					maxs = Vector(2, 2, 2)
				};

				self.Owner:LagCompensation(true)
					punchTrace = util.TraceHull(punchTrace)
				self.Owner:LagCompensation(false)

				self.Owner:ForceSequence("meleehigh" .. math.random(1, 2), nil, nil, true);

				if (punchTrace.Hit and !punchTrace.HitSky) then
					net.Start("PlaceDecal")
						net.WriteString("fadingscorch")
						net.WriteVector(punchTrace.StartPos)
						net.WriteVector(punchTrace.HitPos)
						net.WriteVector(punchTrace.Normal)
					net.Broadcast()

					util.ScreenShake(punchTrace.HitPos, 10, 50, 0.3, 300);

					sound.Play("NPC_Vortigaunt.ShootExplode", punchTrace.HitPos);

					local effectData = EffectData();
					effectData:SetOrigin(punchTrace.HitPos);
					effectData:SetNormal(punchTrace.HitNormal);
				    effectData:SetMagnitude(2);
				    effectData:SetScale(1);
				    effectData:SetRadius(1);

					util.Effect("ElectricSpark", effectData, true, true);

					if (IsValid(punchTrace.Entity)) then
						local force = (punchTrace.HitPos - self.Owner:EyePos()):GetNormalized();
						local dmgInfo = DamageInfo();
						dmgInfo:SetDamage(math.random(50, 90));
						dmgInfo:SetDamageType(DMG_CRUSH);
						dmgInfo:SetAttacker(self.Owner);
						dmgInfo:SetInflictor(self);
						dmgInfo:SetDamageForce(force * 2500);
						dmgInfo:SetDamagePosition(punchTrace.HitPos);

						punchTrace.Entity:TakeDamageInfo(dmgInfo);
					end;
				end;
			end;
		end;
	end;
end;

