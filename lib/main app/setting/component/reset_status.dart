import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../../set up first/connect bluetooth/sent_data_to_iot.dart';

void resetStatus(BuildContext context) async {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const BluetoothSetupPage()),
  );
}
