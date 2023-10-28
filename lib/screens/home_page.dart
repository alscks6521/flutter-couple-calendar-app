import 'package:coupleapp/screens/calender_screen.dart';
import 'package:coupleapp/screens/home_screen.dart';
import 'package:coupleapp/screens/memo_screen.dart';
import 'package:coupleapp/screens/set_screen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final int sel;
  final DateTime sel2;
  const HomePage(this.sel, this.sel2, {super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late DateTime now;
  List<Widget> _widgetOptions = [];
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.sel;
    now = widget.sel2;

    _widgetOptions = <Widget>[
      const HomeScreen(),
      CalendarScreen(now),
      const MemoScreen(),
      const SetScreen(),
    ];
  }

  // static final List<Widget> _widgetOptions = <Widget>[
  //   const HomeScreen(),
  //   CalendarScreen(now),
  //   const MemoScreen(),
  //   const SetScreen(),
  // ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 245, 245),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color.fromARGB(255, 255, 222, 233),
        foregroundColor: const Color.fromARGB(255, 224, 69, 245),
        title: const Text(
          "CRUSH",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      //선택한 아이템에 해당하는 화면을 표시하는 부분
      //elementAt() 메서드는 리스트나 배열과 같은 인덱스로 접근 가능한 자료구조에서 특정 인덱스에 해당하는 요소를 가져오는 메서드
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notes_sharp),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 112, 112),
        unselectedItemColor: const Color.fromARGB(255, 255, 196, 196),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 30,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
