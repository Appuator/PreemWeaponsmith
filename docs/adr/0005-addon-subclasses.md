# ADR 0005: Add-ons are `PreemAddon` subclasses that core finds itself

- Status: accepted (2026-10-28, building Phase 10). Supersedes [ADR 0004](0004-addon-extension-points.md) on how an add-on plugs in; its enum-value and release-order decisions stand.

## Context
ADR 0004 chose empty static hook points on `PreemAddons` for add-ons to `@wrapMethod`. Building them showed redscript 0.5.32 can't do that: `@wrapMethod` only finds classes from the game's script bundle. On a class compiled with the mods it reports "no method with this name exists on the target type" (same file), crashes the compiler with "constant pool error: definition not found" (separate file), and a module-qualified target is "invalid arguments for annotation". Core and every add-on compile in the same pass, so add-ons can't wrap core's hook points, nor core's internal methods (ADR 0004's first option). The options left were:
- **Self-registering services:** each add-on is a Codeware `ScriptableService` that hands an object to a core registry when it starts. Works, but depends on service start order and needs registry storage: the cost ADR 0004 turned down.
- **Subclasses core finds:** core defines an abstract class with empty overridable methods; an add-on extends it; core lists the subclasses with Codeware's `Reflection.GetDerivedClasses` and asks each one.

## Decision
(user, 2026-10-28) Subclasses. `PreemCrafting.Addons` has `PreemAddon` (overridable `RequiredApiVersion`, `GetStyles(classType)`, `DefineMod(style, mod)`, `MapItem(style)`, and the unlock tier in the next task) and `PreemAddons` (the `ApiVersion`, and the static calls core makes, which ask every add-on). `PreemAddonRegistry`, a Codeware `ScriptableService`, finds the subclasses once on first use and keeps one instance of each. Core asks add-ons only where it has no answer of its own (a style it doesn't list, define or map), so an add-on can't change a core mod.

## Consequences
- No load order and no `wrappedMethod` chain: several add-ons don't interfere, and one that forgets something can't break another.
- The `PreemAddon` methods are the public API (what ADR 0004 said of the hook points): a change bumps `ApiVersion` and goes in the CHANGELOG. An add-on that needs a newer API than the installed core is skipped with a log line instead of misbehaving.
- Core depends on Codeware's reflection for this (Codeware is already required).
- An add-on keeps any state of its own outside its `PreemAddon` instance or in it; the registry keeps that one instance for the game session.
