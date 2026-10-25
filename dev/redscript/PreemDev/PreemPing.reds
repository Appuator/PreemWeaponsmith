// Dev only, never shipped. Type Game.PreemPing() in the CET console: it prints "pong" there.
// An exec function is a global function whose first parameter is the GameInstance; CET exposes
// it as Game.<Name>(). CET finds it only by its bare name, so this file has no `module` line
// (a module would make the name PreemDev.PreemPing). Print (Codeware) writes to the CET
// console and its scripting.log, and to gamelog.log.
public static exec func PreemPing(gi: GameInstance) -> Void {
  Print("[PreemDev] pong");
}
