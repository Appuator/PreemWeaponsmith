module PreemCrafting.CraftingSystem.PreemCraftingSystem
import PreemCrafting.CraftingSystem.ModInstaller.*
import PreemCrafting.CraftingSystem.PreemModUnlocker.*
import PreemCrafting.Core.*

public class PreemCraftingSystem extends ScriptableSystem {

  //private let _inventoryManager: ref<InventoryDataManagerV2>;
  private let _player: wref<PlayerPuppet>;
  private let _currentSelectedMods: array<ref<PreemMod>>;
  private let _modInstaller: ref<PreemModMapper>;
  private let _modUnlocker: ref<PreemModUnlocker>;
  private let _currentEvolution: gamedataWeaponEvolution = gamedataWeaponEvolution.Invalid;
  private let _currentWeaponRarity: gamedataQuality = gamedataQuality.Invalid;


  private func OnAttach() -> Void {
    //LogChannel(n"DEBUG", "PreemCraftingSystem::OnAttach");
    this._modInstaller = new PreemModMapper();
    this._modUnlocker = new PreemModUnlocker();
  }

  private func OnDetach() -> Void {
    //LogChannel(n"DEBUG", "PreemCraftingSystem::OnDetach");
    this._modInstaller = null;
    this._modUnlocker = null;
    this._player = null;
  }

