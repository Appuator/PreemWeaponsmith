# Game hooks

Every live annotation in `src/redscript/PreemWeaponsmith` that touches a game class. Re-check this list after every game patch: compile errors catch renamed or removed methods, but a wrapped method whose logic changed still compiles.

Regenerate with the command in `docs/MODDING-WORKFLOW.md` §4C, or by grepping for `^\s*@(wrapMethod|replaceMethod|addMethod|addField)`.

## Wrapped methods (highest patch risk)

| Class | Method | Location |
|---|---|---|
| `CraftingMainGameController` | `OnCraftingComplete` | `PreemMainUI/PreemWeaponPreviewContainer.reds:250` |
| `CraftingMainGameController` | `OnInitialize` | `PreemMainUI/PreemWeaponPreviewContainer.reds:67` |
| `CraftingMainGameController` | `OnUninitialize` | `PreemMainUI/PreemWeaponPreviewContainer.reds:132` |
| `CraftingMainLogicController` | `OnPressSelectedItem` | `PreemMainUI/PreemWeaponPreviewContainer.reds:271` |
| `CraftingSystem` | `CanItemBeCrafted` | `Adapters/PreemCraftingSystemAdapter.reds:103` |
| `CraftingSystem` | `CanItemBeCrafted` | `Adapters/PreemCraftingSystemAdapter.reds:127` |
| `CraftingSystem` | `CraftItem` | `Adapters/PreemCraftingSystemAdapter.reds:26` |
| `CraftingSystem` | `EnoughIngredientsForCrafting` | `Adapters/PreemCraftingSystemAdapter.reds:152` |
| `InventoryDataManagerV2` | `GetAttachmentSlotsForInventory` | `Adapters/PreemInventoryAdapter.reds:5` |
| `InventoryDataManagerV2` | `IsAttachmentDedicated` | `Adapters/PreemInventoryAdapter.reds:22` |
| `MaterialTooltip` | `SetData` | `PreemMainUI/PreemWeaponPreviewContainer.reds:487` |
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
| `@addField(CraftingMainGameController)` | `_barrelSlot1` | `PreemMainUI/PreemWeaponPreviewContainer.reds:17` |
| `@addField(CraftingMainGameController)` | `_barrelSlot2` | `PreemMainUI/PreemWeaponPreviewContainer.reds:20` |
| `@addField(CraftingMainGameController)` | `_bladeSlot1` | `PreemMainUI/PreemWeaponPreviewContainer.reds:29` |
| `@addField(CraftingMainGameController)` | `_bladeSlot2` | `PreemMainUI/PreemWeaponPreviewContainer.reds:32` |
| `@addField(CraftingMainGameController)` | `_handleSlot1` | `PreemMainUI/PreemWeaponPreviewContainer.reds:35` |
| `@addField(CraftingMainGameController)` | `_handleSlot2` | `PreemMainUI/PreemWeaponPreviewContainer.reds:38` |
| `@addField(CraftingMainGameController)` | `_magSlot1` | `PreemMainUI/PreemWeaponPreviewContainer.reds:23` |
| `@addField(CraftingMainGameController)` | `_magSlot2` | `PreemMainUI/PreemWeaponPreviewContainer.reds:26` |
| `@addField(CraftingMainGameController)` | `_preemContainer` | `PreemMainUI/PreemWeaponPreviewContainer.reds:54` |
| `@addField(CraftingMainGameController)` | `_preemContainer2` | `PreemMainUI/PreemWeaponPreviewContainer.reds:57` |
| `@addField(CraftingMainGameController)` | `_preemGridMelee` | `PreemMainUI/PreemWeaponPreviewContainer.reds:44` |
| `@addField(CraftingMainGameController)` | `_preemGridRanged` | `PreemMainUI/PreemWeaponPreviewContainer.reds:41` |
| `@addField(CraftingMainGameController)` | `_preemModMapper` | `PreemMainUI/PreemWeaponPreviewContainer.reds:60` |
| `@addField(CraftingMainGameController)` | `_preemModSlotManager` | `PreemMainUI/PreemWeaponPreviewContainer.reds:51` |
| `@addField(CraftingMainGameController)` | `_preemModUnlocker` | `PreemMainUI/PreemWeaponPreviewContainer.reds:63` |
| `@addField(CraftingMainGameController)` | `_preemPopupGrid` | `PreemMainUI/PreemWeaponPreviewContainer.reds:47` |
| `@addField(CraftingMainGameController)` | `_triggerSlot1` | `PreemMainUI/PreemWeaponPreviewContainer.reds:11` |
| `@addField(CraftingMainGameController)` | `_triggerSlot2` | `PreemMainUI/PreemWeaponPreviewContainer.reds:14` |
| `@addField(MaterialTooltipData)` | `preemModDescription` | `PreemMainUI/PreemWeaponPreviewContainer.reds:484` |
| `@addMethod(CraftingMainGameController)` | `ClearMods` | `PreemMainUI/PreemWeaponPreviewContainer.reds:259` |
| `@addMethod(CraftingMainGameController)` | `CreateMeleeWeaponPreemFrame` | `PreemMainUI/PreemWeaponPreviewContainer.reds:99` |
| `@addMethod(CraftingMainGameController)` | `CreatePreemModItemFromPreemMod` | `PreemMainUI/PreemWeaponPreviewContainer.reds:185` |
| `@addMethod(CraftingMainGameController)` | `CreatePreemModItems` | `PreemMainUI/PreemWeaponPreviewContainer.reds:170` |
| `@addMethod(CraftingMainGameController)` | `CreatePreemPopupGrid` | `PreemMainUI/PreemWeaponPreviewContainer.reds:140` |
| `@addMethod(CraftingMainGameController)` | `CreateRangedWeaponPreemFrame` | `PreemMainUI/PreemWeaponPreviewContainer.reds:80` |
| `@addMethod(CraftingMainGameController)` | `CreateUIPreemSlotDataForMelee` | `PreemMainUI/PreemWeaponPreviewContainer.reds:429` |
| `@addMethod(CraftingMainGameController)` | `CreateUIPreemSlotDataForRanged` | `PreemMainUI/PreemWeaponPreviewContainer.reds:399` |
| `@addMethod(CraftingMainGameController)` | `CreateUIPreemSlotsForMelee` | `PreemMainUI/PreemWeaponPreviewContainer.reds:359` |
| `@addMethod(CraftingMainGameController)` | `CreateUIPreemSlotsForRanged` | `PreemMainUI/PreemWeaponPreviewContainer.reds:300` |
| `@addMethod(CraftingMainGameController)` | `OnPreemModHoverOutCallBack` | `PreemMainUI/PreemWeaponPreviewContainer.reds:530` |
| `@addMethod(CraftingMainGameController)` | `OnPreemModHoverOverCallBack` | `PreemMainUI/PreemWeaponPreviewContainer.reds:475` |
| `@addMethod(CraftingMainGameController)` | `OnPreemModSelectedCallBack` | `PreemMainUI/PreemWeaponPreviewContainer.reds:220` |
| `@addMethod(CraftingMainGameController)` | `OnPreemSlotClickedCallBack` | `PreemMainUI/PreemWeaponPreviewContainer.reds:209` |
| `@addMethod(CraftingMainGameController)` | `ProcessPreemModSelection` | `PreemMainUI/PreemWeaponPreviewContainer.reds:226` |
| `@addMethod(CraftingMainGameController)` | `SetMeleeSlotsOnPreemModSlotManager` | `PreemMainUI/PreemWeaponPreviewContainer.reds:464` |
| `@addMethod(CraftingMainGameController)` | `SetRangedSlotsOnPreemModSlotManager` | `PreemMainUI/PreemWeaponPreviewContainer.reds:451` |
| `@addMethod(CraftingMainGameController)` | `SetWeaponPreemFrameToMelee` | `PreemMainUI/PreemWeaponPreviewContainer.reds:122` |
| `@addMethod(CraftingMainGameController)` | `SetWeaponPreemFrameToRanged` | `PreemMainUI/PreemWeaponPreviewContainer.reds:112` |
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
