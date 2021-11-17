import 'package:flutter/material.dart';
import 'package:weathergrade_aplus/constants/constants.dart';
import 'package:weathergrade_aplus/preferences/theme_colors.dart';
import 'package:weathergrade_aplus/preferences/shared_prefs.dart';
import 'package:weathergrade_aplus/screens/search_screen.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  @override
  _AdvancedSettingsScreenState createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  String version;

  TextEditingController weatherKeyTextController;

  String defaultLocationText = "";

  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    weatherKeyTextController.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var info = await SharedPrefs.getDefaultLocation();

    setState(() {
      version = packageInfo.version;
      defaultLocationText = info[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: TextButton(
          child: Icon(
            Icons.arrow_back,
            color: ThemeColors.primaryTextColor(),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        brightness: ThemeColors.isDark ? Brightness.dark : Brightness.light,
        title: Text(
          "Advanced Settings",
          style: TextStyle(color: ThemeColors.primaryTextColor()),
        ), //Language.getTranslation("advancedSettings")
        centerTitle: true,
        backgroundColor: ThemeColors.backgroundColor(),
      ),
      backgroundColor: ThemeColors.backgroundColor(),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 80,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
                  color: ThemeColors.cardColor(),
                  child: Center(
                    child: ListTile(
                      onLongPress: () async {
                        await SharedPrefs.removeDefaultLocation();
                        await initialize();
                      },
                      onTap: () async {
                        var locationData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchScreen(),
                          ),
                        );
                        //check if returned data != null
                        if (locationData != null) {
                          MapBoxPlace place = locationData;
                          double latitude = place.geometry.coordinates[1];
                          double longitude = place.geometry.coordinates[0];
                          String name = place.text;

                          await SharedPrefs.setDefaultLocation(
                              text: name, lat: latitude, long: longitude);
                          await initialize();
                          print("$name: $latitude, $longitude");
                        }
                      },
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: ThemeColors.secondaryTextColor(),
                      ),
                      title: Text(
                        "Default Location",
                        style: TextStyle(
                          color: ThemeColors.primaryTextColor(),
                        ),
                      ),
                      subtitle: Text(
                        defaultLocationText ==
                                "Use a default location on app startup."
                            ? "useDefaultLocationOnStartup"
                            : "$defaultLocationText. ${"pressAndHold"}",
                        style:
                            TextStyle(color: ThemeColors.secondaryTextColor()),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
