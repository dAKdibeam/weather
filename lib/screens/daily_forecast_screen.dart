import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:weathergrade_aplus/components/daily_card.dart';
import 'package:weathergrade_aplus/components/hourly_card.dart';
import 'package:weathergrade_aplus/constants/constants.dart';
import 'package:expandable/expandable.dart';
import 'package:weathergrade_aplus/constants/text_style.dart';

import 'package:weathergrade_aplus/preferences/shared_prefs.dart';
import 'package:weathergrade_aplus/preferences/theme_colors.dart';
import 'package:weathergrade_aplus/utils/time.dart';
import 'package:intl/intl.dart';
import 'package:weathergrade_aplus/models/weather_model.dart';

import 'home_screen.dart';

class DailyForecastScreen extends StatefulWidget {
  final Function onChooseLocationPressed;
  DailyForecastScreen({this.onChooseLocationPressed});
  @override
  _DailyForecastScreenState createState() => _DailyForecastScreenState();
}

class _DailyForecastScreenState extends State<DailyForecastScreen> {
  var dailyData;
  double lat;
  double lon;
  bool imperial;
  WindUnit unit;

  bool isLoading = true;

  void initState() {
    super.initState();
    if (!(WeatherModel.weatherData == 401 ||
        WeatherModel.weatherData == 429 ||
        WeatherModel.weatherData == null)) {
      updateUI();
    }
  }

  Future<void> updateUI() async {
    dailyData = WeatherModel.weatherData["daily"];
    lat = WeatherModel.weatherData["lat"].toDouble();
    lon = WeatherModel.weatherData["lon"].toDouble();

    imperial = await SharedPrefs.getImperial();
    unit = await SharedPrefs.getWindUnit();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (dailyData == null) {
      return Scaffold(
        backgroundColor: ThemeColors.backgroundColor(),
        body: Center(
          child: Text(
            dailyData == null
                ? "Choose a location to view weather. "
                : "Loading ",
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
          brightness: ThemeColors.isDark ? Brightness.dark : Brightness.light,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: ThemeColors.backgroundColor(),
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
            SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.separated(
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return DailyCard(
                          data: dailyData[index + 1],
                          imperial: imperial,
                          unit: unit,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 5,
                        );
                      },
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      itemCount: 7,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> refresh() async {
    await WeatherModel.getCoordLocationWeather(
        latitude: lat, longitude: lon, name: WeatherModel.locationName);
    updateUI();
    DateTime now = DateTime.now();
    String refreshTime = TimeHelper.getReadableTime(now);
    Scaffold.of(context).showSnackBar(
        SnackBar(content: Text("${"Last updated at "} $refreshTime")));
  }
}
