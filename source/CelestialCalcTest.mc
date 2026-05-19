import Toybox.Test;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;

// Unit tests for CelestialCalc moon calculations.
// Run with: monkeyc --unit-test -d fenix7

// ── Julian day tests ──────────────────────────────────────────────────────────

(:test)
function testJulianDay2000Jan15(logger as Test.Logger) as Boolean {
    return julianDay(2000, 1, 15) == 2451559;
}

(:test)
function testJulianDay2024Jun21(logger as Test.Logger) as Boolean {
    return julianDay(2024, 6, 21) == 2460482;
}

(:test)
function testJulianDay2025Jan1(logger as Test.Logger) as Boolean {
    return julianDay(2025, 1, 1) == 2460668;
}

// ── Moon illumination % tests ──────────────────────────────────────────────────
// Known new moons: 2024-01-11, 2024-02-10, 2025-01-29
// Known full moons: 2024-01-25, 2024-06-22

(:test)
function testMoonIlluminationNewMoon(logger as Test.Logger) as Boolean {
    var illum = moonIlluminationPercent(2024, 1, 11);
    return illum >= 0 && illum <= 3;
}

(:test)
function testMoonIlluminationFullMoon(logger as Test.Logger) as Boolean {
    var illum = moonIlluminationPercent(2024, 6, 22);
    return illum >= 97 && illum <= 100;
}

(:test)
function testMoonIlluminationQuarter(logger as Test.Logger) as Boolean {
    var illum = moonIlluminationPercent(2024, 6, 14);
    return illum >= 45 && illum <= 55;
}

(:test)
function testMoonIlluminationRange(logger as Test.Logger) as Boolean {
    var valid = true;
    for (var m = 1; m <= 12; m += 1) {
        for (var d = 1; d <= 28; d += 5) {
            var illum = moonIlluminationPercent(2025, m, d);
            if (illum < 0 || illum > 100) { valid = false; }
        }
    }
    return valid;
}

// ── Moon phase index tests (same values as old FormatUtils.moonPhase) ─────────

(:test)
function testMoonPhaseNewMoon(logger as Test.Logger) as Boolean {
    return moonPhaseIndex(2024, 1, 11, 0) == 0;
}

(:test)
function testMoonPhaseFullMoon(logger as Test.Logger) as Boolean {
    return moonPhaseIndex(2024, 6, 22, 0) == 4;
}

(:test)
function testMoonPhaseSouthernHemisphere(logger as Test.Logger) as Boolean {
    var north = moonPhaseIndex(2024, 6, 14, 0);
    var south = moonPhaseIndex(2024, 6, 14, 1);
    return south == ((8 - north) % 8);
}

(:test)
function testMoonPhaseMayTheFourth(logger as Test.Logger) as Boolean {
    return moonPhaseIndex(2024, 5, 4, 0) == 8;
}