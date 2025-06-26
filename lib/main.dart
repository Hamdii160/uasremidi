import 'package:flutter/material.dart';
import 'package:uasremidi/formpage.dart';
import 'package:uasremidi/homepage.dart';

// Nama Lengkap : Moh Hamdi Baihaqi
// NIM : 230441100160
// Kelas : D
// Nama Asprak : Kak Rakha

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Color(0xFF201E43),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF201E43),
          selectionColor: Color(0xFF508C9B),
          selectionHandleColor: Color(0xFF201E43),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);
        Widget page;

        if (settings.name == '/') {
          page = const HomePage();
        } else if (settings.name == '/home') {
          page = const HomePage();
        } else if (settings.name == '/add') {
          page = FormPage(isUpdate: false);
        } else if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'update') {
          final id = uri.pathSegments[1];
          page = FormPage(isUpdate: true, id: id);
        } else {
          page = const Scaffold(
            body: Center(child: Text('404 Not Found')),
          );
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }
}