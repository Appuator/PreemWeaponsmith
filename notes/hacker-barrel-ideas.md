# Hacker and Cripple barrels add-on (Modathon 2026)

Spec, 2026-10-28. The open questions were answered the same day (§6). Next: the core part becomes a ROADMAP phase and a SPEC section; the add-on gets its own sibling project, `CyberpunkModding/PreemHackerBarrels/` (own repo, release zip and roadmap).

**Text rule:** the user writes every player-facing string (mod names, UI labels, tooltip and description text, status effect names, Nexus page). In this note and in the code they are `TODO_USER_TEXT` placeholders. Claude writes the code and the research. (Contest T&C §3.6; the user's reading, see memory.)

## 1. What it is
A separate mod on one Nexus page that needs Preem Weaponsmith. It adds two Preem mods in the Barrel slot class, each with one job (decided 2026-10-28: the two effects stay apart):

1. **Hacker barrel.** Each hit puts a stack of **Breach** on the target. Quickhacks on a breached target cost less RAM, more per stack.
2. **Cripple barrel.** Each hit puts a stack of a second debuff, **Cripple charge**, on the target, up to 6. At the 6th stack the target is crippled (Cripple Movement) and the charge is used up.

Ranged weapons have two barrel slots, and one gun may carry both barrels (they fill both slots, so no other barrel fits). Both need a cyberdeck equipped.

**Contest fit:** a new page published 20 Oct to 31 Dec 2026 (T&C §3.3); tags "Cyberpunk Modathon 2026" and "Never Fade Away (2026 Modathon)", maybe "To the Moon (2026 Modathon)". Judges test the version at close (§5.11), so everything ships by 31 Dec.

## 2. Mechanics

### 2.1 Stacking on hit (both barrels)
- **Counts:** a hit on a living NPC (`ScriptedPuppet`) hostile to the player, where the attack's instigator is the player, the player has a cyberdeck equipped (`EquipmentSystem.IsCyberdeckEquipped(player)`), the attack is ranged (`AttackData.IsRangedOrDirect`, not DoT, not explosion), and the attack's weapon (`evt.attackData.GetWeapon()`) has the barrel's item in a Preem barrel slot (`gameItemData.DoesItemHavePreemMod`, `Adapters/ItemDataAdapter.reds`).
- **Effect:** add one stack of that barrel's status effect (TweakXL records `PreemHacker.Breach` and `PreemHacker.CrippleCharge`). Each stack refreshes the duration.
- **Rate limit:** at most one stack per target per barrel per `stackInterval` seconds, so shotgun pellets, Smart bullets and fast triggers don't stack faster than a pistol. One stack per shot, not per pellet.
- **Not on:** dead targets, devices, vehicles, civilians, and friendly or neutral NPCs. Without a cyberdeck the barrels do nothing (no stacks at all).
- **Shared code:** one hit hook and one rate limiter serve both barrels; each barrel is a row of data (item, status effect, numbers).

Starting numbers (tuning goes in tweak data, not literals):

| Value | Hacker | Cripple | Notes |
|---|---|---|---|
| `maxStacks` | 5 | 6 | Cripple's 6 decided 2026-10-28 |
| `duration` | 8 s | 8 s | refreshed on each stack |
| `stackInterval` | 0.3 s | 0.3 s | per target, per barrel |
| `ramPerStack` | 1 | — | RAM off each quickhack |
| `crippleCooldown` | — | 15 s | per target, after a cripple |

### 2.2 Hacker barrel: RAM discount
- **Hook:** `@wrapMethod(BaseScriptableAction) GetCost() -> Int32`. Vanilla works out every quickhack's RAM cost here, perk discounts included (`baseDeviceActions.script:644`). `ScriptableDeviceAction.GetCost` only calls `super`, so one wrap covers device and NPC quickhacks. The quickhack wheel shows what this returns, so the lower cost should show up with no UI code (checked in §5).
- **Rule:** if the target has Breach and the hack has a cost: `result = Max(2, cost - stacks * ramPerStack)`. A cost already under 2 stays as it is: vanilla's minimum for a costed hack is 2, and the discount never lowers it below that.
- **Target:** the same one vanilla uses: `GetRequesterID()` if defined, else the entity of `GetPersistentID()`.
- **Pure function for tests:** `PreemHacker.DiscountedCost(cost: Int32, stacks: Int32, ramPerStack: Int32) -> Int32`.
- Breach stays on after a quickhack lands; it only runs out with time, so several hacks in a row all get the discount.

### 2.3 Cripple barrel: cripple at 6
- When a hit would add the 6th stack: apply the vanilla level-1 Cripple Movement status effect (a `LocomotionMalfunction…` record; exact ID from a TweakDB lookup, the first core-phase research step), remove the Cripple charge stacks, start the per-target cooldown. During the cooldown, hits still add stacks but don't cripple again; the stacks wait at 5 until the cooldown ends, and the next hit after that cripples.
- A status effect applied directly, not an upload: no upload bar, no trace from enemy netrunners. The cyberdeck is needed only because stacks need one (§2.1).
- Vanilla notes: the level-3 cripple tag `LocomotionMalfunctionLevel3` raises the finisher threshold (`gameObject.script:1837`), and `NPCPuppet` applies `LocomotionMalfunctionLevel4Passive` on its own in some cases (`NPCPuppet.script:1444`). Level 1 avoids both.
- **Pure function for tests:** `PreemHacker.CrippleStep(stacks, now, cooldownEnd, maxStacks) -> (newStacks, cripple: Bool)`.

### 2.4 The barrels themselves
| | Hacker | Cripple |
|---|---|---|
| Style | `Barrel_Hacker` (already in the core enum, value 6) | `Barrel_Cripple`, new core enum value 20 |
| Item | `Items.PreemBarrelModHacker` | `Items.PreemBarrelModCripple` |
| Status effect | `PreemHacker.Breach` | `PreemHacker.CrippleCharge` |

- Both: `$base: Items.SimpleWeaponMod01`, placement slots `AttachmentSlots.PreemBarrelMod01/02`, no stat modifiers (the barrel slot and the cyberdeck are the cost; tune later if they play too strong), like the other barrels in `tweaks/barrels.yaml`. Slot class Barrel, no required evolution, not incompatible with each other.
- Unlock under Weapon Blueprints: Hacker at Rare, Cripple at Epic (crowd control is the stronger effect). Sandbox: both always unlocked, like every mod.
- Both debuffs show as status icons on the enemy, so the player sees stacks build (icon records in TweakXL; whether vanilla shows a stack count is to check).
- Names, descriptions, extra descriptions, status effect names: `TODO_USER_TEXT`.
- Value 20 for `Barrel_Cripple`: values 20–99 are unused, and no code does range arithmetic on style values (searched `src/` and `dev/` 2026-10-28; HANDOFF §1 says code relies on the hundreds ranges, which should be checked and corrected as part of the core work).

## 3. Core change: add-on extension points
Today the catalogue is closed: `PreemModMaker.GetModsFromClassType` and `GetModFromModStyleType`, `PreemModMapper` (style → item, slot list, name) and the `PreemModUnlocker` tier lists are switches and fixed lists on `PreemModStyleType`. An add-on can't add to them except by wrapping those internal methods, which ties it to their exact shape.

**Proposal:** a small public surface in core (new release, e.g. 2.6.0; not the contest entry):
- `public class PreemAddons` with empty static methods core calls at each catalogue step, for add-ons to `@wrapMethod`:
  - `AddMods(classType, out list)` at the end of `GetModsFromClassType`;
  - `DefineMod(styleType, mod) -> Bool` in the default branch of `GetModFromModStyleType`;
  - `MapItem(styleType) -> TweakDBID` in the mapper's default branch (before the `Items.TestMod1` fallback);
  - `AddUnlocked(quality, out styles)` after each tier list is built.
- A version constant `PreemAddons.ApiVersion()` so an add-on can refuse to run on an older core and log why.
- `Barrel_Cripple = 20` added to `PreemModStyleType`. redscript can't add enum values from another mod, so every add-on style needs a named value in core. No reserved block for now: a later barrel adds its value in a core release.
- Documented in a short `docs/ADDONS.md`, listed in `docs/HOOKS.md` (as hook *points*, not game hooks).

Alternative: no core change except the enum value, the add-on wraps the existing methods directly. Works today, but every core refactor can break the add-on. Not recommended.

## 4. Hooks (add-on)
| Target | Kind | Why |
|---|---|---|
| `ScriptedPuppet.DamagePipelineFinalized(evt)` | `@wrapMethod` | Runs after damage is worked out for a hit on an NPC (`scriptedPuppet.script:3915`); read `evt.attackData`, add stacks, maybe cripple. Call `wrappedMethod` first. |
| `BaseScriptableAction.GetCost()` | `@wrapMethod` | Hacker barrel's RAM discount (§2.2). |
| `PreemAddons.*` | `@wrapMethod` | Register both barrels in the core catalogue (§3). |

Per-target state (last stack time per barrel, cripple cooldown end) lives in a `ScriptableSystem` map keyed by `EntityID`, cleared when entries expire. No `@addField` on game classes.

## 5. Testing
Cheapest first, same layers as core (CLAUDE.md "Verification recipe"):
1. **Compile check** with core + add-on.
2. **RedTest:** `DiscountedCost` (floor at 2, cost under 2 unchanged, 0 stacks); `CrippleStep` (5 → 6 cripples and clears; during cooldown stays at 5, no cripple; after cooldown the next hit cripples); the rate limiter (two hits inside `stackInterval` add one stack).
3. **Boot + self-check:** both items, both status effects and the cripple record resolve; both barrels are in the Barrel list; Hacker unlocks at Rare and Cripple at Epic.
4. **In a loaded save (CET e2e):** craft a gun with both barrels; spawn a hostile NPC; add stacks through a dev command; read `GetCost()` for a quickhack on it before and after Breach; take Cripple charge to 6 and check the cripple status effect is on the NPC and the charge is gone. With the cyberdeck unequipped, hits add no stacks; a civilian gets none either.
5. **Human gate:** feel in play (stack rate, discount size, how often cripple lands), the wheel showing the discounted cost, both barrels together on one gun, and the add-on page.

## 6. Decisions (2026-10-28, by the user)
| # | Question | Decision |
|---|---|---|
| Q1 | Where the add-on lives | Sibling project `CyberpunkModding/PreemHackerBarrels/`, own repo and release zip |
| Q2 | Cripple strength | Level 1 Cripple Movement (record ID still to look up) |
| Q3 | Both barrels on one gun | Allowed |
| Q4 | Which NPCs get stacks | Hostile only |
| Q5 | Breach after a quickhack | Stays; only time removes it |
| Q6 | Cyberdeck | Both barrels need one |
| Q7 | Stat cost | None for now |
| Q8 | Unlock under Weapon Blueprints | Hacker at Rare, Cripple at Epic |
| Q9 | Debuff icons | Shown on the enemy |
| Q10 | More barrels later | Not now; no reserved enum block |
| Q11 | Nexus pages | One page with both barrels |
| Q12 | Release order | Core 2.6.0 (extension points, `Barrel_Cripple`) first, add-on page later |

Merge into `SPEC.md` (core part) and the ROADMAP decisions log when the core phase is planned.

## 7. Still to find out
- The level-1 Cripple Movement status effect's TweakDB ID, and how vanilla applies it (status effect on the NPC, or through the quickhack's effectors).
- Whether a stacking status effect's icon shows a stack count over an enemy's health bar.
- Whether the quickhack wheel and the scanner show the discounted cost from `GetCost()` with no other hook.
