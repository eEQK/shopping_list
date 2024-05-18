import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/ui/edit/edit_screen.dart';
import 'package:shopping_list/ui/home/home_screen.dart';
import 'package:yaru/yaru.dart';

void main() async {
  await YaruWindowTitleBar.ensureInitialized();

  runApp(
    const ProviderScope(
      child: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      data: const YaruThemeData(
        variant: YaruVariant.lubuntuBlue,
      ),
      builder: (context, yaru, child) => MaterialApp(
        title: 'Shopping list',
        debugShowCheckedModeBanner: false,
        theme: yaru.theme!.copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
            },
          ),
        ),
        routes: {
          HomeScreen.route: (_) => const HomeScreen(),
          EditScreen.route: (_) => const EditScreen(),
        },
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown,
            PointerDeviceKind.trackpad,
          },
        ),
      ),
    );
  }
}
