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
    let result = wrappedMethod();
    this.ChangeTriggerBasedOnPreemMods();
    return result;
}

@wrapMethod(WeaponTransition)
protected final func GetDesiredAttackRecord(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> ref<Attack_Record> {
    let result = wrappedMethod(stateContext,scriptInterface);
    let attackRecord: ref<Attack_Record>;
    let rangedAttack: ref<RangedAttack_Record>;
    let weaponCharge: Float;
    let weaponObject: ref<WeaponObject> = this.GetWeaponObject(scriptInterface);
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
    else{
        attackRecord = result;
    }

    return attackRecord;
  }

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
    if Equals(weapon.GetCurrentTriggerMode().Type(),weapon.GetTriggerTypeBasedOnPreemMods()) {
        return true;
    };

    return result;
}

// @wrapMethod(WeaponObject)
// private final func RegisterStatPoolListeners() -> Void {
//     wrappedMethod();
//     LogChannel(n"DEBUG", s"WeaponObject:: Registering Statpools");
// }

// @wrapMethod(WeaponObject)
//   protected cb func OnWeaponRegisterChargeStatListener(evt: ref<WeaponRegisterChargeStatListener>) -> Bool {
//     LogChannel(n"DEBUG", s"WeaponObject:: Registered StatPools");
//     return wrappedMethod(evt);
//   }

// @wrapMethod(WeaponObject)
//   public final static func RegisterChargeStatListener(weapon: wref<WeaponObject>, register: Bool) -> Void {
//     LogChannel(n"DEBUG", s"WeaponObject:: Registering ChargeStatListener");
//     wrappedMethod(weapon,register);
//   }


// @wrapMethod(WeaponObject)
//   private final func RegisterChargeStatListener() -> Void {
//     LogChannel(n"DEBUG", s"WeaponObject:: Registering ChargeStatListener2");
//     wrappedMethod();
//   }