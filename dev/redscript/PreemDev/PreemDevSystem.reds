// Dev only, never shipped. Installed by tools/dev-install.ps1.
// A ScriptableSystem is created by the game's ScriptableSystemsContainer when the game instance
// starts its systems. OnAttach logs that moment (answering when it happens, HANDOFF §5) and sets
// up RedTest, which runs the tests on the pre-game "Session/Ready" event (the main menu). It also
// runs the TweakDB self-check (SelfCheck/PreemSelfCheck.reds) when the mod is installed.
// Test results go to CET's Game Log (gamelog.log, written when the game exits); the boot check
// reads them.
module PreemDev

import PreemDev.Tests.*
import PreemDev.SelfCheck.*

public class PreemDevSystem extends ScriptableSystem {
  private let m_runner: ref<RedTest>;
  // The weapon the crafting debug commands (PreemDebug.reds) work on.
  public let lastTestItem: ItemID;

  private func OnAttach() {
    FTLog("[PreemDev] PreemDevSystem attached");
    // redscript 0.5 won't widen an array literal of a subclass, so build the array by hand.
    let tests: array<ref<BaseTest>>;
    ArrayPush(tests, new PreemDevSmokeTest());
    for test in PreemModTests() {
      ArrayPush(tests, test);
    }
    for test in PreemSettingsTests() {
      ArrayPush(tests, test);
    }
    this.m_runner = new RedTest();
    this.m_runner.Setup("PreemWeaponsmith", tests);
    PreemRunSelfCheck();
  }

  private func OnDetach() {
    this.m_runner.TearDown();
  }
}
