--AdventureBoots 2023
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "JMod Corpse"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "Momento Mori"
ENT.Spawnable = false -- This is not meant to be spawned seperate from a player

if SERVER then
	function ENT:Initialize()
		if not self.DeadPlayer then self:Remove() return end
		self.EZoverDamage = self.EZoverDamage or 0
		self.TimeTillRemoval = JMod.Config.QoL.JModCorpseStayTime

		self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:SetNoDraw(true)

		local Ply = self.DeadPlayer
		local Ragdoll = ents.Create("prop_ragdoll")
		if self.DeadPlayer.EZoriginalPlayerModel then
			Ragdoll:SetModel(Ply.EZoriginalPlayerModel)
		else
			Ragdoll:SetModel(Ply:GetModel())
		end
		Ragdoll:SetPos(Ply:GetPos())
		Ragdoll:SetAngles(Ply:GetAngles())
		Ragdoll:Spawn()
		Ragdoll:Activate()
		----------------------Kycea contribution Begin----------------------
		timer.Simple(0, function()
			if IsValid(Ragdoll) then
				for i = 0, Ragdoll:GetPhysicsObjectCount() do
					local Phys = Ragdoll:GetPhysicsObjectNum(i)
					if (Phys) and IsValid(Phys)then
						local pos, ang = Ply:GetBonePosition(Ply:TranslatePhysBoneToBone(i))
						Phys:SetPos(pos)
						Phys:SetVelocity(Ply:GetVelocity())
						Phys:SetAngles(ang)
					end
				end
			end
		end)
		----------------------Kycea contribution end------------------------
		if IsValid(Ragdoll) then
			Ragdoll.EZarmorP = {}
			local Parachute = false
			for k, v in pairs(Ply.EZarmor.items) do
				local ArmorInfo = JMod.ArmorTable[v.name]
				if not ArmorInfo.plymdl then
					local Index = Ragdoll:LookupBone(ArmorInfo.bon)
					local Pos, Ang = Ragdoll:GetBonePosition(Index)
					
					if Pos and Ang then
						-- Pos it
						local Right, Forward, Up = Ang:Right(), Ang:Forward(), Ang:Up()
						Pos = Pos + Right * ArmorInfo.pos.x + Forward * ArmorInfo.pos.y + Up * ArmorInfo.pos.z
						Ang:RotateAroundAxis(Right, ArmorInfo.ang.p)
						Ang:RotateAroundAxis(Up, ArmorInfo.ang.y)
						Ang:RotateAroundAxis(Forward, ArmorInfo.ang.r)
						-- Spawn it
						local ArmorPiece = ents.Create(ArmorInfo.ent)
						ArmorPiece:SetPos(Pos)
						ArmorPiece:SetAngles(Ang)
						ArmorPiece:SetOwner(self)
						ArmorPiece:ManipulateBoneScale(0, ArmorInfo.siz)
						ArmorPiece:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
						ArmorPiece:Spawn()
						ArmorPiece:Activate()

						Ragdoll.EZarmorP[v.name] = ArmorPiece
						if ArmorInfo.eff and ArmorInfo.eff.parachute then
							Parachute = v.name
							local BonePhys = Ragdoll:GetPhysicsObjectNum(Index)
							ArmorPiece:GetPhysicsObject():ApplyForceCenter(Vector(0, 0, -100))
						end
						-- Attach it
						local Weld = constraint.Weld(ArmorPiece, Ragdoll, 0, Ragdoll:TranslateBoneToPhysBone(Index), 0, true)
						if Weld then
							Weld:Activate()
						end
					end
				end
			end

			if IsValid(Ply.EZparachute) and Parachute then
				Ply.EZparachute:SetNW2Entity("Owner", Ragdoll.EZarmorP[Parachute])
				ParachuteEnt = Ragdoll.EZarmorP[Parachute]
				ParachuteEnt:SetNW2Bool("EZparachuting", true)
				ParachuteEnt.EZparachute = Ply.EZparachute
				ParachuteEnt.EZparachute.AttachBone = 0
				ParachuteEnt.EZparachute.Drag = ParachuteEnt.EZparachute.Drag * 5
			end
			Ply:SetNW2Bool("EZparachuting", true)
			Ply.EZparachute = nil
		end
		Ragdoll.IsEZcorpse = true
		self.EZragdoll = Ragdoll
		timer.Simple(0, function()
			if IsValid(self) and IsValid(self.EZragdoll) then
				self:SetParent(self.EZragdoll)
			else
				SafeRemoveEntity(self)
			end
		end)
		self:NextThink(CurTime() + 1)
	end

	function ENT:Think()
		local Time = CurTime()

		--[[if not(IsValid(self.DeadPlayer)) or self.DeadPlayer:Alive() then
			self.VeryDead = true
		end]]--

		if self.EZoverDamage >= 100 then
			self.VeryDead = true
		else
			self.EZoverDamage = math.Clamp(self.EZoverDamage + 2, 0, 100)
		end

		if self.VeryDead then
			self.TimeTillRemoval = math.Clamp(self.TimeTillRemoval - 1, 0, JMod.Config.QoL.JModCorpseStayTime)
			if self.TimeTillRemoval <= 0 then
				self:Remove()
			end
		end

		self:NextThink(Time + 1)

		return true
	end

	function ENT:OnRemove() 
		if IsValid(self.EZragdoll) then
			if istable(self.EZragdoll.EZarmorP) then
				for _, v in pairs(self.EZragdoll.EZarmorP) do
					local Con = constraint.FindConstraintEntity(v, "Weld")
					if IsValid(Con) then
						local Ent1, Ent2 = Con:GetConstrainedEntities()
						if (IsValid(Ent1) and Ent1 == self.EZragdoll) or (IsValid(Ent2) and Ent2 == self.EZragdoll) then
							SafeRemoveEntity(v)
						end
					end
				end
			end
			SafeRemoveEntity(self.EZragdoll)
		end
	end
end