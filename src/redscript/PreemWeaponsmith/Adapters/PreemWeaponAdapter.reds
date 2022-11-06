module PreemCrafting.Adapters.WeaponObjectAdapter
import PreemCrafting.Core.*

@addMethod(WeaponObject)
protected final func ChangeTriggerBasedOnPreemMods(){

    let triggerType = this.GetTriggerTypeBasedOnPreemMods();
    if(NotEquals(triggerType,gamedataTriggerMode.Invalid))
    {
        WeaponObject.ChangeTriggerMode(this, triggerType);
    }
}

@addMethod(WeaponObject)
protected final func GetAttackBasedOnPreemMods() -> TweakDBID
{
    let resultID: TweakDBID;

    if (this.GetItemData().DoesItemHaveSmartBarrel())
    {
        resultID = t"Attacks.SmartBulletLowPackage";
    }
    else
    {
        if(this.GetItemData().DoesItemHaveTechBarrel())
        {
            resultID = t"Attacks.PhysicalBulletPackage";
        }
        // else{
        //     if(this.GetItemData().DoesItemHaveAtomizerBarrel())
        //     {
        //         resultID = t"Attacks.PreemAttackFlamethrowerPackage";
        //     }
        // }
    }
    
    return resultID;
}

@addMethod(WeaponObject)
protected final func GetTriggerTypeBasedOnPreemMods() -> gamedataTriggerMode
{
    let slotID1 = t"AttachmentSlots.PreemTriggerMod01";
    let slotID2 = t"AttachmentSlots.PreemTriggerMod02";
    let slotIDsList: array<TweakDBID>;
    ArrayPush(slotIDsList,slotID1);
    ArrayPush(slotIDsList,slotID2);
    let resultTrigger: gamedataTriggerMode = gamedataTriggerMode.Invalid;

    // if(this.GetItemData().DoesItemHavePreemMod(slotIDsList,t"Items.PreemTriggerModCharge"))
    // {
    //     resultTrigger = gamedataTriggerMode.Charge;
    // }
    // else{
        if (this.GetItemData().DoesItemHavePreemMod(slotIDsList,t"Items.PreemTriggerModFullAuto"))
        {
            resultTrigger = gamedataTriggerMode.FullAuto;
        }
        else{
            if(this.GetItemData().DoesItemHavePreemMod(slotIDsList,t"Items.PreemTriggerModSemiAuto"))
            {
                resultTrigger = gamedataTriggerMode.SemiAuto;
            }
            else{
                if(this.GetItemData().DoesItemHavePreemMod(slotIDsList,t"Items.PreemTriggerModBurst"))
                {
                    resultTrigger = gamedataTriggerMode.Burst;
                }
            }
        }
    //}
    
    return resultTrigger;
}

@addMethod(WeaponObject)
protected final func GetEvolutionBasedOnPreemMods() -> gamedataWeaponEvolution
{
    let resultEvolution: gamedataWeaponEvolution;

    if (this.GetItemData().DoesItemHaveSmartBarrel())
    {
        resultEvolution = gamedataWeaponEvolution.Smart;
    }
    else{
        if (this.GetItemData().DoesItemHaveTechBarrel())
        {
            resultEvolution = gamedataWeaponEvolution.Tech;
        }
    }
    
    return resultEvolution;
}

@wrapMethod(WeaponObject)
protected cb func OnGameAttached() -> Bool
{
    wrappedMethod();
    if this.GetOwner().IsPlayer() {
        this.ChangeTriggerBasedOnPreemMods();
    }
}

