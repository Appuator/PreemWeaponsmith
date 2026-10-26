# Dev only. Phase 3 event map (notes/audioware-sounds.md): per player sound set, which fire-mode
# fields the old .archive fills and which vanilla 2.5 already has, plus the weapons using the set.
#   python -I event-map.py <vanilla-base.json> <vanilla-ep1.json> <mod-base.json> <mod-ep1.json> <weapon-dump.txt>
# The JSON files come from `WolvenKit.CLI convert serialize` of cooked_metadata.audio_metadata
# (vanilla from audio_1_general.archive / ep1_2_gamedata.archive, mod from wolvenkit/source/archive);
# the weapon dump from dev/cet/weapon-dump.lua (tools/variant-markers.ps1 keeps it in the log folder).
# Prints tab-separated rows: kind, sound set, field, vanilla 2.5 value, archive value, weapons.
import json, re, sys
from collections import defaultdict

FIELDS = ["fireSound", "autoFireSound", "autoFireStop", "burstFireSound", "chargeStartSound",
          "chargeReadySound", "perfectChargePerkSounds.perfectChargeChargedSound",
          "perfectChargePerkSounds.perfectChargeChargingSound",
          "perfectChargePerkSounds.perfectChargeShootingSound"]

def norm(v):
    if isinstance(v, dict):
        if "$storage" in v:
            x = v.get("$value"); return "" if x in (None, "None") else x
        if "Data" in v and "HandleId" in v: return norm(v["Data"])
        return {k: norm(x) for k, x in v.items() if k != "HandleId"}
    if isinstance(v, list): return [norm(x) for x in v]
    return v

def collect(paths):
    players, groups = {}, {}
    def walk(o):
        if isinstance(o, dict):
            d = o.get("Data") if isinstance(o.get("Data"), dict) else o
            t = d.get("$type")
            if t == "audioPlayerWeaponSettings":
                n = norm(d); players[n["name"]] = n
            elif t == "audioWeaponSettingsGroup":
                n = norm(d); groups[n["name"]] = n
            for x in o.values(): walk(x)
        elif isinstance(o, list):
            for x in o: walk(x)
    for p in paths: walk(json.load(open(p, encoding="utf-8")))
    return players, groups

def field(s, f):
    for part in f.split("."):
        s = s.get(part) if isinstance(s, dict) else None
    return s if s not in (None, 0, "0") else ""

van, groups = collect(sys.argv[1:3])
mod, _ = collect(sys.argv[3:5])

# Sound set (player settings name) -> weapon records using it (Items.Preset_* only, no Preem variants).
weapons = defaultdict(set)
pat = re.compile(r'^(Items\.Preset_[A-Za-z0-9_]+)\.audioName = n"([^"]+)"')
for line in open(sys.argv[5], encoding="utf-8", errors="replace"):
    m = pat.match(line)
    if not m or "_Preem" in m.group(1): continue
    g = groups.get(m.group(2))
    if not g: continue
    short = m.group(1)[len("Items.Preset_"):]
    for key in ("playerSettings", "playerSilenced"):
        if g.get(key): weapons[g[key]].add(short)

def weapon_list(name):
    w = sorted(weapons.get(name, ()))
    return f"{len(w)}: " + ", ".join(w[:4]) + (" ..." if len(w) > 4 else "")

for name in sorted(van):
    for f in FIELDS:
        a, b = field(van[name], f), field(mod.get(name, {}), f)
        if a == b:
            kind = "vanilla" if a else ("empty" if f != "fireSound" else "no-fire")
        else:
            kind = "fill" if not a else ("clear" if not b else "overwrite")
        print("\t".join([kind, name, f, a, b, weapon_list(name)]))
