import 'package:flutter/material.dart';
import 'package:universal_ac_remote/screens/ac_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal AC Remote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.blue),useMaterial3: true),
      home: AcListPage(),
    );
  }
}

