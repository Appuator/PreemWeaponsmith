// Install plans: where PreemCraftingSystem.ApplyMods puts each chosen mod, and what it changes on
// a weapon that already has Preem mods (SPEC §2.1). Compiled only when the mod is installed
// (registered by PreemModTests() in PreemModTests.reds). Expected slots are the 2.2.5 behaviour,
// worked out by hand: per slot class the mods fill slot 01, then 02. Up to 2.4.x the Silencer went
// to the muzzle slot (PowerModule); since ADR 0002 it takes a barrel slot like the others.
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

  // ADR 0002: the Silencer is a normal barrel mod (the hidden muzzle part makes the sound).
  private cb func Test_SilencerTakesBarrelSlot() {
    let plan = PreemCraftingSystem.PlanModSlots(this.Mods([PreemModStyleType.Barrel_Silencer, PreemModStyleType.Barrel_Recoil]));
    this.ExpectString("Silencer, then a barrel", this.Describe(plan), "PreemBarrelMod01=Barrel_Silencer, PreemBarrelMod02=Barrel_Recoil");
  }

  // A weapon crafted with 2.4.x has the Silencer in the muzzle slot: kept as Silencer, it moves to
  // a barrel slot and the old one comes off.
  private cb func Test_OldSilencerMoves() {
    let old = [this.Placed(t"AttachmentSlots.PowerModule", PreemModStyleType.Barrel_Silencer)];
    this.ExpectString("2.4.x Silencer", this.Changes([PreemModStyleType.Barrel_Silencer], old),
      "install [PreemBarrelMod01=Barrel_Silencer] remove [PowerModule]");
  }

  // The record PlanMuzzlePart wants in the muzzle slot, "" for an empty slot.
  private func Muzzle(wanted: array<PreemModStyleType>, muzzlePart: TweakDBID, silencedPart: Bool) -> String {
    let target = PreemCraftingSystem.PlanMuzzlePart(PreemCraftingSystem.PlanModSlots(this.Mods(wanted)), muzzlePart, silencedPart);
    return TDBID.IsValid(target) ? TDBID.ToStringDEBUG(target) : "";
  }

  // ADR 0002 and its addendum: while a Silencer is wanted the muzzle holds a Silenced part: the
  // hidden part, a muzzle brake's twin, or a vanilla silencer the player put there. silencedPart: the
  // part in the muzzle has the Silenced tag (true for a vanilla silencer and the 2.4.x Silencer).
  private cb func Test_MuzzlePart() {
    let none: array<PreemModStyleType>;
    let silencer = [PreemModStyleType.Barrel_Silencer];
    this.ExpectString("Silencer, empty muzzle", this.Muzzle(silencer, TDBID.None(), false), "Items.PreemSilencerMuzzle");
    this.ExpectString("Silencer, part already there", this.Muzzle([PreemModStyleType.Barrel_Silencer, PreemModStyleType.Barrel_Recoil], t"Items.PreemSilencerMuzzle", false), "Items.PreemSilencerMuzzle");
    this.ExpectString("Silencer, 2.4.x Silencer in the muzzle", this.Muzzle(silencer, t"Items.PreemBarrelModSilencer", true), "Items.PreemSilencerMuzzle");
    this.ExpectString("Silencer, vanilla silencer", this.Muzzle(silencer, t"Items.w_silencer_01", true), "Items.w_silencer_01");
    this.ExpectString("Silencer, rifle brake", this.Muzzle(silencer, t"Items.w_muzzle_brake_03", false), "Items.PreemSilenced_w_muzzle_brake_03");
    this.ExpectString("Silencer, handgun brake", this.Muzzle(silencer, t"Items.w_muzzle_brake_09_legendary", false), "Items.PreemSilenced_w_muzzle_brake_09_legendary");
    this.ExpectString("Silencer, twin already there", this.Muzzle(silencer, t"Items.PreemSilenced_w_muzzle_brake_03", false), "Items.PreemSilenced_w_muzzle_brake_03");
    this.ExpectString("Silencer, other muzzle part", this.Muzzle(silencer, t"Items.w_att_power_street_12601_mzl", false), "Items.PreemSilencerMuzzle");
    this.ExpectString("Silencer dropped", this.Muzzle([PreemModStyleType.Barrel_Recoil], t"Items.PreemSilencerMuzzle", false), "");
    this.ExpectString("every mod cleared", this.Muzzle(none, t"Items.PreemSilencerMuzzle", false), "");
    this.ExpectString("Silencer dropped, twin back to its brake", this.Muzzle(none, t"Items.PreemSilenced_w_muzzle_brake_09_legendary", false), "Items.w_muzzle_brake_09_legendary");
    this.ExpectString("no Silencer, vanilla silencer", this.Muzzle([PreemModStyleType.Barrel_Recoil], t"Items.w_silencer_01", true), "Items.w_silencer_01");
    this.ExpectString("no Silencer, brake", this.Muzzle(none, t"Items.w_muzzle_brake_01", false), "Items.w_muzzle_brake_01");
    this.ExpectString("no Silencer, empty muzzle", this.Muzzle(none, TDBID.None(), false), "");
  }

  // Gate feedback 2026-10-28: the vanilla screens hide the muzzle slot of a weapon with no vanilla
  // muzzle (no AttachmentSlots.PowerModule part list in its slotPartList; weapon dump 2026-10-27).
  private cb func Test_HidesMuzzleSlot() {
    this.ExpectBool("Kenshin (no muzzle)", PreemMuzzleParts.HidesMuzzleSlot(t"Items.Preset_Kenshin_Default"), true);
    this.ExpectBool("Burya (no muzzle)", PreemMuzzleParts.HidesMuzzleSlot(t"Items.Preset_Burya_Default"), true);
    this.ExpectBool("Nekomata (no muzzle)", PreemMuzzleParts.HidesMuzzleSlot(t"Items.Preset_Nekomata_Default"), true);
    this.ExpectBool("Ajax (rifle muzzles)", PreemMuzzleParts.HidesMuzzleSlot(t"Items.Preset_Ajax_Default"), false);
    this.ExpectBool("Lexington (handgun muzzles)", PreemMuzzleParts.HidesMuzzleSlot(t"Items.Preset_Lexington_Default"), false);
    this.ExpectBool("not a weapon", PreemMuzzleParts.HidesMuzzleSlot(t"Items.w_muzzle_brake_01"), false);
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
