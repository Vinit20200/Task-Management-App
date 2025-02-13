import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_management_app/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;


import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('preferences');

  await NotificationService.init();
  tz.initializeTimeZones();

  runApp(ProviderScope(child: MyApp()));
}
