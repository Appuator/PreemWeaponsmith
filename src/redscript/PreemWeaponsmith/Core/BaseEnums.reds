module PreemCrafting.Core

enum PreemStatType{
    ReloadSpeed = 0,
    ProjectilePerShot = 1
}

enum PreemModTriggerType{
    Auto = 0,
    SemiAuto = 1,
    Burst = 2,
    InstaBurst = 3,
    TripleAction = 4
}

enum PreemModBarrelType{
    Normal = 0,
    Attachment = 1,
    Tech = 2,
    Atomizer = 3,
    Smart = 4,
    Hacker = 5
}

enum PreemModMagType{
    Normal = 0,
    Burn = 1,
    Shock = 2,
    Chemical = 3,
    Bleed = 4
}

enum PreemModSightType{
    Normal = 0,
    Smart = 1,
    Choke = 2
}

enum PreemModStyleType{
    Barrel_Normal = 0,
    Barrel_Attachment_Sight = 1,    // adds attachment sight slot to weapon.
    Barrel_Attachment_Muzzle = 2,   // adds attachment muzzle slot to weapon.
    Barrel_Tech = 3,
    Barrel_Smart = 4,
    Barrel_Atomizer = 5,            // if possible, will try and use toxic grenade explosion gas as projectile
    Barrel_Hacker = 6,              // if possible, will apply Breach Protocol debuff
    Barrel_ExtraBarrel = 7,         // x2 projectiles at full damage, x2 recoil
    Barrel_Recoil = 8,              // Reduce Recoil  in X
    Barrel_RecoilY = 9,              // Reduce Recoil  in Y
    Barrel_Turbo = 10,              // fireRate + 30%
    Barrel_Power = 11,
    Barrel_Silencer = 12,
    Barrel_SmartMultiTarget = 13,
    Barrel_SmartRangeTarget = 14,
    Barrel_SmartLongLock = 15,
    Barrel_TurboCharger = 16,
    Barrel_OmegaCharge = 17,
    Barrel_VelocityBooster = 18,
    Barrel_CorkscrewRifling = 19,                 
    Trigger_Normal = 100,
    Trigger_FullAuto = 101,
    Trigger_SemiAuto = 102,
    Trigger_Burst = 103,
    Trigger_InstaBurst = 104,       // all shots in burst fire at once. 0 cycle time
    Trigger_UltraAction = 105,     // almost maxed fire rate, but semi-Auto
    Trigger_Charge = 106,
    Trigger_ChargeFullAuto = 107,
    Mag_Normal = 200,
    Mag_Thermal = 201,
    Mag_Electric = 202,
    Mag_Chemical = 203,
    Mag_Bleed = 204,
    Mag_Reload = 205,               // Increase Reload Speed 20%
    Mag_Extended = 206,
    Mag_QuickMag = 207,
    Sight_Normal = 300,
    Sight_Smart = 301,
    Sight_Choke = 302,
    Sight_TriggerMode = 303,
    Blade_Chem = 400,
    Blade_Shock= 401,
    Blade_Thermal = 402,
    Blade_Bleed = 403,
    Blade_CritChance = 404,
    Blade_CritDamage= 405,
    Blade_DeflectorBlade= 406,
    Handle_RubberizedGrip = 500,
    Handle_Dash = 501,
    Handle_Leap = 502,
    Handle_AttackSpeed = 503,
    Handle_StaminaReduction = 504
}

enum PreemModClassType
{
    Trigger = 0,
    Barrel = 1,
    Mag = 2,
    Sight = 3,
    Blade = 4,
    Handle = 5,
    Blunt = 6
}