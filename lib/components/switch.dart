import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../offline/sqllite.dart';

class SwitchExample extends StatefulWidget {
  final bool isOnline;
  final VoidCallback onRefresh;
  const SwitchExample(
      {super.key, required this.isOnline, required this.onRefresh});

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Customized

          LiteRollingSwitch(
            value: widget.isOnline,
            width: 150,
            textOn: 'Online',
            textOff: 'Offline',
            colorOn: Colors.deepPurple,
            colorOff: Colors.grey,
            iconOn: Icons.wifi,
            iconOff: Icons.wifi_off_outlined,
            animationDuration: const Duration(milliseconds: 0),
            textOnColor: Colors.white,
            onChanged: (bool state) async {
              print(state);
              if (state == false) {
                // Show loading indicator
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  barrierDismissible: false,
                );
                try {
                  // Sync data
                  if (await YourDataSync().syncData() == false) {
                    Color backgroundColor = Colors.grey;

                    final snackBar = SnackBar(
                      content: Text('Error in syncing Data'),
                      duration: Duration(seconds: 2),
                      backgroundColor: backgroundColor,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool('isOnline', !widget.isOnline);
                    print('turned ${(state) ? 'on' : 'off'}');
                    // Show Snackbar
                    Color backgroundColor =
                        (state) ? Colors.deepPurple : Colors.grey;

                    final snackBar = SnackBar(
                      content: Text(
                          'You Switched to ${(state) ? 'Online Mode' : 'Offline Mode'}'),
                      duration: Duration(seconds: 2),
                      backgroundColor: backgroundColor,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    widget.onRefresh();
                  }
                } catch (e) {
                } finally {
                  Navigator.pop(context);
                }

                // Close loading indicator
              } else {
                YourDataSync().databaseHelper.deleteDatabaseFile();
                //YourDataSync().databaseHelper.deleteTable();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isOnline', !widget.isOnline);
                print('turned ${(state) ? 'on' : 'off'}');
                // Show Snackbar
                Color backgroundColor =
                    (state) ? Colors.deepPurple : Colors.grey;

                final snackBar = SnackBar(
                  content: Text(
                      'You Switched to ${(state) ? 'Online Mode' : 'Offline Mode'}'),
                  duration: Duration(seconds: 2),
                  backgroundColor: backgroundColor,
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            onDoubleTap: () {},
            onSwipe: () {},
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