  public final static func GetInstance(gameInstance: GameInstance) -> ref<PreemCraftingSystem> {
    let craftSystem: ref<PreemCraftingSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"PreemCrafting.CraftingSystem.PreemCraftingSystem.PreemCraftingSystem") as PreemCraftingSystem;
    return craftSystem;
  }

  public final static func GetRangedWeaponsItemsTypeList() -> array<gamedataItemType>
  {
    //Wea_AssaultRifle = 54,
    //Wea_Axe = 55,
    //Wea_Chainsword = 56,
    //Wea_Fists = 57,
    //Wea_Hammer = 58,
    //Wea_Handgun = 59,
    //Wea_HeavyMachineGun = 60,
    //Wea_Katana = 61,
    //Wea_Knife = 62,
    //Wea_LightMachineGun = 63,
    //Wea_LongBlade = 64,
    //Wea_Machete = 65,
    //Wea_Melee = 66,
    //Wea_OneHandedClub = 67,
    //Wea_PrecisionRifle = 68,
    //Wea_Revolver = 69,
    //Wea_Rifle = 70,
    //Wea_ShortBlade = 71,
    //Wea_Shotgun = 72,
    //Wea_ShotgunDual = 73,
    //Wea_SniperRifle = 74,
    //Wea_SubmachineGun = 75,
    //Wea_TwoHandedClub
    let rangedWeaponItemTypeList: array<gamedataItemType>;

    ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_AssaultRifle);
    ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_Handgun);
    ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_HeavyMachineGun);
    ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_LightMachineGun);
    ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_PrecisionRifle);
    ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_Revolver);
    ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_Rifle);
    ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_Shotgun);
    ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_ShotgunDual);
    ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_SniperRifle);
    ArrayPush(rangedWeaponItemTypeList, gamedataItemType.Wea_SubmachineGun);

    return rangedWeaponItemTypeList;
  }

  public final static func GetMeleeWeaponsItemsTypeList() -> array<gamedataItemType>
  {

    //Wea_AssaultRifle = 54,
    //Wea_Axe = 55,
    //Wea_Chainsword = 56,
    //Wea_Fists = 57,
    //Wea_Hammer = 58,
    //Wea_Handgun = 59,
    //Wea_HeavyMachineGun = 60,
    //Wea_Katana = 61,
    //Wea_Knife = 62,
    //Wea_LightMachineGun = 63,
    //Wea_LongBlade = 64,
    //Wea_Machete = 65,
    //Wea_Melee = 66,
    //Wea_OneHandedClub = 67,
    //Wea_PrecisionRifle = 68,
    //Wea_Revolver = 69,
    //Wea_Rifle = 70,
    //Wea_ShortBlade = 71,
    //Wea_Shotgun = 72,
    //Wea_ShotgunDual = 73,
    //Wea_SniperRifle = 74,
    //Wea_SubmachineGun = 75,
    //Wea_TwoHandedClub
    let meleeWeaponItemTypeList: array<gamedataItemType>;

    ArrayPush(meleeWeaponItemTypeList, gamedataItemType.Wea_Axe);
    ArrayPush(meleeWeaponItemTypeList, gamedataItemType.Wea_Knife);
    ArrayPush(meleeWeaponItemTypeList, gamedataItemType.Wea_Chainsword);
    ArrayPush(meleeWeaponItemTypeList, gamedataItemType.Wea_Fists);
    ArrayPush(meleeWeaponItemTypeList, gamedataItemType.Wea_Hammer);
    ArrayPush(meleeWeaponItemTypeList, gamedataItemType.Wea_Katana);
    ArrayPush(meleeWeaponItemTypeList, gamedataItemType.Wea_LongBlade);
    ArrayPush(meleeWeaponItemTypeList, gamedataItemType.Wea_Machete);
    ArrayPush(meleeWeaponItemTypeList, gamedataItemType.Wea_Melee);
    ArrayPush(meleeWeaponItemTypeList, gamedataItemType.Wea_OneHandedClub);
    ArrayPush(meleeWeaponItemTypeList, gamedataItemType.Wea_ShortBlade);
    ArrayPush(meleeWeaponItemTypeList, gamedataItemType.Wea_TwoHandedClub);

    return meleeWeaponItemTypeList;
  }

  // The record CraftItem crafts. An evolution barrel (Smart, then Tech, then Power) on a weapon of
  // another evolution swaps to that weapon's <id>_Preem<Evolution> variant (PreemWeaponAlteration).
  public final static func GetCraftRecord(itemRecord: ref<Item_Record>, modTypes: array<PreemModStyleType>) -> ref<Item_Record> {
    let evolution: gamedataWeaponEvolution;
    let suffix: TweakDBID;
    if ArrayContains(modTypes, PreemModStyleType.Barrel_Smart) {
      evolution = gamedataWeaponEvolution.Smart;
      suffix = t"_PreemSmart";
    } else {
      if ArrayContains(modTypes, PreemModStyleType.Barrel_Tech) {
        evolution = gamedataWeaponEvolution.Tech;
        suffix = t"_PreemTech";
      } else {
        if ArrayContains(modTypes, PreemModStyleType.Barrel_Power) {
          evolution = gamedataWeaponEvolution.Power;
          suffix = t"_PreemPower";
        } else {
          return itemRecord;
        }
      }
    }
    let weaponRecord = itemRecord as WeaponItem_Record;
    if IsDefined(weaponRecord.Evolution()) && Equals(weaponRecord.Evolution().Type(), evolution) {
      return itemRecord;
    }
    // Only weapons whose own evolution is Smart, Tech or Power get variants; craft the others as they are.
    let variant = TweakDBInterface.GetItemRecord(itemRecord.GetID() + suffix);
    return IsDefined(variant) ? variant : itemRecord;
  }

  public func AddMod(preemMod: ref<PreemMod>) -> Void {
    ArrayPush(this._currentSelectedMods,preemMod);
    //LogChannel(n"DEBUG", "PreemCraftingSystem::Mod Added");
  }

  public func ClearMods() -> Void {
    ArrayClear(this._currentSelectedMods);
    //LogChannel(n"DEBUG", "PreemCraftingSystem::Mods Cleared");
  }

  public func GetModList(out modList: array<ref<PreemMod>>) -> Void
  {
    for currMod in this._currentSelectedMods
    {
      ArrayPush(modList,currMod);
    }
  }

  public func SetModList(modList: array<ref<PreemMod>>)
  {
    this.ClearMods();
    for currMod in modList
    {
      ArrayPush(this._currentSelectedMods,currMod);
    }
    //LogChannel(n"DEBUG", "PreemCraftingSystem::Mods Set");
  }

  public func SetCurrentWeaponEvo(currEvo: gamedataWeaponEvolution)
  {
    this._currentEvolution = currEvo;
  }

  public func SetCurrentWeaponRarity(currRarity: gamedataQuality)
  {
    this._currentWeaponRarity = currRarity;
    this._modUnlocker.SetWeaponQuality(currRarity);
  }

  public func ApplyMods(gi: GameInstance, itemToApplyTo: ref<gameItemData>) -> Bool {
    let applyModsResult: Bool = true;
    let currMod: ref<PreemMod>;
    let limit: Int32 = ArraySize(this._currentSelectedMods);
    let i: Int32 = 0;
    let barrelCount = 0;
    let triggerCount = 0;
    let magCount = 0;
    let bladeCount = 0;
    let handleCount = 0;
    let preemModClass: PreemModClassType;
    let craftingSystem: ref<CraftingSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"CraftingSystem") as CraftingSystem;

    //LogChannel(n"DEBUG", s"PreemCraftingSystem:: \(ArraySize(this._currentSelectedMods))");

    while i < limit {
      currMod = this._currentSelectedMods[i];
      preemModClass = currMod.preemClassType;

      let slotID = this._modInstaller.GetGameModSlotFromPreemMod(currMod);
      let slotList = this._modInstaller.GetGameModSlotListFromPreemMod(currMod);
      switch preemModClass
      {
        case PreemModClassType.Barrel:    slotID = slotList[barrelCount];
            break;
        case PreemModClassType.Trigger:   slotID = slotList[triggerCount];
            break;
        case PreemModClassType.Mag:    slotID = slotList[magCount];
            break;
        case PreemModClassType.Blade:    slotID = slotList[bladeCount];
            break;
        case PreemModClassType.Handle:    slotID = slotList[handleCount];
            break;
      }

      if(Equals(currMod.modStyleType,PreemModStyleType.Barrel_Silencer)){
        slotID = t"AttachmentSlots.PowerModule";
        //slotID = t"AttachmentSlots.PowerModule2";
      }

      craftingSystem.InstallPreemMod(currMod, itemToApplyTo, this._modInstaller, slotID);

      switch preemModClass
      {
        case PreemModClassType.Barrel:    barrelCount += 1;
            break;
        case PreemModClassType.Trigger:    triggerCount += 1;
            break;
        case PreemModClassType.Mag:    magCount += 1;
            break;
        case PreemModClassType.Blade:    bladeCount += 1;
            break;
        case PreemModClassType.Handle:    handleCount += 1;
            break;
      }

      i += 1;
    };
    //LogChannel(n"DEBUG", "PreemCraftingSystem::Mods Applied");
    return applyModsResult;
  }

  // Required mods (met by a chosen mod, or by the weapon already having the required evolution)
  // and incompatible styles. Pure, so RedTest can call it.
  public final static func AreModsCompatible(mods: array<ref<PreemMod>>, weaponEvolution: gamedataWeaponEvolution) -> Bool
  {
    for preemMod in mods
    {
        let isRequiredEvo = false;
        if (NotEquals(weaponEvolution,gamedataWeaponEvolution.Invalid)
                  && NotEquals(preemMod.GetRequiredEvolution(),gamedataWeaponEvolution.Invalid))
        {
          isRequiredEvo = Equals(weaponEvolution, preemMod.GetRequiredEvolution());
        }

        //LogChannel(n"DEBUG", s"PreemCraftingSystem:: \(preemMod.GetRequiredMods())");
        for mod in preemMod.GetRequiredMods()
        {
            let isRequiredInstalled = false;

            for currModType in PreemMod.GetModTypes(mods)
            {
              if(Equals(currModType,mod) || isRequiredEvo)
              {
                isRequiredInstalled = true;
              }
            }
            if(!isRequiredInstalled){
              return false;
            }
        }
    }

    for preemMod in mods
    {
        //LogChannel(n"DEBUG", s"PreemCraftingSystem:: \(preemMod.GetIncompatMods())");
        for mod in preemMod.GetIncompatMods()
        {
            for currModType in PreemMod.GetModTypes(mods)
            {
              if(Equals(currModType,mod))
              {
                return false;
              }
            }
        }
    }

    return true;
  }

  public func CanInstallSelectedPreemMods() -> Bool
  {
    let canInstall: Bool = true;

    if !PreemCraftingSystem.AreModsCompatible(this._currentSelectedMods, this._currentEvolution)
    {
      return false;
    }

    let settings = PreemSettings.GetInstance(this.GetGameInstance());
    this._modUnlocker.SetModes(settings.GetUnlockMode(), settings.GetLimitMode());
    this._modUnlocker.SetDevSystem(this._player);
    this._modUnlocker.SetWeaponQuality(this._currentWeaponRarity);
    if(ArraySize(this._currentSelectedMods) > this._modUnlocker.DetermineAmountOfModsAllowed(this._player))
    {
      return false;
    }

    //LogChannel(n"DEBUG", s"PreemCraftingSystem can install:: \(canInstall)");
    return canInstall;
  }

  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(request.owner.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    if IsDefined(player) {
      this._player = player;
    };
  }

}