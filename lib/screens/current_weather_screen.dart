import 'dart:ui';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:weathergrade_aplus/screens/daily_forecast_screen.dart';
import 'package:weathergrade_aplus/utils/weather_type.dart';
import 'package:weathergrade_aplus/constants/constants.dart';
import 'package:weathergrade_aplus/preferences/shared_prefs.dart';
import 'package:weathergrade_aplus/preferences/theme_colors.dart';

import 'package:weathergrade_aplus/screens/saved_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:weathergrade_aplus/constants/text_style.dart';
import 'package:weathergrade_aplus/components/weather_animation.dart';
import 'package:weathergrade_aplus/components/info_card.dart';
import 'package:weathergrade_aplus/models/location_service.dart';
import 'package:weathergrade_aplus/utils/time.dart';
import 'package:weathergrade_aplus/components/panel_card.dart';
import 'package:weathergrade_aplus/components/hourly_card.dart';
import 'package:weathergrade_aplus/models/weather_model.dart';
import 'package:intl/intl.dart';
import 'package:weathergrade_aplus/utils/extensions.dart';
import 'home_screen.dart';

class CurrentWeatherScreen extends StatefulWidget {
  //get the weather from loading screen
  @override
  CurrentWeatherScreen();
  _CurrentWeatherScreenState createState() => _CurrentWeatherScreenState();
}

class _CurrentWeatherScreenState extends State<CurrentWeatherScreen> {
  //animation for the current time / weather

  WeatherAnimation weatherAnimation = new WeatherAnimation();

  double lat;
  double lon;

  DateTime weatherTime; //the time from the forecast
  DateTime sunriseTime; //sunrise
  DateTime sunsetTime; //sunset

  int timeZoneOffset;
  String timeZoneOffsetText; //the displayed version of timezoneoffset

  String conditionDescription;

  int temperature; //actual temperature, celsius for metric, fahrenheit for imperial
  double feelTemp; //what the temperature feels like (to one dp for accuracy)
  double uvIndex; //the UV index at midday
  int pressure;
  int humidity;

  double windSpeed; //wind speed in m/s for metric, mph for imperial
  String unitString; //unit for the wind speed
  int windDirection; //the angle of the wind direction in degrees

  List<dynamic> hourlyData;
  List<dynamic> dailyData;

  String refreshTimeText;
  DateTime refreshTime; //the time weather last updated

  bool isLoading = true; //if data is being loaded

  @override
  void initState() {
    super.initState();
    if (!(WeatherModel.weatherData == 401 ||
        WeatherModel.weatherData == 429 ||
        WeatherModel.weatherData == null)) {
      updateUI();
    }
  }

  void updateUI() async {
    var weatherData = WeatherModel.weatherData;
    hourlyData = weatherData["hourly"];
    dailyData = weatherData["daily"];

    timeZoneOffset = WeatherModel.getSecondsTimezoneOffset();
    timeZoneOffsetText = timeZoneOffset.isNegative
        ? "${(timeZoneOffset / 3600).round()}"
        : "+${(timeZoneOffset / 3600).round()}"; //TODO: FIX ROUNDING OF TIMEZONE

    lat = weatherData["lat"].toDouble();
    lon = weatherData["lon"].toDouble();

    weatherTime = TimeHelper.getDateTimeSinceEpoch(
        weatherData["current"]["dt"], timeZoneOffset);

    sunriseTime = TimeHelper.getDateTimeSinceEpoch(
        weatherData["current"]["sunrise"].toInt(), timeZoneOffset);

    sunsetTime = TimeHelper.getDateTimeSinceEpoch(
        weatherData["current"]["sunset"].toInt(), timeZoneOffset);
    DateTime tomorrowSunrise = TimeHelper.getDateTimeSinceEpoch(
        dailyData[1]["sunrise"], timeZoneOffset);

    int conditionCode = weatherData["current"]["weather"][0]["id"];
    //update all values
    temperature = weatherData["current"]["temp"]?.round();
    feelTemp = weatherData["current"]["feels_like"]?.toDouble();
    uvIndex = weatherData["current"]["uvi"]?.toDouble();
    humidity = weatherData["current"]["humidity"]?.round();
    pressure = weatherData["current"]["pressure"]?.round();

    windDirection = weatherData["current"]["wind_deg"]?.round();

    conditionDescription = weatherData["current"]["weather"][0]["description"];

    bool imperial = await SharedPrefs.getImperial();
    WindUnit unit = await SharedPrefs.getWindUnit();

    windSpeed = WeatherModel.convertWindSpeed(
        weatherData["current"]["wind_speed"].round(), unit, imperial);
    unitString = WeatherModel.getWindUnitString(unit);

    WeatherType weatherType = WeatherModel.getWeatherType(
        sunriseTime, sunsetTime, tomorrowSunrise, weatherTime, conditionCode);

    //if assets are not loaded yet, set the initial weather to build
    if (weatherAnimation.state == null) {
      weatherAnimation.initialWeather = weatherType;
    } else {
      //else set the weather normally
      weatherAnimation.state.weatherWorld.weatherType = weatherType;
    }

    refreshTimeText = TimeHelper.getReadableTime(DateTime.now());
    refreshTime = DateTime.now();

    setState(() {
      isLoading = false;
    });
  }

