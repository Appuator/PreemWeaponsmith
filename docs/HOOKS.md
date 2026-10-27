# Game hooks

Every live annotation in `src/redscript/PreemWeaponsmith` that touches a game class. Re-check this list after every game patch: compile errors catch renamed or removed methods, but a wrapped method whose logic changed still compiles.

Regenerate with the command in `docs/MODDING-WORKFLOW.md` §4C, or by grepping for `^\s*@(wrapMethod|replaceMethod|addMethod|addField)`.

## Wrapped methods (highest patch risk)

| Class | Method | Location |
|---|---|---|
| `CraftingMainGameController` | `OnCraftingComplete` | `PreemMainUI/PreemWeaponPreviewContainer.reds:80` |
| `CraftingMainGameController` | `OnInitialize` | `PreemMainUI/PreemWeaponPreviewContainer.reds:10` |
| `CraftingMainGameController` | `OnUninitialize` | `PreemMainUI/PreemWeaponPreviewContainer.reds:50` |
| `CraftingMainLogicController` | `OnPressSelectedItem` | `PreemMainUI/PreemWeaponPreviewContainer.reds:101` |
| `CraftingSystem` | `CanItemBeCrafted` | `Adapters/PreemCraftingSystemAdapter.reds:68` |
| `CraftingSystem` | `CanItemBeCrafted` | `Adapters/PreemCraftingSystemAdapter.reds:92` |
| `CraftingSystem` | `CraftItem` | `Adapters/PreemCraftingSystemAdapter.reds:26` |
| `CraftingSystem` | `EnoughIngredientsForCrafting` | `Adapters/PreemCraftingSystemAdapter.reds:117` |
| `InventoryDataManagerV2` | `GetAttachmentSlotsForInventory` | `Adapters/PreemInventoryAdapter.reds:5` |
| `InventoryDataManagerV2` | `IsAttachmentDedicated` | `Adapters/PreemInventoryAdapter.reds:22` |
| `MaterialTooltip` | `SetData` | `PreemMainUI/PreemWeaponPreviewContainer.reds:150` |
| `MeleeAttackGenericEvents` | `SpawnAttackGameEffect` | `Adapters/PreemWeaponAdapter.reds:199` |
| `MeleeSprintAttackEvents` | `OnEnter` | `Adapters/PreemWeaponAdapter.reds:216` |
| `UIInventoryItemModsStaticData` | `GetAttachmentSlots` | `Adapters/PreemInventoryAdapter.reds:27` |
| `UIInventoryItemModsStaticData` | `IsAttachmentDedicated` | `Adapters/PreemInventoryAdapter.reds:44` |
| `WeaponObject` | `OnGameAttached` | `Adapters/PreemWeaponAdapter.reds:125` |
| `WeaponTransition` | `GetDesiredAttackRecord` | `Adapters/PreemWeaponAdapter.reds:158` |
| `WeaponTransition` | `IsPrimaryTriggerModeActive` | `Adapters/PreemWeaponAdapter.reds:185` |
| `WeaponTransition` | `SwitchTriggerMode` | `Adapters/PreemWeaponAdapter.reds:141` |

There are no `@replaceMethod` hooks (the old commented-out ones were deleted in Phase 1).

## Added methods and fields (lower risk: only break if the class itself is renamed or removed)

| Annotation | Member | Location |
|---|---|---|
| `@addField(CraftingMainGameController)` | `_preemFrame` | `PreemMainUI/PreemWeaponPreviewContainer.reds:7` |
| `@addField(MaterialTooltipData)` | `preemModDescription` | `PreemMainUI/PreemWeaponPreviewContainer.reds:147` |
| `@addMethod(CraftingMainGameController)` | `ClearMods` | `PreemMainUI/PreemWeaponPreviewContainer.reds:89` |
| `@addMethod(CraftingMainGameController)` | `GetPreemFrame` | `PreemMainUI/PreemWeaponPreviewContainer.reds:18` |
| `@addMethod(CraftingMainGameController)` | `GetPreemPlayer` | `PreemMainUI/PreemWeaponPreviewContainer.reds:31` |
| `@addMethod(CraftingMainGameController)` | `GetPreemSettings` | `PreemMainUI/PreemWeaponPreviewContainer.reds:25` |
| `@addMethod(CraftingMainGameController)` | `GetPreemTooltipsManager` | `PreemMainUI/PreemWeaponPreviewContainer.reds:37` |
| `@addMethod(CraftingMainGameController)` | `GetPreemWeaponQuality` | `PreemMainUI/PreemWeaponPreviewContainer.reds:44` |
| `@addMethod(CraftingMainGameController)` | `ProcessPreemModSelection` | `PreemMainUI/PreemWeaponPreviewContainer.reds:57` |
| `@addMethod(CraftingSystem)` | `InstallPreemMod` | `Adapters/PreemCraftingSystemAdapter.reds:6` |
| `@addMethod(WeaponObject)` | `ChangeTriggerBasedOnPreemMods` | `Adapters/PreemWeaponAdapter.reds:4` |
| `@addMethod(WeaponObject)` | `ConvertTriggerModeToActual` | `Adapters/PreemWeaponAdapter.reds:80` |
| `@addMethod(WeaponObject)` | `GetAttackBasedOnPreemMods` | `Adapters/PreemWeaponAdapter.reds:18` |
| `@addMethod(WeaponObject)` | `GetEvolutionBasedOnPreemMods` | `Adapters/PreemWeaponAdapter.reds:106` |
| `@addMethod(WeaponObject)` | `GetTriggerTypeBasedOnPreemMods` | `Adapters/PreemWeaponAdapter.reds:44` |
| `@addMethod(gameItemData)` | `DoesItemHaveBoosterHandle` | `Adapters/ItemDataAdapter.reds:83` |
| `@addMethod(gameItemData)` | `DoesItemHavePowerBarrel` | `Adapters/ItemDataAdapter.reds:53` |
| `@addMethod(gameItemData)` | `DoesItemHavePreemMod` | `Adapters/ItemDataAdapter.reds:19` |
| `@addMethod(gameItemData)` | `DoesItemHaveSilencer` | `Adapters/ItemDataAdapter.reds:67` |
| `@addMethod(gameItemData)` | `DoesItemHaveSmartBarrel` | `Adapters/ItemDataAdapter.reds:5` |
| `@addMethod(gameItemData)` | `DoesItemHaveTechBarrel` | `Adapters/ItemDataAdapter.reds:39` |

## Resource callbacks (Codeware)

Not annotations, but they change game data when it loads. Re-check after every patch that the
resources still exist at these paths and that the fields keep their names.

| Event | Resource | What changes | Location |
|---|---|---|---|
| `Resource/Ready` | `base\sound\metadata\cooked_metadata.audio_metadata`, `ep1\sound\metadata\cooked_metadata.audio_metadata` | Empty fire-mode fields of `audioPlayerWeaponSettings` entries (`PreemSoundSets.Fills`) | `Audio/PreemSoundSets.reds` (`PreemSoundSetService`) |
