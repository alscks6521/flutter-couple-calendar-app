import 'dart:convert';
import 'package:coupleapp/screens/home_page.dart';
import 'package:coupleapp/survice/calendar_class.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarView extends StatefulWidget {
  final data;
  final DateTime date;
  const CalendarView(this.data, this.date, {super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  Future<void> deleteEvent(DateTime date, Event event) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsMap = prefs.getString('events') != null
        ? Map<String, dynamic>.from(
            Map<String, dynamic>.from(await json.decode(prefs.getString('events')!)),
          )
        : {};

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    if (eventsMap.containsKey(formattedDate)) {
      final existingEvent = eventsMap[formattedDate];

      if ((existingEvent.length) > 1) {
        eventsMap[formattedDate] =
            existingEvent.where((e) => Event.fromJson(e).title != event.title).toList();
      } else {
        print("! re");
        eventsMap.remove(formattedDate);
      }

      // 업데이트된 이벤트 목록을 저장
      await prefs.setString('events', json.encode(eventsMap));

      // UI를 업데이트합니다.첫 페이지까지 이동하기
      setState(() {
        // Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HomePage(1, widget.date),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 249, 249),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 201, 110, 237),
        title: Text(
          "${widget.data.title}",
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.clear,
              weight: 700,
              color: Colors.red,
            ),
            iconSize: 30,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("삭제하시겠습니까?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("취소"),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteEvent(widget.date, widget.data);
                        },
                        child: const Text("확인"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.watch_later_outlined,
                  size: 35,
                ),
                Text(
                  " ${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일",
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "일정내용: ${widget.data.content}",
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
