﻿--[[
1 axe
1 bat
1 bow
1 combat knife
1 hatchet
1 pocket knife
1 sledgehammer
1 sword
2 blunderbuss
2 musket
3 cap and ball revolver
4 break-action shotgun
4 revolver
4 single shot rifle
5 crossbow
6 bolt action rifle
6 lever-action rifle
6 magnum revolver
6 pump-action shotgun
6 shot revolver
7 grenade launcher
7 pistol
7 plinking pistol
7 pocket pistol
7 sniper rifle
8 anti-materiel sniper rifle
8 assault rifle
8 battle rifle
8 carbine
8 designated marksman rifle
8 machine pistol
8 magnum pistol
8 rocket launcher
8 semiautomatic shotgun
8 submachine gun
9 anti-materiel rifle
9 fully-automatic shotgun
9 light machine gun
9 medium machine gun
10 multiple grenade launcher
10 multiple rocket launcher
-------------------------------
"VertexlitGeneric"
{
   "$basetexture" "models/weapons/v_models/CoD4/m4a1/weapon_m4_col"
	$bumpmap   "models/weapons/v_models/CoD4/m4a1/normal"

	$phong  "1"
	$phongboost  ".2"
	$phongfresnelranges     "[1 1 1]"
	$phongexponent 20
	$nocull  1
}
$attachment "muzzle" "ValveBiped.Bip01_R_Hand" 38 0 -12 rotate 15 0 0
$attachment "shell" "ValveBiped.Bip01_R_Hand" 9.5 -0.7 -5 rotate 30 90 -90

$definebone "ValveBiped.Bip01_R_Hand" "" -0.678304 13.183071 4.586786 10.000006 -89.999982 -179.999978 0 0 0 0 0 0
--]]
JMod.WeaponTable = {

}

-- keepcorpses caauses floating arrow bug
JMod.AmmoTable = {

}

function JMod.LoadAmmoTable(tbl)
	for k, v in pairs(tbl) do
		v.carrylimit = v.carrylimit or -2
		game.AddAmmoType({
			name = k,
			maxcarry = v.carrylimit,
			npcdmg = v.basedmg,
			plydmg = v.basedmg,
			dmgtype = v.dmgtype or DMG_BULLET
		})
		if SERVER then
			timer.Simple(1, function()
				if (v.resourcetype) and (v.resourcetype == "munitions") then
					if not(table.HasValue(JMod.Config.Weapons.AmmoTypesThatAreMunitions, k)) then
						table.insert(JMod.Config.Weapons.AmmoTypesThatAreMunitions, k)
					end
				elseif not(v.resourcetype) then
					if not(table.HasValue(JMod.Config.Weapons.WeaponAmmoBlacklist, k)) then
						table.insert(JMod.Config.Weapons.WeaponAmmoBlacklist, k)
					end
				end
			end)
		end

		if CLIENT then
			language.Add(k .. "_ammo", k)

			if v.ent then
				language.Add(v.ent, v.nicename or ("EZ " .. k))
			end
		end
	end
end

-- Dynamically create weapon Ents
function JMod.GenerateWeaponEntities(tbl)
	for name, info in pairs(tbl) do
		if info.noent then continue end

		local WeaponEnt = {}
		WeaponEnt.Base = "ent_jack_gmod_ezweapon"
		WeaponEnt.PrintName = info.PrintName or name
		if info.Spawnable == nil then
			WeaponEnt.Spawnable = true
		else
			WeaponEnt.Spawnable = info.Spawnable
		end
		WeaponEnt.AdminOnly = info.AdminOnly or false
		WeaponEnt.Category = info.Category or "JMod - EZ Weapons"
		WeaponEnt.WeaponName = name
		WeaponEnt.ModelScale = info.gayPhysics and nil or info.size -- or math.max(info.siz.x, info.siz.y, info.siz.z)
		scripted_ents.Register(WeaponEnt, info.ent)

		if CLIENT then
			language.Add(info.ent, name)
		end
	end
