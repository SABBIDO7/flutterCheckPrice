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
            width: 120,
            textOn: 'Online',
            textOff: 'Offline',
            colorOn: Colors.deepPurple,
            colorOff: Colors.grey,
            iconOn: Icons.wifi,
            iconOff: Icons.wifi_off_outlined,
            animationDuration: const Duration(milliseconds: 0),
            textOnColor: Colors.white,
            onChanged: (bool state) async {
              bool isConnected = await YourDataSync().isConnected();
              if (!isConnected) {
                // Show an alert or snackbar indicating no internet connection
                // You can customize this based on your UI/UX preferences
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No internet connection. Please check your connection.',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.all(20),
                  ),
                );

                return; // Do not update the state if there is no connection
              }
              print(state);
              if (state == false) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isOnline', false);
                print("-------------${prefs.getBool('isOnline')}");
                print('turned ${(state) ? 'on' : 'off'}');
                // Show Snackbar
                Color backgroundColor =
                    (state) ? Colors.deepPurple : Colors.grey;

                final snackBar = SnackBar(
                  content: Text(
                    'You Switched to ${(state) ? 'Online Mode' : 'Offline Mode'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: backgroundColor,
                  padding: const EdgeInsets.all(20.0),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                //YourDataSync().databaseHelper.deleteTable();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isOnline', true);
                print("-------------${prefs.getBool('isOnline')}");
                print('turned ${(state) ? 'on' : 'off'}');
                // Show Snackbar
                Color backgroundColor =
                    (state) ? Colors.deepPurple : Colors.grey;

                final snackBar = SnackBar(
                  content: Text(
                    'You Switched to ${(state) ? 'Online Mode' : 'Offline Mode'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: backgroundColor,
                  padding: const EdgeInsets.all(20.0),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }

              widget.onRefresh();
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
