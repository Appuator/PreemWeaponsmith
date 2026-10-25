# Game hooks

Every live annotation in `src/redscript/PreemWeaponsmith` that touches a game class (the commented-out vendored `Codeware/` folder is excluded). Re-check this list after every game patch: compile errors catch renamed or removed methods, but a wrapped method whose logic changed still compiles.

Regenerate with the command in `docs/MODDING-WORKFLOW.md` §4C, or by grepping for `^\s*@(wrapMethod|replaceMethod|addMethod|addField)`.

## Wrapped methods (highest patch risk)

| Class | Method | Location |
|---|---|---|
| `CraftingMainGameController` | `OnCraftingComplete` | `PreemMainUI/PreemWeaponPreviewContainer.reds:252` |
| `CraftingMainGameController` | `OnInitialize` | `PreemMainUI/PreemWeaponPreviewContainer.reds:69` |
| `CraftingMainGameController` | `OnUninitialize` | `PreemMainUI/PreemWeaponPreviewContainer.reds:134` |
| `CraftingMainLogicController` | `OnPressSelectedItem` | `PreemMainUI/PreemWeaponPreviewContainer.reds:303` |
| `CraftingSystem` | `CanItemBeCrafted` | `Adapters/PreemCraftingSystemAdapter.reds:103` |
| `CraftingSystem` | `CanItemBeCrafted` | `Adapters/PreemCraftingSystemAdapter.reds:127` |
| `CraftingSystem` | `CraftItem` | `Adapters/PreemCraftingSystemAdapter.reds:26` |
| `CraftingSystem` | `EnoughIngredientsForCrafting` | `Adapters/PreemCraftingSystemAdapter.reds:152` |
| `InventoryDataManagerV2` | `GetAttachmentSlotsForInventory` | `Adapters/PreemInventoryAdapter.reds:5` |
| `InventoryDataManagerV2` | `IsAttachmentDedicated` | `Adapters/PreemInventoryAdapter.reds:22` |
| `MaterialTooltip` | `SetData` | `PreemMainUI/PreemWeaponPreviewContainer.reds:532` |
| `MeleeAttackGenericEvents` | `SpawnAttackGameEffect` | `Adapters/PreemWeaponAdapter.reds:213` |
| `MeleeSprintAttackEvents` | `OnEnter` | `Adapters/PreemWeaponAdapter.reds:230` |
| `UIInventoryItemModsStaticData` | `GetAttachmentSlots` | `Adapters/PreemInventoryAdapter.reds:27` |
| `UIInventoryItemModsStaticData` | `IsAttachmentDedicated` | `Adapters/PreemInventoryAdapter.reds:44` |
| `WeaponObject` | `OnGameAttached` | `Adapters/PreemWeaponAdapter.reds:139` |
| `WeaponTransition` | `GetDesiredAttackRecord` | `Adapters/PreemWeaponAdapter.reds:172` |
| `WeaponTransition` | `IsPrimaryTriggerModeActive` | `Adapters/PreemWeaponAdapter.reds:199` |
| `WeaponTransition` | `SwitchTriggerMode` | `Adapters/PreemWeaponAdapter.reds:155` |

There are no live `@replaceMethod` hooks (older ones are commented out in `Adapters/PreemWeaponAdapter.reds`).

## Added methods and fields (lower risk: only break if the class itself is renamed or removed)