end

JMod.LoadAmmoTable(JMod.AmmoTable)
JMod.GenerateWeaponEntities(JMod.WeaponTable)

-- support third-party additions to the jmod ammo/weapons table
function JMod.LoadAdditionalAmmo()
	if JMod.AdditionalAmmoTable then
		table.Merge(JMod.AmmoTable, JMod.AdditionalAmmoTable)
		JMod.LoadAmmoTable(JMod.AdditionalAmmoTable)
	end
end
hook.Add("Initialize", "JMod_LoadAdditionalAmmo", JMod.LoadAdditionalAmmo)

function JMod.LoadAdditionalWeaponEntities()
	if JMod.AdditionalWeaponTable then
		table.Merge(JMod.WeaponTable, JMod.AdditionalWeaponTable)
		JMod.GenerateWeaponEntities(JMod.AdditionalWeaponTable)
	end
end
hook.Add("Initialize", "JMod_LoadAdditionalWeaponEntities", JMod.LoadAdditionalWeaponEntities)

--JMod.LoadAdditionalAmmo()
--JMod.LoadAdditionalWeaponEntities()

function JMod.GetAmmoSpecs(typ)
	if not JMod.AmmoTable[typ] then return nil end
	local Result, BaseType = table.FullCopy(JMod.AmmoTable[typ]), string.Split(typ, "-")[1]

	return table.Inherit(Result, JMod.AmmoTable[BaseType])
end

function JMod.ApplyAmmoSpecs(wep, typ, mult)
	mult = mult or 1
	wep.Primary.Ammo = typ
	local Specs = JMod.GetAmmoSpecs(typ)
	if not Specs then print("[JMod] - " ..typ.." is not a registered ammo type") return end
	wep.Damage = Specs.basedmg * mult
	wep.Num = Specs.projnum or 1

	if Specs.effrange then
		wep.Range = Specs.effrange
	end

	if Specs.terminaldmg then
		wep.DamageMin = Specs.terminaldmg * mult
	end

	if Specs.penetration then
		wep.Penetration = Specs.penetration
	end

	if Specs.blastrad then
		wep.BlastRadius = Specs.blastrad
	end

	if Specs.dmgtype then
		wep.DamageType = Specs.dmgtype
	end

	if Specs.expanding then
		wep.EZexpangingAmmo = Specs.expanding
	end

	if Specs.armorpiercing then
		wep.EZarmorpiercingAmmo = Specs.armorpiercing
	end

	-- todo: implement this when we add these types
	if Specs.tracer then
		wep.Tracer = Specs.tracer
	else
		wep.Tracer = nil
	end
end

for k, v in pairs({"muzzleflash_g3", "muzzleflash_m14", "muzzleflash_ak47", "muzzleflash_ak74", "muzzleflash_6", "muzzleflash_pistol_rbull", "muzzleflash_pistol", "muzzleflash_suppressed", "muzzleflash_pistol_deagle", "muzzleflash_OTS", "muzzleflash_M3", "muzzleflash_smg", "muzzleflash_SR25", "muzzleflash_shotgun", "muzzle_center_M82", "muzzleflash_m79"}) do
	PrecacheParticleSystem(v)
end

