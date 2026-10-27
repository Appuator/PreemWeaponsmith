// Install plans: where PreemCraftingSystem.ApplyMods puts each chosen mod, and what it changes on
// a weapon that already has Preem mods (SPEC §2.1). Compiled only when the mod is installed
// (registered by PreemModTests() in PreemModTests.reds). Expected slots are the 2.2.5 behaviour,
// worked out by hand: per slot class the mods fill slot 01, then 02; the Silencer goes to the
// muzzle slot (PowerModule) but still uses up a barrel slot.
module PreemDev.Tests

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.CraftingSystem.PreemCraftingSystem.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.Core.*
@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
import PreemCrafting.CraftingSystem.PreemModMaker.*

@if(ModuleExists("PreemCrafting.CraftingSystem.PreemCraftingSystem"))
public class PreemInstallPlanTest extends BaseTest {
  public func Create() {
    this.m_modName = "PreemWeaponsmith";
    this.m_name = "InstallPlan";
  }

  private func Mods(styles: array<PreemModStyleType>) -> array<ref<PreemMod>> {
    let mods: array<ref<PreemMod>>;
    for style in styles {
      ArrayPush(mods, PreemModMaker.GetModFromModStyleType(style));
    }
    return mods;
  }

  private func Placed(slot: TweakDBID, style: PreemModStyleType) -> ref<PreemModPlacement> {
    return PreemModPlacement.Create(slot, PreemModMaker.GetModFromModStyleType(style));
  }

  // "PreemBarrelMod01=Barrel_Smart, ..." in plan order.
  private func Describe(placements: array<ref<PreemModPlacement>>) -> String {
    let text = "";
    for p in placements {
      if StrLen(text) > 0 {
        text += ", ";
      }
      text += StrAfterFirst(TDBID.ToStringDEBUG(p.slotID), ".") + "=" + PreemDebug.StyleName(p.mod.modStyleType);
    }
    return text;
  }

  private func DescribeSlots(slots: array<TweakDBID>) -> String {
    let text = "";
    for slot in slots {
      if StrLen(text) > 0 {
        text += ", ";
      }
      text += StrAfterFirst(TDBID.ToStringDEBUG(slot), ".");
    }
    return text;
  }

  private func Changes(wanted: array<PreemModStyleType>, installed: array<ref<PreemModPlacement>>) -> String {
    let installs: array<ref<PreemModPlacement>>;
    let removals: array<TweakDBID>;
    PreemCraftingSystem.PlanModChanges(PreemCraftingSystem.PlanModSlots(this.Mods(wanted)), installed, installs, removals);
    return "install [" + this.Describe(installs) + "] remove [" + this.DescribeSlots(removals) + "]";
  }

  private cb func Test_SlotsPerClass() {
    let plan = PreemCraftingSystem.PlanModSlots(this.Mods([PreemModStyleType.Barrel_Smart, PreemModStyleType.Trigger_FullAuto, PreemModStyleType.Mag_Thermal, PreemModStyleType.Barrel_Recoil]));
    this.ExpectString("two barrels, a trigger, a magazine", this.Describe(plan),
      "PreemBarrelMod01=Barrel_Smart, PreemTriggerMod01=Trigger_FullAuto, PreemMagazineMod01=Mag_Thermal, PreemBarrelMod02=Barrel_Recoil");
  }

  private cb func Test_SilencerTakesMuzzle() {
    let plan = PreemCraftingSystem.PlanModSlots(this.Mods([PreemModStyleType.Barrel_Silencer, PreemModStyleType.Barrel_Recoil]));
    this.ExpectString("Silencer, then a barrel", this.Describe(plan), "PowerModule=Barrel_Silencer, PreemBarrelMod02=Barrel_Recoil");
  }

  // A new item has nothing installed: every mod is installed, nothing removed (crafting).
  private cb func Test_NewItem() {
    let none: array<ref<PreemModPlacement>>;
    this.ExpectString("crafted weapon", this.Changes([PreemModStyleType.Blade_Thermal, PreemModStyleType.Handle_RubberizedGrip], none),
      "install [PreemBladeMod01=Blade_Thermal, PreemHandleMod01=Handle_RubberizedGrip] remove []");
  }

  // An owned weapon keeps the mods it already has in the same slot; only changes are installed.
  private cb func Test_KeepsInstalled() {
    let installed = [this.Placed(t"AttachmentSlots.PreemBarrelMod01", PreemModStyleType.Barrel_Smart), this.Placed(t"AttachmentSlots.PreemTriggerMod01", PreemModStyleType.Trigger_FullAuto)];
    this.ExpectString("same Smart barrel, Full-auto replaced by Burst", this.Changes([PreemModStyleType.Barrel_Smart, PreemModStyleType.Trigger_Burst], installed),
      "install [PreemTriggerMod01=Trigger_Burst] remove []");
    this.ExpectString("nothing changed", this.Changes([PreemModStyleType.Barrel_Smart, PreemModStyleType.Trigger_FullAuto], installed),
      "install [] remove []");
  }

  // SPEC §2.1: an owned weapon keeps its record, so the three evolution barrels are refused there.
  private cb func Test_OwnedWeaponMods() {
    this.ExpectBool("Smart barrel on an owned weapon", PreemCraftingSystem.IsModAllowedOnOwnedWeapon(PreemModStyleType.Barrel_Smart), false);
    this.ExpectBool("Tech barrel on an owned weapon", PreemCraftingSystem.IsModAllowedOnOwnedWeapon(PreemModStyleType.Barrel_Tech), false);
    this.ExpectBool("Power barrel on an owned weapon", PreemCraftingSystem.IsModAllowedOnOwnedWeapon(PreemModStyleType.Barrel_Power), false);
    this.ExpectBool("Silencer on an owned weapon", PreemCraftingSystem.IsModAllowedOnOwnedWeapon(PreemModStyleType.Barrel_Silencer), true);
    this.ExpectBool("Burst trigger on an owned weapon", PreemCraftingSystem.IsModAllowedOnOwnedWeapon(PreemModStyleType.Trigger_Burst), true);
  }

  // Mods no longer chosen come off; a replaced one is overwritten in place (not removed first).
  private cb func Test_RemovesDropped() {
    let mags = [this.Placed(t"AttachmentSlots.PreemMagazineMod01", PreemModStyleType.Mag_Thermal), this.Placed(t"AttachmentSlots.PreemMagazineMod02", PreemModStyleType.Mag_Electric)];
    this.ExpectString("Electric moves to the first slot", this.Changes([PreemModStyleType.Mag_Electric], mags),
      "install [PreemMagazineMod01=Mag_Electric] remove [PreemMagazineMod02]");
    let blade = [this.Placed(t"AttachmentSlots.PreemBladeMod01", PreemModStyleType.Blade_Thermal)];
    let none: array<PreemModStyleType>;
    this.ExpectString("every mod cleared", this.Changes(none, blade), "install [] remove [PreemBladeMod01]");
  }
}