| Annotation | Member | Location |
|---|---|---|
| `@addField(CraftingMainGameController)` | `_barrelSlot1` | `PreemMainUI/PreemWeaponPreviewContainer.reds:17` |
| `@addField(CraftingMainGameController)` | `_barrelSlot2` | `PreemMainUI/PreemWeaponPreviewContainer.reds:20` |
| `@addField(CraftingMainGameController)` | `_bladeSlot1` | `PreemMainUI/PreemWeaponPreviewContainer.reds:29` |
| `@addField(CraftingMainGameController)` | `_bladeSlot2` | `PreemMainUI/PreemWeaponPreviewContainer.reds:32` |
| `@addField(CraftingMainGameController)` | `_handleSlot1` | `PreemMainUI/PreemWeaponPreviewContainer.reds:35` |
| `@addField(CraftingMainGameController)` | `_handleSlot2` | `PreemMainUI/PreemWeaponPreviewContainer.reds:38` |
| `@addField(CraftingMainGameController)` | `_magSlot1` | `PreemMainUI/PreemWeaponPreviewContainer.reds:23` |
| `@addField(CraftingMainGameController)` | `_magSlot2` | `PreemMainUI/PreemWeaponPreviewContainer.reds:26` |
| `@addField(CraftingMainGameController)` | `_preemContainer` | `PreemMainUI/PreemWeaponPreviewContainer.reds:56` |
| `@addField(CraftingMainGameController)` | `_preemContainer2` | `PreemMainUI/PreemWeaponPreviewContainer.reds:59` |
| `@addField(CraftingMainGameController)` | `_preemGridMelee` | `PreemMainUI/PreemWeaponPreviewContainer.reds:44` |
| `@addField(CraftingMainGameController)` | `_preemGridRanged` | `PreemMainUI/PreemWeaponPreviewContainer.reds:41` |
| `@addField(CraftingMainGameController)` | `_preemModMapper` | `PreemMainUI/PreemWeaponPreviewContainer.reds:62` |
| `@addField(CraftingMainGameController)` | `_preemModSlotManager` | `PreemMainUI/PreemWeaponPreviewContainer.reds:53` |
| `@addField(CraftingMainGameController)` | `_preemModUnlocker` | `PreemMainUI/PreemWeaponPreviewContainer.reds:65` |
| `@addField(CraftingMainGameController)` | `_preemPopupGrid` | `PreemMainUI/PreemWeaponPreviewContainer.reds:47` |
| `@addField(CraftingMainGameController)` | `_triggerSlot1` | `PreemMainUI/PreemWeaponPreviewContainer.reds:11` |
| `@addField(CraftingMainGameController)` | `_triggerSlot2` | `PreemMainUI/PreemWeaponPreviewContainer.reds:14` |
| `@addField(MaterialTooltipData)` | `preemModDescription` | `PreemMainUI/PreemWeaponPreviewContainer.reds:529` |
| `@addMethod(CraftingMainGameController)` | `ClearMods` | `PreemMainUI/PreemWeaponPreviewContainer.reds:261` |
| `@addMethod(CraftingMainGameController)` | `CreateMeleeWeaponPreemFrame` | `PreemMainUI/PreemWeaponPreviewContainer.reds:101` |
| `@addMethod(CraftingMainGameController)` | `CreatePreemModItemFromPreemMod` | `PreemMainUI/PreemWeaponPreviewContainer.reds:187` |
| `@addMethod(CraftingMainGameController)` | `CreatePreemModItems` | `PreemMainUI/PreemWeaponPreviewContainer.reds:172` |
| `@addMethod(CraftingMainGameController)` | `CreatePreemPopupGrid` | `PreemMainUI/PreemWeaponPreviewContainer.reds:142` |
| `@addMethod(CraftingMainGameController)` | `CreateRangedWeaponPreemFrame` | `PreemMainUI/PreemWeaponPreviewContainer.reds:82` |
| `@addMethod(CraftingMainGameController)` | `CreateUIPreemSlotDataForMelee` | `PreemMainUI/PreemWeaponPreviewContainer.reds:474` |
| `@addMethod(CraftingMainGameController)` | `CreateUIPreemSlotDataForRanged` | `PreemMainUI/PreemWeaponPreviewContainer.reds:444` |
| `@addMethod(CraftingMainGameController)` | `CreateUIPreemSlotsForMelee` | `PreemMainUI/PreemWeaponPreviewContainer.reds:404` |
| `@addMethod(CraftingMainGameController)` | `CreateUIPreemSlotsForRanged` | `PreemMainUI/PreemWeaponPreviewContainer.reds:345` |
| `@addMethod(CraftingMainGameController)` | `OnPreemModHoverOutCallBack` | `PreemMainUI/PreemWeaponPreviewContainer.reds:575` |
| `@addMethod(CraftingMainGameController)` | `OnPreemModHoverOverCallBack` | `PreemMainUI/PreemWeaponPreviewContainer.reds:520` |
| `@addMethod(CraftingMainGameController)` | `OnPreemModSelectedCallBack` | `PreemMainUI/PreemWeaponPreviewContainer.reds:222` |
| `@addMethod(CraftingMainGameController)` | `OnPreemSlotClickedCallBack` | `PreemMainUI/PreemWeaponPreviewContainer.reds:211` |
| `@addMethod(CraftingMainGameController)` | `ProcessPreemModSelection` | `PreemMainUI/PreemWeaponPreviewContainer.reds:228` |
| `@addMethod(CraftingMainGameController)` | `SetMeleeSlotsOnPreemModSlotManager` | `PreemMainUI/PreemWeaponPreviewContainer.reds:509` |
| `@addMethod(CraftingMainGameController)` | `SetRangedSlotsOnPreemModSlotManager` | `PreemMainUI/PreemWeaponPreviewContainer.reds:496` |
| `@addMethod(CraftingMainGameController)` | `SetWeaponPreemFrameToMelee` | `PreemMainUI/PreemWeaponPreviewContainer.reds:124` |
| `@addMethod(CraftingMainGameController)` | `SetWeaponPreemFrameToRanged` | `PreemMainUI/PreemWeaponPreviewContainer.reds:114` |
| `@addMethod(CraftingSystem)` | `InstallPreemMod` | `Adapters/PreemCraftingSystemAdapter.reds:6` |
| `@addMethod(WeaponObject)` | `ChangeTriggerBasedOnPreemMods` | `Adapters/PreemWeaponAdapter.reds:4` |
| `@addMethod(WeaponObject)` | `ConvertTriggerModeToActual` | `Adapters/PreemWeaponAdapter.reds:94` |
| `@addMethod(WeaponObject)` | `GetAttackBasedOnPreemMods` | `Adapters/PreemWeaponAdapter.reds:32` |
| `@addMethod(WeaponObject)` | `GetEvolutionBasedOnPreemMods` | `Adapters/PreemWeaponAdapter.reds:120` |
| `@addMethod(WeaponObject)` | `GetTriggerTypeBasedOnPreemMods` | `Adapters/PreemWeaponAdapter.reds:58` |
| `@addMethod(gameItemData)` | `DoesItemHaveBoosterHandle` | `Adapters/ItemDataAdapter.reds:83` |
| `@addMethod(gameItemData)` | `DoesItemHavePowerBarrel` | `Adapters/ItemDataAdapter.reds:53` |
| `@addMethod(gameItemData)` | `DoesItemHavePreemMod` | `Adapters/ItemDataAdapter.reds:19` |
| `@addMethod(gameItemData)` | `DoesItemHaveSilencer` | `Adapters/ItemDataAdapter.reds:67` |
| `@addMethod(gameItemData)` | `DoesItemHaveSmartBarrel` | `Adapters/ItemDataAdapter.reds:5` |
| `@addMethod(gameItemData)` | `DoesItemHaveTechBarrel` | `Adapters/ItemDataAdapter.reds:39` |