JMod.GunHandlingSounds = {
	draw = {
		handgun = {"snds_jack_gmod/ez_weapons/handling/draw_pistol1.wav", "snds_jack_gmod/ez_weapons/handling/draw_pistol2.wav", "snds_jack_gmod/ez_weapons/handling/draw_pistol3.wav", "snds_jack_gmod/ez_weapons/handling/draw_pistol4.wav", "snds_jack_gmod/ez_weapons/handling/draw_pistol5.wav", "snds_jack_gmod/ez_weapons/handling/draw_pistol6.wav"},
		longgun = {"snds_jack_gmod/ez_weapons/handling/draw_longgun1.wav", "snds_jack_gmod/ez_weapons/handling/draw_longgun2.wav", "snds_jack_gmod/ez_weapons/handling/draw_longgun3.wav", "snds_jack_gmod/ez_weapons/handling/draw_longgun4.wav", "snds_jack_gmod/ez_weapons/handling/draw_longgun5.wav", "snds_jack_gmod/ez_weapons/handling/draw_longgun6.wav", "snds_jack_gmod/ez_weapons/handling/draw_longgun7.wav", "snds_jack_gmod/ez_weapons/handling/draw_longgun8.wav"}
	},
	tap = {
		magwell = {"snds_jack_gmod/ez_weapons/handling/tap_magwell1.wav", "snds_jack_gmod/ez_weapons/handling/tap_magwell2.wav", "snds_jack_gmod/ez_weapons/handling/tap_magwell3.wav", "snds_jack_gmod/ez_weapons/handling/tap_magwell4.wav", "snds_jack_gmod/ez_weapons/handling/tap_magwell5.wav", "snds_jack_gmod/ez_weapons/handling/tap_magwell6.wav"},
		metallic = {"snds_jack_gmod/ez_weapons/handling/tap_metallic.wav"}
	},
	aim = {
		inn = {"snds_jack_gmod/ez_weapons/handling/aim1.wav", "snds_jack_gmod/ez_weapons/handling/aim2.wav", "snds_jack_gmod/ez_weapons/handling/aim3.wav", "snds_jack_gmod/ez_weapons/handling/aim4.wav", "snds_jack_gmod/ez_weapons/handling/aim5.wav", "snds_jack_gmod/ez_weapons/handling/aim6.wav"},
		out = {"snds_jack_gmod/ez_weapons/handling/aim_out.wav"},
		minor = {"snds_jack_gmod/ez_weapons/handling/aim_minor.wav"}
	},
	cloth = {
		loud = {"snds_jack_gmod/ez_weapons/handling/cloth_loud.wav"},
		quiet = {"snds_jack_gmod/ez_weapons/handling/cloth_quiet.wav"},
		magpull = {"snds_jack_gmod/ez_weapons/handling/cloth_magpull1.wav", "snds_jack_gmod/ez_weapons/handling/cloth_magpull2.wav", "snds_jack_gmod/ez_weapons/handling/cloth_magpull3.wav", "snds_jack_gmod/ez_weapons/handling/cloth_magpull4.wav"},
		move = {"snds_jack_gmod/ez_weapons/handling/cloth_move.wav"}
	},
	grab = {"snds_jack_gmod/ez_weapons/handling/grab1.wav"},
	shotshell = {"snds_jack_gmod/ez_weapons/handling/shotshell_insert1.wav", "snds_jack_gmod/ez_weapons/handling/shotshell_insert2.wav", "snds_jack_gmod/ez_weapons/handling/shotshell_insert3.wav", "snds_jack_gmod/ez_weapons/handling/shotshell_insert4.wav"}
}

