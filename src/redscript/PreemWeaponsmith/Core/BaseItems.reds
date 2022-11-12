module PreemCrafting.Core

public class PreemSlot{
    public let slottedMod: ref<PreemMod>;
    public let slotID: TweakDBID;
    public let slotName: CName;
    public let isEmptySlot: Bool = true;
    public let preemClassType: PreemModClassType;

    public func GetSlottedMod() -> ref<PreemMod>
    {
        return this.slottedMod;
    }

    public func SetSlottedMod(preemMod: ref<PreemMod>) -> Void
    {
        this.slottedMod = preemMod;
    }

    public func GetSlotID() -> TweakDBID
    {
        return this.slotID;
    }

    public func SetSlotID(slotID: TweakDBID) -> Void
    {
        this.slotID = slotID;
    }

    public func SetSlotName(name: CName) -> Void
    {
        this.slotName = name;
    }

    public func GetSlotName() -> CName
    {
        return this.slotName;
    }


    public func InstallMod(preemMod: ref<PreemMod>) -> Void
    {
        this.SetSlottedMod(preemMod);
        if IsDefined(this.slottedMod)
        {
            this.isEmptySlot = true;
        }
        else
        {
            this.isEmptySlot = false;
        }
    }
}

public class PreemStats{
    public let preemStatType: PreemStatType;
    public let preemStatValue: Float;
}

public class PreemMod
{
    public let nativeStatModifiers: array<ref<gameStatModifierData>>;
    public let preemStatModifiers: array<ref<PreemStats>>;
    public let preemClassType: PreemModClassType;
    public let modStyleType: PreemModStyleType;
    public let modName: CName;
    public let modID: TweakDBID;
    public let requiredMods: array<PreemModStyleType>;
    public let requiredEvolution: gamedataWeaponEvolution = gamedataWeaponEvolution.Invalid;
    public let incompatMods: array<PreemModStyleType>;
    public let isSelected: Bool = false;
    public let description: String;
    public let additionalDescription: String;

    public func GetModID() -> TweakDBID
    {
        return this.modID;
    }

    public func SetModID(preemModID: TweakDBID) -> Void
    {
        this.modID = preemModID;
    }

    public func SetModName(name: CName) -> Void
    {
        this.modName = name;
    }

    public func GetModName() -> CName
    {
        return this.modName;
    }

    public func AddRequiredMod(preemModStyle: PreemModStyleType) -> Void
    {
        ArrayPush(this.requiredMods, preemModStyle);
    }

    public func GetRequiredMods() -> array<PreemModStyleType>
    {
        return this.requiredMods;
    }

    public func SetRequiredEvolution(preemModEvo: gamedataWeaponEvolution) -> Void
    {
        this.requiredEvolution = preemModEvo;
    }

    public func GetRequiredEvolution() -> gamedataWeaponEvolution
    {
        return this.requiredEvolution;
    }

    public func AddIncompatMod(preemModStyle: PreemModStyleType) -> Void
    {
        ArrayPush(this.incompatMods, preemModStyle);
    }

    public func GetIncompatMods() -> array<PreemModStyleType>
    {
        return this.incompatMods;
    }

    public static func GetModTypes(modList: array<ref<PreemMod>>) -> array<PreemModStyleType>
    {
        let modStyleList: array<PreemModStyleType>;
        for mod in modList
        {
            ArrayPush(modStyleList, mod.modStyleType);
        }

        return modStyleList;
    }

    public func GetAdditionalDescription() -> String
    {
        return this.additionalDescription;
    }

    public func SetAdditionalDescription(addDesc: String) -> Void
    {
        this.additionalDescription = addDesc;
    }

    public func GetDescription() -> String
    {
        return this.description;
    }

    public func SetDescription(desc: String) -> Void
    {
        this.description = desc;
    }
}