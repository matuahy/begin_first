import 'package:begin_first/app/app.dart';
import 'package:begin_first/data/local/hive_initializer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeHive();
  runApp(const ProviderScope(child: App()));
}
