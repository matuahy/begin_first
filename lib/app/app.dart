import 'package:begin_first/app/router.dart';
import 'package:begin_first/app/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return CupertinoApp.router(
      routerConfig: router,
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
    );
  }
}
