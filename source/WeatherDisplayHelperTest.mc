import Toybox.Test;

(:test)
function testUvIndexRoundsToNearestInteger(logger as Test.Logger) as Boolean {
    var weather = new StoredWeather();
    weather.uvIndex = 4.6f;

    var helper = new WeatherDisplayHelper();
    helper.update(weather, null, "C", true, 0, 0, false, 0);

    return helper.getUVIndex().equals("5");
}
