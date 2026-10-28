# Pester 3.4 (the copy that ships with Windows): pwsh -c "Invoke-Pester tools/tests"
# Hand-made logs in the format of the 2026-10-26 20:17 sweep (scripting.log rows from
# dev/cet/sound-sweep.lua, gamelog.log lines from PreemSoundListener.reds).
Import-Module (Join-Path $PSScriptRoot '..\SoundSweepLog.psm1') -Force

$known = @(@{ Weapon = 'Items.Preset_Ashura_Default'; Expect = 'w_gun_smg_smart_sidewinder_fire_auto'; Why = '1-round magazine' })

# An earlier, shorter run (row 1 only), then the run under test: rows 1-4, 9 s apart.
$script = @(
  '[2026-10-26 19:58:03 UTC-07:00] [86316] [PreemSweep] 1 wea_pla_ajax Items.Preset_Ajax_Default expect w_gun_rifle_power_masamune_fire_burst'
  '[2026-10-26 20:17:05 UTC-07:00] [71840] [PreemSweep] 1 wea_pla_ajax Items.Preset_Ajax_Default expect w_gun_rifle_power_masamune_fire_burst'
  '[2026-10-26 20:17:14 UTC-07:00] [71840] [PreemSweep] 2 wea_pla_ajax_suppressor Items.Preset_Ajax_Default expect w_gun_rifle_power_masamune_fire_suppressor_burst'
  '[2026-10-26 20:17:23 UTC-07:00] [71840] [PreemSweep] 3 wea_pla_ashura Items.Preset_Ashura_Default expect w_gun_smg_smart_sidewinder_fire_auto'
  '[2026-10-26 20:17:32 UTC-07:00] [71840] [PreemSweep] 4 wea_pla_borg4a Items.Preset_Borg4a_Default expect w_gun_ticon_fire_burst'
  'some other CET line'
)
$game = @(
  # Earlier run: must not count for the later run's row 1.
  "[2026-10-26 19:58:10 UTC-07:00] [77420] [PreemDev] sound: w_gun_rifle_power_masamune_fire_burst on player's weapon Items.Preset_Ajax_Default"
  # Row 1: two hits on the player's weapon.
  "[2026-10-26 20:17:12 UTC-07:00] [71840] [PreemDev] sound: fire Items.Preset_Ajax_Default mode=Burst"
  "[2026-10-26 20:17:12 UTC-07:00] [77420] [PreemDev] sound: w_gun_rifle_power_masamune_fire_burst on player's weapon Items.Preset_Ajax_Default"
  "[2026-10-26 20:17:13 UTC-07:00] [77420] [PreemDev] sound: w_gun_rifle_power_masamune_fire_burst on player's weapon Items.Preset_Ajax_Default"
  # Row 2: the unsuppressed event and an NPC's suppressed one only, so it fails.
  "[2026-10-26 20:17:21 UTC-07:00] [77420] [PreemDev] sound: w_gun_rifle_power_masamune_fire_burst on player's weapon Items.Preset_Ajax_Default"
  "[2026-10-26 20:17:21 UTC-07:00] [77420] [PreemDev] sound: w_gun_rifle_power_masamune_fire_suppressor_burst on entity dynamic: '10005329'"
  # Row 3: Ashura plays nothing (known miss).
  # Row 4: the expected event, but on another record, then on the right one.
  "[2026-10-26 20:17:39 UTC-07:00] [77420] [PreemDev] sound: w_gun_ticon_fire_burst on player's weapon Items.Preset_Ashura_Default"
  "[2026-10-26 20:17:40 UTC-07:00] [77420] [PreemDev] sound: w_gun_ticon_fire_burst on player's weapon Items.Preset_Borg4a_Default"
  # Row 1's event again, now inside row 4's window: counts for neither.
  "[2026-10-26 20:17:40 UTC-07:00] [77420] [PreemDev] sound: w_gun_rifle_power_masamune_fire_burst on player's weapon Items.Preset_Ajax_Default"
)

Describe 'Get-SoundSweepReport' {
  $r = Get-SoundSweepReport -ScriptLines $script -GameLines $game -KnownMisses $known

  It 'finds every run and reports the last one' {
    @($r.Runs).Count | Should Be 2
    $r.Runs[0].Start | Should Be ([datetime]'2026-10-26 19:58:03')
    $r.Runs[0].Rows | Should Be 1
    $r.Runs[1].Rows | Should Be 4
    $r.Run | Should Be 2
    @($r.Rows).Count | Should Be 4
  }
  It 'passes a row whose expected event played on its weapon, counting only its own window' {
    $r.Rows[0].Status | Should Be 'pass'
    $r.Rows[0].Count | Should Be 2
  }
  It 'fails a row when the event played only on another entity' {
    $r.Rows[1].Status | Should Be 'fail'
    $r.Rows[1].Count | Should Be 0
  }
  It 'marks a known miss that played nothing' {
    $r.Rows[2].Status | Should Be 'known miss'
    $r.Rows[2].Note | Should Be '1-round magazine'
  }
  It 'counts only lines on the row''s own weapon record' {
    $r.Rows[3].Status | Should Be 'pass'
    $r.Rows[3].Count | Should Be 1
  }
  It 'reports an earlier run when asked' {
    $first = Get-SoundSweepReport -ScriptLines $script -GameLines $game -KnownMisses $known -Run 1
    @($first.Rows).Count | Should Be 1
    $first.Rows[0].Status | Should Be 'pass'
    $first.Rows[0].Count | Should Be 1
  }
  It 'passes a known-miss row that did play' {
    $played = $game + "[2026-10-26 20:17:30 UTC-07:00] [77420] [PreemDev] sound: w_gun_smg_smart_sidewinder_fire_auto on player's weapon Items.Preset_Ashura_Default"
    (Get-SoundSweepReport -ScriptLines $script -GameLines $played -KnownMisses $known).Rows[2].Status | Should Be 'pass'
  }
  It 'returns no runs for a log without sweep rows' {
    @((Get-SoundSweepReport -ScriptLines @('nothing') -GameLines $game -KnownMisses $known).Runs).Count | Should Be 0
  }
}
