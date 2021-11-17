import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:weathergrade_aplus/constants/constants.dart';
import 'package:weathergrade_aplus/preferences/shared_prefs.dart';
import 'package:weathergrade_aplus/preferences/theme_colors.dart';
import 'package:weathergrade_aplus/screens/home_screen.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restart_app/restart_app.dart';

import 'loading_screen.dart';

class MoreScreen extends StatefulWidget {
  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  //the values displayed on the toggles
  bool useImperial;
  bool useDarkMode;
  bool use24;
  String windDropdownValue;
  String langDropdownValue;

  void initState() {
    super.initState();
    getSharedPrefs();
  }

  //gets the shared prefs to display on the toggles
  Future<void> getSharedPrefs() async {
    useImperial = await SharedPrefs.getImperial();
    useDarkMode = await SharedPrefs.getDark();
    use24 = await SharedPrefs.get24();
    switch (await SharedPrefs.getWindUnit()) {
      case WindUnit.MS:
        windDropdownValue = "meters/s";
        break;
      case WindUnit.MPH:
        windDropdownValue = "miles/h";
        break;
      case WindUnit.KMPH:
        windDropdownValue = "kilometers/h";
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(),
      appBar: AppBar(
        brightness: ThemeColors.isDark ? Brightness.dark : Brightness.light,
        title: Text(
          "more",
          style: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 30,
            color: ThemeColors.primaryTextColor(),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Container(
                height: 125,
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: kBorderRadius,
                  color: Colors.grey[900],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      left: 15,
                      child: Text(
                        "Weather",
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 35,
                            color: Colors.white),
                      ),
                    ),
                    Positioned(
                      top: 22,
                      right: 15,
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/pluvia.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 80,
                child: Card(
                  child: Center(
                    child: SwitchListTile(
                      title: Text(
                        "darkMode",
                        style: TextStyle(color: ThemeColors.primaryTextColor()),
                      ),
                      value: useDarkMode ?? false,
                      onChanged: (bool value) async {
                        useDarkMode = true;
                        ThemeColors.switchTheme(value);
                        //restart the app to show theme changes
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return HomeScreen();
                            },
                          ),
                        );
                      },
                      secondary: Icon(
                        Icons.lightbulb_outline,
                        color: ThemeColors.secondaryTextColor(),
                      ),
                    ),
                  ),
                  color: ThemeColors.cardColor(),
                  shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
                ),
              ),
              SizedBox(
                height: 80,
                child: Card(
                  child: Center(
                    child: SwitchListTile(
                      title: Text(
                        "useFahrenheit",
                        style: TextStyle(
                          color: ThemeColors.primaryTextColor(),
                        ),
                      ),
                      value: useImperial ?? false,
                      onChanged: (bool value) async {
                        await SharedPrefs.setImperial(value);
                        useImperial = value;
                        setState(() {});
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text("refreshToSee")));
                      },
                      secondary: Icon(
                        Icons.thermostat_outlined,
                        color: ThemeColors.secondaryTextColor(),
                      ),
                    ),
                  ),
                  color: ThemeColors.cardColor(),
                  shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
                ),
              ),
              SizedBox(
                height: 80,
                child: Card(
                  child: Center(
                    child: SwitchListTile(
                      title: Text(
                        "use24HourTime",
                        style: TextStyle(
                          color: ThemeColors.primaryTextColor(),
                        ),
                      ),
                      value: use24 ?? false,
                      onChanged: (bool value) async {
                        await SharedPrefs.set24(value);
                        use24 = value;
                        setState(() {});
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text("refreshToSee")));
                      },
                      secondary: Icon(
                        Icons.timelapse_outlined,
                        color: ThemeColors.secondaryTextColor(),
                      ),
                    ),
                  ),
                  color: ThemeColors.cardColor(),
                  shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
                ),
              ),
              // Container(
              //   height: 130,
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       FlatButton(
              //         onPressed: () async {
              //           const url =
              //               "https://github.com/SpicyChair/pluvia_weather_flutter";
              //           if (await canLaunch(url)) {
              //             await launch(url);
              //           }
              //         },
              //         child: ThemeColors.isDark
              //             ? Image.asset("assets/GitHub-Mark-Light-64px.png")
              //             : Image.asset("assets/GitHub-Mark-64px.png"),
              //       ),
              //       SizedBox(
              //         height: 12,
              //       ),
              //       Center(
              //         child: Text(
              //           "viewOnGithub",
              //           style: TextStyle(
              //               fontSize: 14,
              //               fontWeight: FontWeight.bold,
              //               color: ThemeColors.primaryTextColor()),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
