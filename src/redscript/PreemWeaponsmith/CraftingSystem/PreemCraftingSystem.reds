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
  // Mods chosen on the Upgrades tab for an item being upgraded; CraftingSystem.UpgradeItem applies
  // them once the upgrade is done (PreemCraftingSystemAdapter).
  private let _upgradeItem: ItemID;
  private let _upgradeMods: array<ref<PreemMod>>;
  // The mods last applied to an owned item: their installs are queued, so a screen refreshing
  // right after the apply shows these rather than the item's slots (GetShownMods).
  private let _lastAppliedItem: ItemID;
  private let _lastAppliedMods: array<ref<PreemMod>>;


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

  // The slot each chosen mod goes in (2.2.5 order): per slot class the mods fill slot 01, then 02.
  // The Silencer is a barrel mod like the others (ADR 0002; PlanMuzzlePart adds the hidden muzzle
  // part). A third mod of one class has no slot and is left out. Pure, so RedTest can call it.
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
        ArrayPush(plan, PreemModPlacement.Create(slotList[index], mod));
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

  // The muzzle slot while a Silencer is wanted (ADR 0002 and its addendum): the game plays a
  // weapon's silenced sound set only while the part in the muzzle slot (AttachmentSlots.PowerModule)
  // has the Silenced tag. Returns the record that slot should hold (TDBID.None(): empty).
  // muzzlePart is the record there now (TDBID.None() when empty); silencedPart, whether it has the
  // Silenced tag. With a Silencer: a muzzle brake becomes its Silenced twin, a vanilla silencer
  // stays, anything else (empty, the 2.4.x Silencer, another part) gives way to the hidden part.
  // Without one: the hidden part comes off, a twin goes back to its brake, vanilla parts stay. Pure.
  public final static func PlanMuzzlePart(wanted: array<ref<PreemModPlacement>>, muzzlePart: TweakDBID, silencedPart: Bool) -> TweakDBID {
    let silencer = false;
    for want in wanted {
      if Equals(want.mod.modStyleType, PreemModStyleType.Barrel_Silencer) {
        silencer = true;
      }
    }
    let hidden = PreemMuzzleParts.HiddenPart();
    let brake = PreemMuzzleParts.BrakeOf(muzzlePart);
    if !silencer {
      if muzzlePart == hidden {
        return TDBID.None();
      }
      return TDBID.IsValid(brake) ? brake : muzzlePart;
    }
    if muzzlePart == hidden || TDBID.IsValid(brake) {
      return muzzlePart;
    }
    let twin = PreemMuzzleParts.TwinOf(muzzlePart);
    if TDBID.IsValid(twin) {
      return twin;
    }
    if silencedPart && muzzlePart != PreemMuzzleParts.OldSilencer() {
      return muzzlePart;
    }
    return hidden;
  }

  // The record of the part in an item's muzzle slot, TDBID.None() when it has none.
  public final static func GetMuzzlePart(itemData: ref<gameItemData>) -> TweakDBID {
    if !IsDefined(itemData) || !itemData.HasPartInSlot(t"AttachmentSlots.PowerModule") {
      return TDBID.None();
    }
    let part: InnerItemData;
    itemData.GetItemPart(part, t"AttachmentSlots.PowerModule");
    return ItemID.GetTDBID(InnerItemData.GetItemID(part));
  }

  // The Preem mods installed on an item, read back from its Preem slots and the muzzle slot (only
  // parts that are Preem mod records count; a vanilla muzzle or the hidden muzzle part is not one).
  // The muzzle slot holds a Preem mod only on weapons from 2.4.x (the old Silencer); ApplyMods
  // moves it to a barrel slot.
  public final static func GetInstalledMods(itemData: ref<gameItemData>) -> array<ref<PreemModPlacement>> {
    let installed: array<ref<PreemModPlacement>>;
    if !IsDefined(itemData) {
      return installed;
    }
    for slotID in PreemCraftingSystem.GetPreemModSlots() {
      if itemData.HasPartInSlot(slotID) {
        let part: InnerItemData;
        itemData.GetItemPart(part, slotID);
        let mod = PreemCraftingSystem.GetModForPartRecord(ItemID.GetTDBID(InnerItemData.GetItemID(part)));
        if IsDefined(mod) {
          ArrayPush(installed, PreemModPlacement.Create(slotID, mod));
        }
      }
    }
    return installed;
  }

  // The catalogue mod (core's or an add-on's) whose item is this part record, or null if the part
  // isn't a Preem mod. GetInstalledMods' per-slot step, apart so RedTest can call it at the main menu.
  public final static func GetModForPartRecord(partRecord: TweakDBID) -> ref<PreemMod> {
    let mapper = new PreemModMapper();
    let classes: array<PreemModClassType> = [PreemModClassType.Barrel, PreemModClassType.Trigger, PreemModClassType.Mag, PreemModClassType.Blade, PreemModClassType.Handle];
    for classType in classes {
      for mod in PreemModMaker.GetModsFromClassType(classType) {
        if ItemID.GetTDBID(mapper.GetGameModFromPreemMod(mod)) == partRecord {
          return mod;
        }
      }
    }
    return null;
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
    return this.ApplyModList(gi, itemToApplyTo, this._currentSelectedMods);
  }

  // Remembers the mods to put on an item once its upgrade is done (the Upgrades tab's hold).
  public func SetUpgradeMods(itemID: ItemID, mods: array<ref<PreemMod>>) -> Void {
    this._upgradeItem = itemID;
    this._upgradeMods = mods;
  }

  // Called after CraftingSystem.UpgradeItem: applies the remembered mods if they are for this item.
  public func ApplyUpgradeMods(gi: GameInstance, itemData: ref<gameItemData>) -> Void {
    if !IsDefined(itemData) || itemData.GetID() != this._upgradeItem {
      return;
    }
    this.ApplyModList(gi, itemData, this._upgradeMods);
    this._upgradeItem = ItemID.None();
    ArrayClear(this._upgradeMods);
  }

  // Whether a weapon of this evolution and rarity can take these mods together: compatibility and
  // required evolution (AreModsCompatible) and the mod limit for the rarity (limit setting).
  public func CanInstallMods(mods: array<ref<PreemMod>>, evolution: gamedataWeaponEvolution, rarity: gamedataQuality) -> Bool {
    if !PreemCraftingSystem.AreModsCompatible(mods, evolution) {
      return false;
    }
    let settings = PreemSettings.GetInstance(this.GetGameInstance());
    this._modUnlocker.SetModes(settings.GetUnlockMode(), settings.GetLimitMode());
    this._modUnlocker.SetDevSystem(this._player);
    this._modUnlocker.SetWeaponQuality(rarity);
    return ArraySize(mods) <= this._modUnlocker.DetermineAmountOfModsAllowed(this._player);
  }

  // The Preem mods to show for an owned item: the last applied set while its installs may still be
  // queued, else what its slots hold.
  public func GetShownMods(itemData: ref<gameItemData>) -> array<ref<PreemModPlacement>> {
    if IsDefined(itemData) && itemData.GetID() == this._lastAppliedItem {
      return PreemCraftingSystem.PlanModSlots(this._lastAppliedMods);
    }
    return PreemCraftingSystem.GetInstalledMods(itemData);
  }

  // Called when the crafting screen opens: by then every queued install has finished.
  public func ForgetLastApplied() -> Void {
    this._lastAppliedItem = ItemID.None();
    ArrayClear(this._lastAppliedMods);
    PreemMuzzleParts.TakeBackStray(this._player);
  }

  public func ApplyModList(gi: GameInstance, itemToApplyTo: ref<gameItemData>, mods: array<ref<PreemMod>>) -> Bool {
    if IsDefined(itemToApplyTo) {
      this._lastAppliedItem = itemToApplyTo.GetID();
      this._lastAppliedMods = mods;
    }
    let craftingSystem: ref<CraftingSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"CraftingSystem") as CraftingSystem;
    let installs: array<ref<PreemModPlacement>>;
    let removals: array<TweakDBID>;
    let wanted = PreemCraftingSystem.PlanModSlots(mods);
    PreemCraftingSystem.PlanModChanges(wanted, PreemCraftingSystem.GetInstalledMods(itemToApplyTo), installs, removals);
    let muzzle = PreemCraftingSystem.GetMuzzlePart(itemToApplyTo);
    let muzzleTarget = PreemCraftingSystem.PlanMuzzlePart(wanted, muzzle, PreemMuzzleParts.HasSilencedTag(muzzle));
    for slotID in removals {
      craftingSystem.RemovePreemMod(itemToApplyTo, slotID);
    }
    // The hidden part, a twin, or a brake becoming its twin is deleted here; another vanilla part
    // the hidden part replaces goes back to the inventory when the install replaces it.
    let muzzleOff = muzzle == PreemMuzzleParts.HiddenPart() || TDBID.IsValid(PreemMuzzleParts.BrakeOf(muzzle)) || TDBID.IsValid(PreemMuzzleParts.TwinOf(muzzle));
    if muzzleTarget != muzzle && muzzleOff {
      craftingSystem.RemovePreemMod(itemToApplyTo, t"AttachmentSlots.PowerModule");
    }
    for placement in installs {
      // A mod being replaced is removed (and deleted) first: replaced in place on the weapon in
      // hand while the muzzle part also came off, the game gave the old one back.
      craftingSystem.RemovePreemMod(itemToApplyTo, placement.slotID);
      craftingSystem.InstallPreemMod(placement.mod, itemToApplyTo, this._modInstaller, placement.slotID);
    }
    if muzzleTarget != muzzle && TDBID.IsValid(muzzleTarget) {
      craftingSystem.InstallPreemPart(ItemID.FromTDBID(muzzleTarget), itemToApplyTo, t"AttachmentSlots.PowerModule");
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
    return this.CanInstallMods(this._currentSelectedMods, this._currentEvolution, this._currentWeaponRarity);
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

// The muzzle-slot parts the Silencer uses (ADR 0002 and its addendum): the hidden muzzle part and
// one Silenced twin per player muzzle brake (records in tweaks/barrels.yaml; keep both lists the
// same, the self-check compares them with the game's brakes). They never stay in the inventory.
public abstract class PreemMuzzleParts {
  public final static func HiddenPart() -> TweakDBID {
    return t"Items.PreemSilencerMuzzle";
  }

  // The 2.4.x Silencer record, which sat in the muzzle slot until ADR 0002.
  public final static func OldSilencer() -> TweakDBID {
    return t"Items.PreemBarrelModSilencer";
  }

  public final static func BrakeNames() -> array<String> {
    return [
      "w_muzzle_brake_01", "w_muzzle_brake_01_Craftable", "w_muzzle_brake_01_legendary", "w_muzzle_brake_02",
      "w_muzzle_brake_03", "w_muzzle_brake_03_legendary", "w_muzzle_brake_05", "w_muzzle_brake_06",
      "w_muzzle_brake_07", "w_muzzle_brake_08", "w_muzzle_brake_09", "w_muzzle_brake_09_Craftable",
      "w_muzzle_brake_09_legendary", "w_muzzle_brake_10", "w_muzzle_brake_10_legendary", "w_muzzle_brake_11"
    ];
  }

  // The twin of a muzzle brake record, TDBID.None() when it isn't one of the brakes.
  public final static func TwinOf(brake: TweakDBID) -> TweakDBID {
    for name in PreemMuzzleParts.BrakeNames() {
      if TDBID.Create("Items." + name) == brake {
        return TDBID.Create("Items.PreemSilenced_" + name);
      }
    }
    return TDBID.None();
  }

  // The muzzle brake a twin record stands for, TDBID.None() when it isn't a twin.
  public final static func BrakeOf(twin: TweakDBID) -> TweakDBID {
    for name in PreemMuzzleParts.BrakeNames() {
      if TDBID.Create("Items.PreemSilenced_" + name) == twin {
        return TDBID.Create("Items." + name);
      }
    }
    return TDBID.None();
  }

  // Whether the vanilla screens (mod screen, tooltips) hide a weapon's muzzle slot: the weapon
  // record lists no muzzle parts (no vanilla muzzle), so the slot is only there for the hidden part
  // (Items.PreemBarrelSlot03Element) and nothing from the inventory fits it. Not a weapon: false.
  public final static func HidesMuzzleSlot(weaponRecord: TweakDBID) -> Bool {
    let weapon = TweakDBInterface.GetWeaponItemRecord(weaponRecord);
    if !IsDefined(weapon) {
      return false;
    }
    let lists: array<wref<SlotItemPartListElement_Record>>;
    weapon.SlotPartList(lists);
    for list in lists {
      if IsDefined(list) && IsDefined(list.Slot()) && list.Slot().GetID() == t"AttachmentSlots.PowerModule" {
        return false;
      }
    }
    return true;
  }

  public final static func HasSilencedTag(record: TweakDBID) -> Bool {
    let itemRecord = TweakDBInterface.GetItemRecord(record);
    return IsDefined(itemRecord) && itemRecord.TagsContains(n"Silenced");
  }

  // Whether a Preem Silencer sits in one of the item's barrel slots.
  public final static func HasPreemSilencer(itemData: ref<gameItemData>) -> Bool {
    for placement in PreemCraftingSystem.GetInstalledMods(itemData) {
      if Equals(placement.mod.modStyleType, PreemModStyleType.Barrel_Silencer) && placement.slotID != t"AttachmentSlots.PowerModule" {
        return true;
      }
    }
    return false;
  }

  // The item in an item's muzzle slot, ItemID.None() when it has none.
  public final static func GetPartItem(itemData: ref<gameItemData>) -> ItemID {
    if !IsDefined(itemData) || !itemData.HasPartInSlot(t"AttachmentSlots.PowerModule") {
      return ItemID.None();
    }
    let part: InnerItemData;
    itemData.GetItemPart(part, t"AttachmentSlots.PowerModule");
    return InnerItemData.GetItemID(part);
  }

  // A muzzle part that has come off into the inventory: the hidden part is deleted, a twin is
  // swapped for its plain brake; anything else stays. Returns the item now in the inventory.
  public final static func TakeBack(owner: ref<GameObject>, part: ItemID) -> ItemID {
    let record = ItemID.GetTDBID(part);
    let brake = PreemMuzzleParts.BrakeOf(record);
    if !ItemID.IsValid(part) || (record != PreemMuzzleParts.HiddenPart() && !TDBID.IsValid(brake)) {
      return part;
    }
    let ts = GameInstance.GetTransactionSystem(owner.GetGame());
    if !ts.HasItem(owner, part) {
      return part;
    }
    ts.RemoveItem(owner, part, 1);
    if !TDBID.IsValid(brake) {
      return ItemID.None();
    }
    let plain = ItemID.FromTDBID(brake);
    ts.GiveItem(owner, plain, 1);
    return plain;
  }

  // Takes back every hidden part and twin left in the inventory (a vanilla path that strips parts,
  // such as using a weapon as a crafting ingredient, puts them there). Matched by record: each part
  // item has its own seed, so ItemID.FromTDBID(record) doesn't find it.
  public final static func TakeBackStray(owner: ref<GameObject>) -> Void {
    if !IsDefined(owner) {
      return;
    }
    let items: array<wref<gameItemData>>;
    GameInstance.GetTransactionSystem(owner.GetGame()).GetItemList(owner, items);
    let stray: array<ItemID>;
    for item in items {
      let record = ItemID.GetTDBID(item.GetID());
      if record == PreemMuzzleParts.HiddenPart() || TDBID.IsValid(PreemMuzzleParts.BrakeOf(record)) {
        let count = item.GetQuantity();
        while count > 0 {
          ArrayPush(stray, item.GetID());
          count -= 1;
        }
      }
    }
    for part in stray {
      PreemMuzzleParts.TakeBack(owner, part);
    }
  }
}