@wrapMethod(WeaponTransition)
protected final func GetDesiredAttackRecord(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> ref<Attack_Record> {
    let result = wrappedMethod(stateContext,scriptInterface);
    let attackRecord: ref<Attack_Record>;
    let rangedAttack: ref<RangedAttack_Record>;
    let weaponCharge: Float;
    attackRecord = result;
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    if weaponObject.GetOwner().IsPlayer() {
        let weaponRecord: ref<WeaponItem_Record> = weaponObject.GetWeaponRecord();
        let preemAttackPackage = TweakDBInterface.GetRangedAttackPackageRecord(weaponObject.GetAttackBasedOnPreemMods());
        if IsDefined(preemAttackPackage)
        {
            this.m_rangedAttackPackage = preemAttackPackage;
            weaponCharge = WeaponObject.GetWeaponChargeNormalized(weaponObject);
            rangedAttack = weaponCharge >= 1.00 ? this.m_rangedAttackPackage.ChargeFire() : this.m_rangedAttackPackage.DefaultFire();
            if scriptInterface.GetTimeSystem().IsTimeDilationActive() && !Equals(weaponRecord.Evolution().Type(), gamedataWeaponEvolution.Tech) {
            attackRecord = rangedAttack.PlayerTimeDilated();
            } else {
            attackRecord = rangedAttack.PlayerAttack();
            };
        }
    }

    return attackRecord;
}

// @wrapMethod(ShootEvents)
// protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
//     let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
//     if(!weaponObject.IsContinuousAttackStarted())
//     {
//         wrappedMethod(stateContext,scriptInterface);
//     }
// }

// public class ReadyEvents extends WeaponEventsTransition {

//   public let m_timeStamp: Float;

//   protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
//     let weapon: wref<WeaponObject> = scriptInterface.owner as WeaponObject;
//     this.OnEnterNonChargeState(weapon, stateContext, scriptInterface);
//     this.EndShootingSequence(weapon, stateContext, scriptInterface);
//     stateContext.SetConditionWeakScriptableParameter(n"Weapon", weapon, true);
//     scriptInterface.TEMP_WeaponStopFiring();
//     if !weapon.IsMagazineEmpty() {
//       this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Default));
//     };
//     this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Ready));
//     stateContext.SetPermanentBoolParameter(n"WeaponInSafe", false, true);
//     scriptInterface.SetAnimationParameterFloat(n"safe", 0.00);
//     this.m_timeStamp = EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame()));
//     GameInstance.GetAudioSystem(scriptInterface.owner.GetGame()).RemoveTriggerEffect(n"PSM_shootBumpCycle_off");
//     this.SetTriggerEffectCycleTrigger(scriptInterface);
//   }

//   protected final func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
//     let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
//     let attackID: TweakDBID = this.GetDesiredAttackRecord(stateContext, scriptInterface).GetID();
//     if weaponObject.GetCurrentAttack().GetRecord().GetID() != attackID {
//       weaponObject.SetAttack(attackID);
//     };
//     this.ShowAttackPreview(true, weaponObject, scriptInterface, stateContext);
//     this.HandleDamagePreview(weaponObject, scriptInterface, stateContext);
//   }

//   protected final func OnTick(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
//     let animFeature: ref<AnimFeature_WeaponHandlingStats>;
//     let ownerID: EntityID;
//     let statsSystem: ref<StatsSystem>;
//     let gameInstance: GameInstance = scriptInterface.GetGame();
//     let currentTime: Float = EngineTime.ToFloat(GameInstance.GetSimTime(gameInstance));
//     let behindCover: Bool = NotEquals(GameInstance.GetSpatialQueriesSystem(gameInstance).GetPlayerObstacleSystem().GetCoverDirection(scriptInterface.executionOwner), gamePlayerCoverDirection.None);
//     if behindCover {
//       this.m_timeStamp = currentTime;
//       stateContext.SetPermanentFloatParameter(n"TurnOffPublicSafeTimeStamp", this.m_timeStamp, true);
//     };
//     if WeaponTransition.GetPlayerSpeed(scriptInterface) < 0.10 && stateContext.IsStateActive(n"Locomotion", n"stand") {
//       if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) != EnumInt(gamePSMCombat.InCombat) && !behindCover {
//         if this.m_timeStamp + this.GetStaticFloatParameterDefault("timeBetweenIdleBreaks", 20.00) <= currentTime {
//           scriptInterface.PushAnimationEvent(n"IdleBreak");
//           this.m_timeStamp = currentTime;
//         };
//       };
//     };
//     if this.IsHeavyWeaponEmpty(scriptInterface) && !stateContext.GetBoolParameter(n"requestHeavyWeaponUnequip", true) {
//       stateContext.SetPermanentBoolParameter(n"requestHeavyWeaponUnequip", true, true);
//     };
//     statsSystem = GameInstance.GetStatsSystem(gameInstance);
//     ownerID = scriptInterface.ownerEntityID;
//     animFeature = new AnimFeature_WeaponHandlingStats();
//     animFeature.weaponRecoil = statsSystem.GetStatValue(Cast<StatsObjectID>(ownerID), gamedataStatType.RecoilAnimation);
//     animFeature.weaponSpread = statsSystem.GetStatValue(Cast<StatsObjectID>(ownerID), gamedataStatType.SpreadAnimation);
//     scriptInterface.SetAnimationParameterFeature(n"WeaponHandlingData", animFeature, scriptInterface.executionOwner);
//   }

//   private final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
//     this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Default));
//     this.ActivateDamageProjection(false, this.GetWeaponObject(scriptInterface), scriptInterface, stateContext);
//   }
// }

//    protected final func GetDesiredAttackRecord(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> ref<Attack_Record> {
//     let attackRecord: ref<Attack_Record>;
//     let magazine: InnerItemData;
//     let rangedAttack: ref<RangedAttack_Record>;
//     let weaponCharge: Float;
//     let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
//     let weaponRecord: ref<WeaponItem_Record> = weaponObject.GetWeaponRecord();
//     if !IsDefined(this.m_rangedAttackPackage) {
//       this.m_rangedAttackPackage = weaponRecord.RangedAttacks();
//     };
//     weaponObject.GetItemData().GetItemPart(magazine, t"AttachmentSlots.DamageMod");
//     if this.m_magazineID != ItemID.GetTDBID(InnerItemData.GetItemID(magazine)) {
//       this.m_magazineID = ItemID.GetTDBID(InnerItemData.GetItemID(magazine));
//       if TDBID.IsValid(this.m_magazineID) {
//         this.m_magazineAttack = TDBID.Create(TweakDBInterface.GetString(this.m_magazineID + t".overrideAttack", ""));
//         this.m_rangedAttackPackage = TweakDBInterface.GetRangedAttackPackageRecord(this.m_magazineAttack);
//       } else {
//         this.m_magazineAttack = t".fireAndForget";
//       };
//     };
//     weaponCharge = WeaponObject.GetWeaponChargeNormalized(weaponObject);
//     rangedAttack = weaponCharge >= 1.00 ? this.m_rangedAttackPackage.ChargeFire() : this.m_rangedAttackPackage.DefaultFire();
//     if scriptInterface.GetTimeSystem().IsTimeDilationActive() && !Equals(weaponRecord.Evolution().Type(), gamedataWeaponEvolution.Tech) {
//       attackRecord = rangedAttack.PlayerTimeDilated();
//     } else {
//       attackRecord = rangedAttack.PlayerAttack();
//     };
//     return attackRecord;
//   }


// @wrapMethod(WeaponTransition)
// protected final const func SwitchTriggerMode(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
//     wrappedMethod(stateContext,scriptInterface);
//     let evt: ref<WeaponChangeTriggerModeEvent> = new WeaponChangeTriggerModeEvent();
//     let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
//     if NotEquals(weapon.GetTriggerTypeBasedOnPreemMods(),gamedataTriggerMode.Invalid)
//     {
//         evt.triggerMode = weapon.GetTriggerTypeBasedOnPreemMods();
//         weapon.QueueEvent(evt);
//     }
// }

@wrapMethod(WeaponTransition)
protected final const func IsPrimaryTriggerModeActive(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let result = wrappedMethod(scriptInterface);
    let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
    if(weapon.GetOwner().IsPlayer())
    {
        if Equals(weapon.GetCurrentTriggerMode().Type(),weapon.GetTriggerTypeBasedOnPreemMods()) {
            return true;
        };
    }

    return result;
}

// public class ShootDecisions extends WeaponTransition {

//   public const let stateBodyDone: Bool;

//   protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
//     return this.stateBodyDone;
//   }
// }

// public class ShootEvents extends WeaponEventsTransition {

//   protected final func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
//     let attackID: TweakDBID;
//     let broadcaster: ref<StimBroadcasterComponent>;
//     let gameInstance: GameInstance = scriptInterface.GetGame();
//     let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gameInstance);
//     let currentTime: Float = EngineTime.ToFloat(GameInstance.GetSimTime(gameInstance));
//     let weapon: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
//     this.ForceDisableVisionMode(stateContext);
//     this.ShowAttackPreview(true, weapon, scriptInterface, stateContext);
//     if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponShootWhileSprinting) && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion) == EnumInt(gamePSMLocomotionStates.Sprint) {
//       stateContext.SetTemporaryBoolParameter(n"InterruptSprint", true, true);
//     };
//     stateContext.SetPermanentFloatParameter(n"LastShotTime", currentTime, true);
//     attackID = this.GetDesiredAttackRecord(stateContext, scriptInterface).GetID();
//     weapon.SetAttack(attackID);
//     weapon.QueueEvent(new WeaponPreFireEvent());
//     stateContext.SetPermanentIntParameter(n"LastChargePressCount", Cast<Int32>(scriptInterface.GetActionPressCount(n"RangedAttack")), true);
//     stateContext.SetPermanentFloatParameter(n"TurnOffPublicSafeTimeStamp", currentTime, true);
//     stateContext.SetPermanentBoolParameter(n"WeaponInSafe", false, true);
//     scriptInterface.PushAnimationEvent(n"Shoot");
//     stateContext.SetPermanentFloatParameter(n"StoppedFiringTimestamp", currentTime, true);
//     this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Weapon, EnumInt(gamePSMRangedWeaponStates.Shoot));
//     broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
//     if statsSystem.GetStatValue(Cast<StatsObjectID>(weapon.GetEntityID()), gamedataStatType.CanSilentKill) > 0.00 {
//       if IsDefined(broadcaster) {
//         broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.IllegalAction);
//         broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.SilencedGunshot);
//         broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.SilencedGunshot, 8.00, true);
//         if Equals(WeaponObject.GetWeaponType(weapon.GetItemID()), gamedataItemType.Wea_SniperRifle) {
//           broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.Gunshot, 8.00);
//         };
//       };
//       WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.SilencedShoot);
//       WeaponObject.SendAmmoUpdateEvent(scriptInterface.executionOwner, weapon);
//     } else {
//       if statsSystem.GetStatValue(Cast<StatsObjectID>(weapon.GetEntityID()), gamedataStatType.HasMuzzleBrake) > 0.00 {
//         WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.MuzzleBrakeShoot);
//         WeaponObject.SendAmmoUpdateEvent(scriptInterface.executionOwner, weapon);
//       } else {
//         WeaponObject.TriggerWeaponEffects(weapon, gamedataFxAction.Shoot);
//         WeaponObject.SendAmmoUpdateEvent(scriptInterface.executionOwner, weapon);
//       };
//       if IsDefined(broadcaster) {
//         if IsEntityInInteriorArea(GetPlayer(gameInstance)) {
//           broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.Gunshot, 25.00);
//           broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.Gunshot, 45.00, true);
//         } else {
//           broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.Gunshot, GetPlayer(gameInstance).GetGunshotRange());
//           broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.Gunshot, 50.00, true);
//         };
//       };
//       PlayerCoverHelper.BlockCoverVisibilityReduction(scriptInterface.executionOwner);
//     };
//     this.SendDataTrackingRequest(scriptInterface, ETelemetryData.RangedAttacksMade, 1);
//     this.ChangeStatPoolValue(scriptInterface, scriptInterface.ownerEntityID, gamedataStatPoolType.WeaponOverheat, this.GetStaticFloatParameterDefault("overheatValAdd", 10.00));
//     this.ShootingSequencePostShoot(stateContext);
//     GameInstance.GetTelemetrySystem(scriptInterface.owner.GetGame()).LogWeaponAttackPerformed(weapon);
//     if scriptInterface.IsTriggerModeActive(gamedataTriggerMode.FullAuto) || scriptInterface.IsTriggerModeActive(gamedataTriggerMode.Burst) {
//       GameInstance.GetAudioSystem(scriptInterface.owner.GetGame()).SetTriggerEffectModeTimed(n"te_wea_shoot_bump_auto", 0.20);
//     } else {
//       GameInstance.GetAudioSystem(scriptInterface.owner.GetGame()).AddTriggerEffect(n"te_off", n"PSM_shootBumpCycle_off");
//       GameInstance.GetAudioSystem(scriptInterface.owner.GetGame()).SetTriggerEffectModeTimed(n"te_wea_shoot_bump_single", 0.20);
//     };
//   }

//   protected final func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
//     let statPoolsSystem: ref<StatPoolsSystem> = scriptInterface.GetStatPoolsSystem();
//     let statsSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
//     let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
//     if statsSystem.GetStatValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatType.FullAutoOnFullCharge) == 0.00 {
//       statPoolsSystem.RequestSettingStatPoolMinValue(Cast<StatsObjectID>(weaponObject.GetEntityID()), gamedataStatPoolType.WeaponCharge, scriptInterface.executionOwner);
//     };
//   }
// }