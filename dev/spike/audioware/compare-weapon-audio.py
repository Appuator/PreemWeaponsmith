# Dev only. Phase 3 spike (notes/audioware-sounds.md): compares the audioPlayerWeaponSettings
# entries of two cooked_metadata.audio_metadata files serialized to JSON by
# `WolvenKit.CLI convert serialize`, and prints one tab-separated line per differing field:
#   python -I compare-weapon-audio.py <old.json> <new.json>
# Lines read `<settings name> <field> vanilla25=<new value> old=<old value>`; 0 means unset.
import json, sys
def norm(v):
    if isinstance(v, dict):
        if v.get("$type") in ("CName", "ResourcePath") or "$storage" in v:
            x = v.get("$value"); return 0 if x in (None, "None", "") else x
        if "Data" in v and "HandleId" in v: return norm(v["Data"])
        return {k: norm(x) for k, x in v.items() if k not in ("HandleId",)}
    if isinstance(v, list): return [norm(x) for x in v]
    return v
def collect(path):
    out = {}
    def walk(o):
        if isinstance(o, dict):
            d = o.get("Data") if isinstance(o.get("Data"), dict) else o
            if d.get("$type") == "audioPlayerWeaponSettings":
                n = norm(d); out[n["name"]] = n
            for x in o.values(): walk(x)
        elif isinstance(o, list):
            for x in o: walk(x)
    walk(json.load(open(path, encoding="utf-8")))
    return out
old, new = collect(sys.argv[1]), collect(sys.argv[2])
print("old", len(old), "new", len(new))
print("only in old:", sorted(set(old) - set(new)))
print("only in new:", sorted(set(new) - set(old)))
def flat(d, p=""):
    r = {}
    for k, v in d.items():
        if isinstance(v, dict): r.update(flat(v, p + k + "."))
        else: r[p + k] = v
    return r
for name in sorted(set(old) & set(new)):
    fo, fn = flat(old[name]), flat(new[name])
    diffs = [(k, fn.get(k), fo.get(k)) for k in sorted(set(fo) | set(fn)) if fo.get(k) != fn.get(k)]
    for k, a, b in diffs: print(f"{name}\t{k}\tvanilla25={a}\told={b}")
