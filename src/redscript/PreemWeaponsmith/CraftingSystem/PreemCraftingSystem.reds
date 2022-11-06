module PreemCrafting.CraftingSystem.PreemCraftingSystem
import PreemCrafting.CraftingSystem.ModInstaller.*
import PreemCrafting.Core.*

public class PreemCraftingSystem extends ScriptableSystem {

  //private let _inventoryManager: ref<InventoryDataManagerV2>;
  private let _player: wref<PlayerPuppet>;
  private let _currentSelectedMods: array<ref<PreemMod>>;
  private let _modInstaller: ref<PreemModMapper>;
  private let _currentEvolution: gamedataWeaponEvolution = gamedataWeaponEvolution.Invalid;


  private func OnAttach() -> Void {
    //LogChannel(n"DEBUG", "PreemCraftingSystem::OnAttach");
    this._modInstaller = new PreemModMapper();
  }

  private func OnDetach() -> Void {
    //LogChannel(n"DEBUG", "PreemCraftingSystem::OnDetach");
    this._modInstaller = null;
  }

  //  private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
  //   LogChannel(n"DEBUG", "PreemCraftingSystem::OnPlayerAttach");
  //   let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(request.owner.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
  //   if IsDefined(player) {
  //     this._player = player;
  //     this._inventoryManager = new InventoryDataManagerV2();  
  //     this._inventoryManager.Initialize(this._player);
  //     this.RefreshPlayerInventory();
  //     LogChannel(n"DEBUG", "PreemCraftingSystem::Player Inventory Refreshed");
  //   };
  // }

  public final static func GetInstance(gameInstance: GameInstance) -> ref<PreemCraftingSystem> {
    let craftSystem: ref<PreemCraftingSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"PreemCrafting.CraftingSystem.PreemCraftingSystem.PreemCraftingSystem") as PreemCraftingSystem;
    return craftSystem;
  }

  public final static func GetRangedWeaponsItemsTypeList() -> array<gamedataItemType>
  {
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

  // public func RefreshPlayerInventory() -> Void {
  //   let playerItems: array<ItemID>;
  //   let playerItemsData: array<ref<gameItemData>>;
  //   this._inventoryManager.GetPlayerItemsDataByCategory(gamedataItemCategory.Weapon, playerItemsData);
  //   this.GetItemsIdsFromGameData(playerItemsData, playerItems);
  // }

  // private func GetItemsIdsFromGameData(targetItems: array<ref<gameItemData>>, out items: array<ItemID>) -> Void {
  //   let itemId: ItemID;
  //   let limit: Int32 = ArraySize(targetItems);
  //   let i: Int32 = 0;
  //   while i < limit {
  //     itemId = targetItems[i].GetID();
  //     ArrayPush(items, itemId);
  //     i += 1;
  //   };
  // }

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

  public func ApplyMods(gi: GameInstance, itemToApplyTo: ref<gameItemData>) -> Bool {
    let applyModsResult: Bool = true;
    let currMod: ref<PreemMod>;
    let limit: Int32 = ArraySize(this._currentSelectedMods);
    let i: Int32 = 0;
    let barrelCount = 0;
    let triggerCount = 0;
    let magCount = 0;
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
      }

      i += 1;
    };
    //LogChannel(n"DEBUG", "PreemCraftingSystem::Mods Applied");
    return applyModsResult;
  }

  public func CanInstallSelectedPreemMods() -> Bool
  {
    let canInstall: Bool = true;

    for preemMod in this._currentSelectedMods
    {
        let isRequiredEvo = false;
        if (NotEquals(this._currentEvolution,gamedataWeaponEvolution.Invalid)
                  && NotEquals(preemMod.GetRequiredEvolution(),gamedataWeaponEvolution.Invalid))
        {
          isRequiredEvo = Equals(this._currentEvolution, preemMod.GetRequiredEvolution());
        }

        //LogChannel(n"DEBUG", s"PreemCraftingSystem:: \(preemMod.GetRequiredMods())");
        for mod in preemMod.GetRequiredMods()
        {
            let isRequiredInstalled = false;

            for currModType in PreemMod.GetModTypes(this._currentSelectedMods)
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

    for preemMod in this._currentSelectedMods
    {
        //LogChannel(n"DEBUG", s"PreemCraftingSystem:: \(preemMod.GetIncompatMods())");
        for mod in preemMod.GetIncompatMods()
        {
            for currModType in PreemMod.GetModTypes(this._currentSelectedMods)
            {
              if(Equals(currModType,mod))
              {
                return false;
              }
            }
        }
    }

    //LogChannel(n"DEBUG", s"PreemCraftingSystem can install:: \(canInstall)");
    return canInstall;
  }

}