if CLIENT then
	net.Receive("JMod_EZweaponMod", function()
		local Type, ply = net.ReadInt(16), LocalPlayer()

		-- ammo type switch
		if Type == 1 then
			local Wep = ply:GetActiveWeapon()

			if Wep then
				Wep.Primary.Ammo = net.ReadString()
				surface.PlaySound(table.Random(JMod.GunHandlingSounds.tap.magwell))
			end
		end
	end)

	hook.Add("RenderScene", "JMod_ArcCW_RenderScene", function()
		local wpn = LocalPlayer():GetActiveWeapon()
		if not wpn.ArcCW then return end

		if wpn.ForceExpensiveScopes then
			wpn:FormRTScope()
		end
	end)

	concommand.Add("jacky_wep_debug", function(ply, cmd, args)
		local VM = ply:GetViewModel()
		print(VM:GetModel())
		print(ply:GetActiveWeapon().WorldModel)

		for i = 0, 20 do
			local Info = VM:GetSequenceInfo(i)

			if Info then
				print("seq", i, Info.label)

				for k, v in pairs(Info.anims) do
					local Anim = VM:GetAnimInfo(v)

					if Anim then
						print("anim", Anim.label, Anim.fps .. "fps", Anim.numframes .. " total frames")
					end
				end
			end
		end

		print("---------------------")

		for i = 0, 100 do
			local Name = VM:GetBoneName(i)

			if Name then
				print("bone", i, Name)
			end
		end

		print("---------------------")
		PrintTable(VM:GetBodyGroups())
		print("---------------------")
		PrintTable(VM:GetAttachments())
	end, nil, "Helps with EZ weapon debugging.")

	local SlotInfoTable = {
		back = {
			right = {
				bone = "ValveBiped.Bip01_Spine4"
			},
			left = {
				bone = "ValveBiped.Bip01_Spine4"
			}
		},
		thighs = {
			right = {
				bone = "ValveBiped.Bip01_R_Thigh"
			},
			left = {
				bone = "ValveBiped.Bip01_L_Thigh"
			}
		},
		hips = {
			right = {
				bone = "ValveBiped.Bip01_Spine1"
			},
			left = {
				bone = "ValveBiped.Bip01_Spine1"
			}
		}
	}

	local function RenderHolsteredWeapon(ply, slot, side)
		local Class = ply.EZweapons.slots[slot][side]
		local CurWep = ply:GetActiveWeapon()

		if Class and ply:HasWeapon(Class) and IsValid(CurWep) and not (CurWep:GetClass() == Class) then
			local mdl, slotInfo = ply.EZweapons.mdls[Class], SlotInfoTable[slot][side]
			if not IsValid(mdl) then return end
			local ID = ply:LookupBone(slotInfo.bone)

			if ID then
				local Wep = ply:GetWeapon(Class)
				local WepPos, WepAng = Wep.BodyHolsterPos, Wep.BodyHolsterAng

				if side == "left" then
					WepPos = Wep.BodyHolsterPosL
					WepAng = Wep.BodyHolsterAngL
				end

				local pos, ang = ply:GetBonePosition(ID)
				local up, right, forward = ang:Up(), ang:Right(), ang:Forward()
				pos = pos + right * WepPos.x + forward * WepPos.y + up * WepPos.z
				ang:RotateAroundAxis(right, WepAng.p)
				ang:RotateAroundAxis(up, WepAng.y)
				ang:RotateAroundAxis(forward, WepAng.r)
				mdl:SetRenderOrigin(pos)
				mdl:SetRenderAngles(ang)
				render.SetColorModulation(1, 1, 1)
				mdl:DrawModel()
			end
		else
			ply.EZweapons.slots[slot][side] = nil
		end
	end

	hook.Add("PostPlayerDraw", "JMod_WeaponPlayerDraw", function(ply)
		if not ply:Alive() then return end

		if not ply.EZweapons then
			ply.EZweapons = {
				mdls = {},
				slots = {
					back = {
						left = nil,
						right = nil,
						center = nil
					},
					thighs = {
						left = nil,
						right = nil
					},
					hips = {
						left = nil,
						right = nil
					}
				}
			}
		end

		local ActiveWep = ply:GetActiveWeapon()

		for k, wep in pairs(ply:GetWeapons()) do
			if wep.BodyHolsterSlot then
				local Class, Slots = wep:GetClass(), ply.EZweapons.slots[wep.BodyHolsterSlot]

				if wep ~= ActiveWep then
					if not ply.EZweapons.mdls[Class] or not IsValid(ply.EZweapons.mdls[Class]) then
						local mdl = ClientsideModel(wep.BodyHolsterModel or wep.WorldModel)
						mdl:SetPos(ply:GetPos())
						mdl:SetParent(ply)
						mdl:SetModelScale(wep.BodyHolsterScale or 1)
						mdl:SetNoDraw(true)
						ply.EZweapons.mdls[Class] = mdl
					end

					-- lul
					if not Slots.right and (Slots.left ~= Class) then
						Slots.right = Class
					elseif not Slots.left and (Slots.right ~= Class) then
						Slots.left = Class
					end
				end
			end
		end

		RenderHolsteredWeapon(ply, "back", "right")
		RenderHolsteredWeapon(ply, "back", "left")
		RenderHolsteredWeapon(ply, "thighs", "right")
		RenderHolsteredWeapon(ply, "thighs", "left")
		RenderHolsteredWeapon(ply, "hips", "left")
		RenderHolsteredWeapon(ply, "hips", "right")
	end)
