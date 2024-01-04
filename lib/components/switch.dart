import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../offline/sqllite.dart';

class SwitchExample extends StatefulWidget {
  final bool isOnline;
  const SwitchExample({super.key, required this.isOnline});

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
                YourDataSync().syncData();
              }

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isOnline', !widget.isOnline);
              print('turned ${(state) ? 'on' : 'off'}');
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
