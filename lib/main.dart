import 'package:coupleapp/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  //  애플리케이션이 실행될 때 초기화 과정을 제어하고 애플리케이션의 안정성과 동작을 보장하는 것
  WidgetsFlutterBinding.ensureInitialized();
  // 초기화 됐는지 확인(원래는 runApp 실행이 되면 이 코드가 실행이 되는데 우리가 runApp전에
  // initializeDateFormatting을 실행하기 때문에 또 한번의 초기화를 해줘야 한다
  await initializeDateFormatting('ko_KR', null);

  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  MyApp({super.key});
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(0, now),
    );
  }
}