elseif SERVER then
	concommand.Add("jmod_ez_dropweapon", function(ply, cmd, args)
		if not ply:Alive() then return end
		local Wep = ply:GetActiveWeapon()

		if IsValid(Wep) and Wep.EZdroppable then
			ply:DropWeapon(Wep)
		end
	end, nil, "Drops your current EZ weapon.")

	concommand.Add("jmod_ez_switchammo", function(ply, cmd, args)
		-- TODO: this is not complete, we need to modify more traits
		-- TracerNum, Penetration, DamageType, Num, maybe Accuracy and Recoil
		-- and somehow we have to keep track of the original values during swaps
		if not ply:Alive() then return end
		local Wep = ply:GetActiveWeapon()
		if not (Wep.Primary.Ammo and JMod.AmmoTable[Wep.Primary.Ammo]) then return end
		local AllTypes, OriginalType = {}, string.Split(Wep.Primary.Ammo, "-")[1]

		for name, info in pairs(JMod.AmmoTable) do
			if string.find(name, OriginalType) and (ply:GetAmmoCount(name) > 0) then
				table.insert(AllTypes, name)
			end
		end

		if #AllTypes <= 0 then return end
		local CurrentIndex = table.KeyFromValue(AllTypes, Wep.Primary.Ammo)
		local NewIndex = CurrentIndex + 1

		if NewIndex > #AllTypes then
			NewIndex = 1
		end

		local NewType = AllTypes[NewIndex]

		if NewType ~= Wep.Primary.Ammo then
			Wep:Unload()
			Wep.Primary.Ammo = NewType
			net.Start("JMod_EZweaponMod")
			net.WriteInt(1, 16)
			net.WriteString(NewType)
			net.Send(ply)
		else
			JMod.Hint(ply, "no alternate ammo")
		end
	end, nil, "Switches your current ammo type for your EZ weapon.")

	local IsAmmoOnTable = function(ammoName, tableToCheck)
		if not ammoName then return false end
		local IsListed = false
		for k, v in ipairs(tableToCheck) do
			if ammoName == v then
				IsListed = true
				break
			elseif string.find(v, '%*$') then
				IsListed = (string.find(ammoName, '^'..string.sub(v, 1, -2)) ~= nil)
				break
			end
		end
		return IsListed
	end

	function JMod.GiveAmmo(ply, ent, noRemove)
		-- it's a resource box
		if ent.EZsupplies then
			local Wep = ply:GetActiveWeapon()

			if Wep then
				local PrimType, SecType, PrimSize, SecSize = Wep:GetPrimaryAmmoType(), Wep:GetSecondaryAmmoType(), Wep:GetMaxClip1(), Wep:GetMaxClip2()
				local PrimMax, SecMax, PrimName, SecName = game.GetAmmoMax(PrimType), game.GetAmmoMax(SecType), game.GetAmmoName(PrimType), game.GetAmmoName(SecType)
				
				local IsMunitionBox = ent.EZsupplies == "munitions"

				--[[ PRIMARY --]]
				if PrimName then
					PrimMax = PrimMax * JMod.Config.Weapons.AmmoCarryLimitMult
					local IsPrimMunitions = IsAmmoOnTable(PrimName, JMod.Config.Weapons.AmmoTypesThatAreMunitions)
					if (IsPrimMunitions == IsMunitionBox) and not(IsAmmoOnTable(PrimName, JMod.Config.Weapons.WeaponAmmoBlacklist)) then
						if PrimSize == -1 then
							PrimSize = -PrimSize
						end

						local CurrentAmmo, ResourceLeftInBox = ply:GetAmmoCount(PrimName), ent:GetResource()
						local SpaceLeftInPlayerInv = PrimMax - CurrentAmmo
						local AmmoPerResourceUnit = PrimMax / 30
						local ResourceUnitPerAmmo = 1 / AmmoPerResourceUnit
						local AmtToGive = math.min(PrimSize, math.floor(ResourceLeftInBox / ResourceUnitPerAmmo), SpaceLeftInPlayerInv)
						if (AmtToGive > 0) and (ply:GetAmmoCount(PrimType) < PrimMax) then
							ply:GiveAmmo(AmtToGive, PrimType)
							ent:SetResource(ResourceLeftInBox - math.ceil(AmtToGive * ResourceUnitPerAmmo))
							ent:UseEffect(ent:GetPos(), ent)

							if ent:GetResource() <= 0 then
								if not noRemove then
									ent:Remove()
								end

								return
							end
						end
					end
				end
				
				if ent:GetResource() <= 0 then return end
				--[[ Secondary --]]
				if SecName then
					SecMax = SecMax * JMod.Config.Weapons.AmmoCarryLimitMult
					local IsSecMunitions = IsAmmoOnTable(SecName, JMod.Config.Weapons.AmmoTypesThatAreMunitions)
					if (IsSecMunitions == IsMunitionBox) and not(IsAmmoOnTable(SecName, JMod.Config.Weapons.WeaponAmmoBlacklist)) then
						if SecSize == -1 then
							SecSize = -SecSize
						end

						local CurrentAmmo, ResourceLeftInBox = ply:GetAmmoCount(SecName), ent:GetResource()
						local SpaceLeftInPlayerInv = SecMax - CurrentAmmo
						local AmmoPerResourceUnit = SecMax / 30
						local ResourceUnitPerAmmo = 1 / AmmoPerResourceUnit
						local AmtToGive = math.min(SecSize, math.floor(ResourceLeftInBox / ResourceUnitPerAmmo), SpaceLeftInPlayerInv)
						
						if (AmtToGive > 0) and (ply:GetAmmoCount(SecType) < SecMax) then
							ply:GiveAmmo(AmtToGive, SecType)
							ent:SetResource(ResourceLeftInBox - math.ceil(AmtToGive * ResourceUnitPerAmmo))
							ent:UseEffect(ent:GetPos(), ent)

							if ent:GetResource() <= 0 then
								if not noRemove then
									ent:Remove()
								end

								return
							end
						end
					end
				end
			end
		elseif ent.EZammo then
			-- it's a specific ammo box or ammo entity
			local Typ, CountInBox = ent.EZammo, ent:GetCount()
			local AmmoInfo, CurrentAmmo = JMod.GetAmmoSpecs(Typ), ply:GetAmmoCount(Typ)
			local SpaceLeftInPlayerInv = AmmoInfo.carrylimit - CurrentAmmo
			local AmtToGive = math.min(SpaceLeftInPlayerInv, CountInBox)

			if AmtToGive > 0 then
				ply:GiveAmmo(AmtToGive, Typ)
				ent:UseEffect(ent:GetPos(), ent)
				ent:SetCount(CountInBox - AmtToGive)

				if ent:GetCount() <= 0 then
					if not noRemove then
						ent:Remove()
					end

					return
				end
			end
		end
	end
end
-- todo: fix judge anims, remove the extra round
