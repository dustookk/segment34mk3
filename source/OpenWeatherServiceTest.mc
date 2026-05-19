import Toybox.Test;
import Toybox.Lang;
import Toybox.Time;

// Unit tests for OpenWeatherService.owmCodeToGarmin()
// These test the OWM weather code -> Garmin condition enum mapping.
// Run with: monkeyc --unit-test -d fenix7

(:test)
function testOwmCodeClear(logger as Test.Logger) as Boolean {
    return OpenWeatherService.owmCodeToGarmin(800) == 0;
}

(:test)
function testOwmCodeThunderstorm(logger as Test.Logger) as Boolean {
    return OpenWeatherService.owmCodeToGarmin(200) == 6;
}

(:test)
function testOwmCodeRain(logger as Test.Logger) as Boolean {
    return OpenWeatherService.owmCodeToGarmin(500) == 14
        && OpenWeatherService.owmCodeToGarmin(501) == 3
        && OpenWeatherService.owmCodeToGarmin(502) == 15;
}

(:test)
function testOwmCodeSnow(logger as Test.Logger) as Boolean {
    return OpenWeatherService.owmCodeToGarmin(600) == 16
        && OpenWeatherService.owmCodeToGarmin(601) == 4
        && OpenWeatherService.owmCodeToGarmin(602) == 17;
}

(:test)
function testOwmCodeFog(logger as Test.Logger) as Boolean {
    return OpenWeatherService.owmCodeToGarmin(701) == 8
        && OpenWeatherService.owmCodeToGarmin(741) == 8;
}

(:test)
function testOwmCodeClouds(logger as Test.Logger) as Boolean {
    return OpenWeatherService.owmCodeToGarmin(801) == 1
        && OpenWeatherService.owmCodeToGarmin(803) == 2
        && OpenWeatherService.owmCodeToGarmin(804) == 20;
}

(:test)
function testOwmCodeUnknown(logger as Test.Logger) as Boolean {
    return OpenWeatherService.owmCodeToGarmin(999) == 53;
}

// Unit tests for getSolarHorizonEvent() in FormatUtils.mc
// Reference: Stockholm (lat=59.33°), equinox-like day:
//   sunrise epoch = 1742900400 (approx 06:00 local / 05:00 UTC)
//   sunset epoch  = 1742943600 (approx 18:00 local / 17:00 UTC)
//   day length = 43200s (12h), so solar noon is midpoint

// h0 = -0.8333 (sun horizon): event times should equal sunrise/sunset (within ~60s)
(:test)
function testSolarHorizonEventIdentity(logger as Test.Logger) as Boolean {
    var sunrise = new Time.Moment(1742900400);
    var sunset  = new Time.Moment(1742943600);
    var result = getSolarHorizonEvent(59.33f, sunrise, sunset, -0.8333f);
    if (result == null) { return false; }
    var dawn = (result as Array)[0] as Time.Moment;
    var dusk = (result as Array)[1] as Time.Moment;
    // Should be within 60 seconds of sunrise/sunset
    var dawnDelta = (dawn.value() - sunrise.value()).abs();
    var duskDelta = (dusk.value() - sunset.value()).abs();
    return dawnDelta < 60 && duskDelta < 60;
}

// h0 = -6° (civil twilight): dawn before sunrise, dusk after sunset
(:test)
function testSolarHorizonEventCivilTwilight(logger as Test.Logger) as Boolean {
    var sunrise = new Time.Moment(1742900400);
    var sunset  = new Time.Moment(1742943600);
    var result = getSolarHorizonEvent(59.33f, sunrise, sunset, -6.0f);
    if (result == null) { return false; }
    var dawn = (result as Array)[0] as Time.Moment;
    var dusk = (result as Array)[1] as Time.Moment;
    // Civil dawn is before sunrise, civil dusk is after sunset
    return dawn.lessThan(sunrise) && sunset.lessThan(dusk);
}

// h0 = +5° (golden hour end): event is after sunrise (sun must rise above +5°)
(:test)
function testSolarHorizonEventGoldenHourEnd(logger as Test.Logger) as Boolean {
    var sunrise = new Time.Moment(1742900400);
    var sunset  = new Time.Moment(1742943600);
    var result = getSolarHorizonEvent(59.33f, sunrise, sunset, 5.0f);
    if (result == null) { return false; }
    var goldenEnd   = (result as Array)[0] as Time.Moment;
    var goldenStart = (result as Array)[1] as Time.Moment;
    // Golden hour end (morning) is after sunrise; golden hour start (evening) is before sunset
    return sunrise.lessThan(goldenEnd) && goldenStart.lessThan(sunset);
}

// h0 = +0.125° (moon-like): event times should be very close to sunrise/sunset (slightly after/before)
(:test)
function testSolarHorizonEventMoonLike(logger as Test.Logger) as Boolean {
    var sunrise = new Time.Moment(1742900400);
    var sunset  = new Time.Moment(1742943600);
    var result = getSolarHorizonEvent(59.33f, sunrise, sunset, 0.125f);
    if (result == null) { return false; }
    var moonRise = (result as Array)[0] as Time.Moment;
    var moonSet  = (result as Array)[1] as Time.Moment;
    // Moon-like h0 > 0 means event is slightly after sunrise / before sunset
    return sunrise.lessThan(moonRise) && moonSet.lessThan(sunset);
}

// Ordering test: for a mid-latitude location, civil < sun < moon-like < golden-end
// dawn order: civil_dawn < sunrise < moon_dawn < golden_end_dawn
(:test)
function testSolarHorizonEventOrdering(logger as Test.Logger) as Boolean {
    var sunrise = new Time.Moment(1742900400);
    var sunset  = new Time.Moment(1742943600);
    var civil    = getSolarHorizonEvent(59.33f, sunrise, sunset, -6.0f);
    var moonLike = getSolarHorizonEvent(59.33f, sunrise, sunset, 0.125f);
    var golden   = getSolarHorizonEvent(59.33f, sunrise, sunset, 5.0f);
    if (civil == null || moonLike == null || golden == null) { return false; }
    var civilDawn  = (civil as Array)[0] as Time.Moment;
    var moonDawn   = (moonLike as Array)[0] as Time.Moment;
    var goldenDawn = (golden as Array)[0] as Time.Moment;
    // civil dawn < sunrise < moon dawn < golden hour end (morning)
    return civilDawn.lessThan(sunrise)
        && sunrise.lessThan(moonDawn)
        && moonDawn.lessThan(goldenDawn);
}
