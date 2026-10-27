module PreemCrafting.CraftingSystem.PreemCraftingSystem
import PreemCrafting.CraftingSystem.ModInstaller.*
import PreemCrafting.CraftingSystem.PreemModUnlocker.*
import PreemCrafting.Core.*
import PreemCrafting.CraftingSystem.PreemModMaker.*

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

  // The slot each chosen mod goes in (2.2.5 order): per slot class the mods fill slot 01, then 02;
  // the Silencer goes to the muzzle slot (PowerModule) but still uses up a barrel slot. A third
  // mod of one class has no slot and is left out. Pure, so RedTest can call it.
  public final static func PlanModSlots(mods: array<ref<PreemMod>>) -> array<ref<PreemModPlacement>> {
    let plan: array<ref<PreemModPlacement>>;
    let mapper = new PreemModMapper();
    let barrelCount = 0;
    let triggerCount = 0;
    let magCount = 0;
    let bladeCount = 0;
    let handleCount = 0;
    for mod in mods {
      let slotList = mapper.GetGameModSlotListFromPreemMod(mod);
      let index = 0;
      switch mod.preemClassType {
        case PreemModClassType.Barrel:    index = barrelCount;    barrelCount += 1;
            break;
        case PreemModClassType.Trigger:   index = triggerCount;   triggerCount += 1;
            break;
        case PreemModClassType.Mag:       index = magCount;       magCount += 1;
            break;
        case PreemModClassType.Blade:     index = bladeCount;     bladeCount += 1;
            break;
        case PreemModClassType.Handle:    index = handleCount;    handleCount += 1;
            break;
      }
      if index < ArraySize(slotList) {
        let slotID = slotList[index];
        if Equals(mod.modStyleType, PreemModStyleType.Barrel_Silencer) {
          slotID = t"AttachmentSlots.PowerModule";
        }
        ArrayPush(plan, PreemModPlacement.Create(slotID, mod));
      }
    }
    return plan;
  }

  // What ApplyMods changes on an item that already holds Preem mods (SPEC §2.1): a wanted mod
  // already in its slot stays, any other wanted mod is installed (over whatever Preem mod is in
  // that slot: the game deletes a replaced weapon mod), and a slot whose Preem mod is no longer
  // wanted is emptied. For a new item (nothing installed) that is every wanted mod. Pure.
  public final static func PlanModChanges(wanted: array<ref<PreemModPlacement>>, installed: array<ref<PreemModPlacement>>, out installs: array<ref<PreemModPlacement>>, out removals: array<TweakDBID>) -> Void {
    for want in wanted {
      let same = false;
      for have in installed {
        if have.slotID == want.slotID && Equals(have.mod.modStyleType, want.mod.modStyleType) {
          same = true;
        }
      }
      if !same {
        ArrayPush(installs, want);
      }
    }
    for have in installed {
      let kept = false;
      for want in wanted {
        if want.slotID == have.slotID {
          kept = true;
        }
      }
      if !kept {
        ArrayPush(removals, have.slotID);
      }
    }
  }

  // The Preem mods installed on an item, read back from its Preem slots and the muzzle slot (only
  // parts that are Preem mod records count; a vanilla muzzle is not one).
  public final static func GetInstalledMods(itemData: ref<gameItemData>) -> array<ref<PreemModPlacement>> {
    let installed: array<ref<PreemModPlacement>>;
    if !IsDefined(itemData) {
      return installed;
    }
    let mapper = new PreemModMapper();
    let classes: array<PreemModClassType> = [PreemModClassType.Barrel, PreemModClassType.Trigger, PreemModClassType.Mag, PreemModClassType.Blade, PreemModClassType.Handle];
    let mods: array<ref<PreemMod>>;
    for classType in classes {
      for mod in PreemModMaker.GetModsFromClassType(classType) {
        ArrayPush(mods, mod);
      }
    }
    for slotID in PreemCraftingSystem.GetPreemModSlots() {
      if itemData.HasPartInSlot(slotID) {
        let part: InnerItemData;
        itemData.GetItemPart(part, slotID);
        let partRecord = ItemID.GetTDBID(InnerItemData.GetItemID(part));
        for mod in mods {
          if ItemID.GetTDBID(mapper.GetGameModFromPreemMod(mod)) == partRecord {
            ArrayPush(installed, PreemModPlacement.Create(slotID, mod));
            break;
          }
        }
      }
    }
    return installed;
  }

  // Whether a mod can be chosen for a weapon the player already owns (upgrade screen, SPEC §2.1).
  // Evolution barrels are refused: they need a new item from another record (GetCraftRecord).
  public final static func IsModAllowedOnOwnedWeapon(style: PreemModStyleType) -> Bool {
    return !Equals(style, PreemModStyleType.Barrel_Smart) && !Equals(style, PreemModStyleType.Barrel_Tech) && !Equals(style, PreemModStyleType.Barrel_Power);
  }

  // Every slot a Preem mod can sit in, in slot-class order.
  public final static func GetPreemModSlots() -> array<TweakDBID> {
    return [
      t"AttachmentSlots.PreemBarrelMod01", t"AttachmentSlots.PreemBarrelMod02", t"AttachmentSlots.PowerModule",
      t"AttachmentSlots.PreemTriggerMod01", t"AttachmentSlots.PreemTriggerMod02",
      t"AttachmentSlots.PreemMagazineMod01", t"AttachmentSlots.PreemMagazineMod02",
      t"AttachmentSlots.PreemBladeMod01", t"AttachmentSlots.PreemBladeMod02",
      t"AttachmentSlots.PreemHandleMod01", t"AttachmentSlots.PreemHandleMod02"
    ];
  }

  // Installs the chosen mods on an item, new (crafting) or owned (upgrade screen): mods already in
  // place stay, changed ones are installed, Preem mods no longer chosen are removed and deleted.
  public func ApplyMods(gi: GameInstance, itemToApplyTo: ref<gameItemData>) -> Bool {
    let craftingSystem: ref<CraftingSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"CraftingSystem") as CraftingSystem;
    let installs: array<ref<PreemModPlacement>>;
    let removals: array<TweakDBID>;
    PreemCraftingSystem.PlanModChanges(PreemCraftingSystem.PlanModSlots(this._currentSelectedMods), PreemCraftingSystem.GetInstalledMods(itemToApplyTo), installs, removals);
    for slotID in removals {
      craftingSystem.RemovePreemMod(itemToApplyTo, slotID);
    }
    for placement in installs {
      craftingSystem.InstallPreemMod(placement.mod, itemToApplyTo, this._modInstaller, placement.slotID);
    }
    return true;
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
// A Preem mod in an attachment slot of a weapon: planned by ApplyMods, or read back from an item.
public class PreemModPlacement {
  public let slotID: TweakDBID;
  public let mod: ref<PreemMod>;

  public static func Create(slotID: TweakDBID, mod: ref<PreemMod>) -> ref<PreemModPlacement> {
    let placement = new PreemModPlacement();
    placement.slotID = slotID;
    placement.mod = mod;
    return placement;
  }
}