  //refresh data
  Future<void> refresh() async {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text("loading...")));

    if (DateTime.now().difference(refreshTime).inMinutes >= 10) {
      //if the location displayed is current, refresh location
      if (WeatherModel.locationName == "Current Location ") {
        await WeatherModel.getUserLocationWeather();
      } else {
        //else refresh normally
        await WeatherModel.getCoordLocationWeather(
            latitude: lat, longitude: lon, name: WeatherModel.locationName);
        //lati, lon, WeatherModel.locationName);
      }
      updateUI();
    } else {
      refreshTimeText = TimeHelper.getReadableTime(DateTime.now());
      weatherTime = weatherTime.add(DateTime.now().difference(refreshTime));
      setState(() {});
    }

    Scaffold.of(context).showSnackBar(
        SnackBar(content: Text("${"Last updated at "}$refreshTimeText")));
  }

  @override
  Widget build(BuildContext context) {
    if (WeatherModel.weatherData == null) {
      return Scaffold(
        backgroundColor: ThemeColors.backgroundColor(),
        body: Center(
          child: Text(
            "Choose a location to view weather. ",
            style: TextStyle(
              color: ThemeColors.primaryTextColor(),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          title: Text(
            WeatherModel.locationName,
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 30,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            ButtonTheme(
              minWidth: 0,
              child: FlatButton(
                onPressed: refresh,
                child: Icon(
                  Icons.refresh_outlined,
                  size: 27,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: ThemeColors.backgroundColor(),
        extendBodyBehindAppBar: true,
        body: isLoading
            ?
            //if is loading
            Center(
                child: Column(
                children: [
                  SpinKitFadingCircle(
                    color: ThemeColors.secondaryTextColor(),
                    size: 50,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Loading ",
                    style: TextStyle(color: ThemeColors.secondaryTextColor()),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ))
            :

            //if loaded
            Stack(
                alignment: Alignment.topCenter,
                children: [
                  weatherAnimation,
                  temperatureWidget(),
                  //infoWidget(),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height - 85,
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          children: [
                            //add a spacer
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.55,
                            ),
                            Column(
                              children: [
                                createHourlyForecastCard(),
                                createInfoCards(),
                                dailyForecastScreenInfoCards(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget temperatureWidget() {
    return Positioned(
      top: 70,
      left: 5,
      child: SizedBox(
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${temperature.toString()}°",
              style: kLargeTempTextStyle,
            ),
            Container(
              width: 300,
              padding: EdgeInsets.only(left: 5),
              child: Text(
                conditionDescription.toTitleCase(),
                textAlign: TextAlign.left,
                style: kConditionTextStyle,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              child: Text(
                "${"Local Time "}${TimeHelper.getReadableTime(weatherTime)} (UTC$timeZoneOffsetText)",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.65), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoWidget() {
    return Positioned(
      top: 90,
      right: 5,
      child: Container(
        height: 100,
        width: 100,
        color: Colors.white,
      ),
    );
  }

  Widget createHourlyForecastCard() {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.backgroundColor(),
      ),
      child: Container(
        height: 200,
        width: double.infinity,
        margin: kPanelCardMargin,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            int temp;
            String icon;
            DateTime forecastTime;
            String displayTime;
            var weatherData;

            if (hourlyData[index] == null) {
              temp = 0;
              icon = "☀";
              displayTime = "00:00";
            } else {
              temp = hourlyData[index]["temp"].round();

              forecastTime = TimeHelper.getDateTimeSinceEpoch(
                  hourlyData[index]["dt"], timeZoneOffset);
              displayTime = TimeHelper.getShortReadableTime(forecastTime);

              DateTime tomorrowSunrise = TimeHelper.getDateTimeSinceEpoch(
                  dailyData[1]["sunrise"], timeZoneOffset);
              icon = WeatherModel.getIcon(hourlyData[index]["weather"][0]["id"],
                  forecastTime: forecastTime,
                  sunrise: sunriseTime,
                  sunset: sunsetTime,
                  tomorrowSunrise: tomorrowSunrise);
            }

            weatherData = hourlyData[index];

            int pop = (weatherData["pop"].toDouble() * 100)
                .round(); //probability of precipitation

            return HourlyCard(
              context: context,
              icon: icon,
              temp: temp,
              displayTime: displayTime,
              forecastTime: forecastTime,
              weatherData: weatherData,
              pop: pop,
              isCurrent: index == 0,
            );
          },
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 24,
        ),
      ),
    );
  }

  Widget createInfoCards() {
    return PanelCard(
      cardChild: Container(
        width: double.infinity,
        margin: kPanelCardMargin,
        child: GridView.count(
          shrinkWrap: true,
          childAspectRatio: 2.5,
          crossAxisCount: 2,
          physics: NeverScrollableScrollPhysics(),
          children: [
            InfoCard(
              title: "Feels like ",
              value: "${feelTemp.toString()}°",
            ),
            InfoCard(
              title: "Wind ",
              value:
                  "${windSpeed.round().toString()} $unitString ${WeatherModel.getWindCompassDirection(windDirection)}",
            ),
            InfoCard(
              title: "Sunrise ",
              value: "${TimeHelper.getReadableTime(sunriseTime)}",
            ),
            InfoCard(
              title: "Sunset ",
              value: "${TimeHelper.getReadableTime(sunsetTime)}",
            ),
            InfoCard(
              title: "Humidity ",
              value: "${humidity.toString()}%",
            ),
            InfoCard(
              title: "Pressure ",
              value: "${pressure.toString()} hPa",
            ),
          ],
        ),
      ),
    );
  }

  Widget dailyForecastScreenInfoCards() {
    return PanelCard(
      cardChild: Container(
          height: 700,
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: DailyForecastScreen()),
    );
  }
}
