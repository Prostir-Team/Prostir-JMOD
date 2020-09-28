SWEP.Base = "wep_jack_gmod_meleebase"
SWEP.Spawnable = true -- this obviously has to be set to true
SWEP.Category = "ArcCW - Other" -- edit this if you like
SWEP.AdminOnly = false

SWEP.PrintName = "Knife"
SWEP.Trivia_Class = "Melee Weapon"
SWEP.Trivia_Desc = "Sharp metal blade for stabbing and slashing."
SWEP.Trivia_Manufacturer = "Cold Steel"
SWEP.Trivia_Calibre = "N/A"
SWEP.Trivia_Mechanism = "Sharp Edge"
SWEP.Trivia_Country = "USA"
SWEP.Trivia_Year = 2006

SWEP.Slot = 0

SWEP.NotForNPCs = true

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/yurie_cod/iw7/tactical_knife_iw7_vm.mdl"
SWEP.WorldModel = "models/weapons/yurie_cod/iw7/tactical_knife_iw7_wm.mdl"
SWEP.ViewModelFOV = 60

SWEP.PrimaryBash = true
SWEP.CanBash = true
SWEP.MeleeDamage = 15
SWEP.MeleeRange = 32
SWEP.MeleeDamageType = DMG_SLASH

SWEP.MeleeGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE

SWEP.NotForNPCs = true

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "MELEE"
	},
}

SWEP.MeleeTime = 0.5

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "knife"

SWEP.Primary.ClipSize = -1

--[[
vm_knifeonly_drop
vm_knifeonly_idle
vm_knifeonly_raise
vm_knifeonly_sprint_in
vm_knifeonly_sprint_loop
vm_knifeonly_sprint_out
vm_knifeonly_swipe
--]]
SWEP.Animations = {
	["draw"] = {
		Source = "vm_knifeonly_raise",
		Time = 1,
		SoundTable = {{s = "snds_jack_gmod/ez_weapons/knives/draw", t = 0}}
	},
	["ready"] = {
		Source = "vm_knifeonly_raise",
		Time = 1,
	},
	["idle"] = {
		Source = "vm_knifeonly_idle",
		Time = 10,
	},
	["bash"] = {
		Source = "vm_knifeonly_swipe",
		Time = 0.7,
	}
}

SWEP.IronSightStruct = false

SWEP.BashPreparePos = Vector(0, 0, 0)
SWEP.BashPrepareAng = Angle(0, 5, 0)

SWEP.BashPos = Vector(0, 0, 0)
SWEP.BashAng = Angle(10, -10, 0)

SWEP.HolsterPos = Vector(0, -1, 2)
SWEP.HolsterAng = Angle(-15, 0, 0)