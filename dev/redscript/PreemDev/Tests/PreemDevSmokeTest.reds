// Proves the RedTest harness runs and reports. Real rule tests come in Phase 1.
module PreemDev.Tests

public class PreemDevSmokeTest extends BaseTest {
  public func Create() {
    this.m_modName = "PreemWeaponsmith";
    this.m_name = "Smoke";
  }

  private cb func Test_HarnessRuns() {
    this.ExpectInt32("2 + 2 == 4", 2 + 2, 4);
  }
}
