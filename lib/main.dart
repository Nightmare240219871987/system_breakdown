import 'package:flutter/material.dart';
import 'package:system_breakdown/src/rust/frb_generated.dart';
import 'package:system_breakdown/src/app.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}
