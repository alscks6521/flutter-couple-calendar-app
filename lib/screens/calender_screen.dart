import 'dart:convert';
import 'package:coupleapp/screens/calendar_view.dart';
import 'package:coupleapp/survice/calendar_class.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

// ignore: must_be_immutable
class CalendarScreen extends StatefulWidget {
  late DateTime sel2;

  CalendarScreen(this.sel2, {Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime focusedDay = DateTime.now();

// format 상태 저장할 변수
  CalendarFormat format = CalendarFormat.month;

// marker
  Map<DateTime, List<Event>> events = {
    // DateTime.utc(2023, 9, 17): [Event('0917 title', '내용')],
  };

  @override
  void initState() {
    super.initState();
    loadEvents();
    print(widget.sel2);
    selectedDay = widget.sel2;
    focusedDay = selectedDay;
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  Future<void> saveEvent(DateTime date, Event event) async {
    print("SAVE");
    final prefs = await SharedPreferences.getInstance();
    final eventsMap = prefs.getString('events') != null
        ? Map<String, dynamic>.from(
            Map<String, dynamic>.from(await json.decode(prefs.getString('events')!)),
          )
        : {};

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    if (eventsMap.containsKey(formattedDate)) {
      // 이미 해당 날짜에 이벤트가 있는 경우, 이어붙이기
      final existingEvent = eventsMap[formattedDate];

      if (existingEvent is List) {
        existingEvent.add(event.toJson()); // Event 객체를 JSON으로 직렬화하여 추가
        print("1");
      } else {
        eventsMap[formattedDate] = [existingEvent, event.toJson()];
        print("2");
      }
    } else {
      // 해당 날짜에 이벤트가 없는 경우, 새로 추가
      eventsMap[formattedDate] = [event.toJson()];
    }

    await prefs.setString('events', json.encode(eventsMap));
    events[date] = [event];
    setState(() {
      loadEvents();
    });
  }

  Future<void> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();

    final eventsMap = prefs.getString('events');

    if (eventsMap != null) {
      final decodedMap = json.decode(eventsMap);
      decodedMap.forEach((key, value) {
        // key는 날짜 문열, value는 관련 이벤트 데이터.

        final date = DateFormat('yyyy-MM-dd').parse(key);
        // UTC로 DateTime 지정해줘야됨.
        final dateUtc = DateTime.utc(date.year, date.month, date.day);

        if (value is List<dynamic>) {
          // Event 객체로 변환하고, 그 결과를 eventList로 저장.
          final eventList = value.map((eventData) => Event.fromJson(eventData)).toList();

          setState(() {
            events[dateUtc] = eventList;
          });
        }
      });
    }
  }

  viewEvents() {
    if (events.containsKey(selectedDay)) {
      print("날짜 : $events \n");
      final dayEvents = events[selectedDay]!;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView.separated(
          // shrinkWrap을 true로 설정하면 ListView.builder는 필요한 크기만큼만 차지한다.
          shrinkWrap: true,
          // physics를 NeverScrollableScrollPhysics()로 설정하여 스크롤을 비활성화한다.
          // 이렇게 하면 무한한 높이로 인한 오류가 발생하지 않는다.
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dayEvents.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              //자식이 없는 빈 공간도 제스처를 감지
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CalendarView(dayEvents[index], selectedDay)));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 60,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dayEvents[index].title,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                        const Icon(
                          Icons.arrow_right,
                          size: 25,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(
            height: 10,
            child: Divider(
              thickness: 1,
            ),
          ),
        ),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: SizedBox(
          child: Text(
            "일정이 없어요.",
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }
  }

  void _dayShow() {
    String contextTitle = '';
    String contextContent = '';
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      builder: (BuildContext builder) {
        return Expanded(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                // 일정 없을때.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {});
                        // 취소 버튼 눌렀을 때의 동작
                        Navigator.of(context).pop(context); // 다이얼로그 닫기
                      },
                      icon: const Icon(
                        Icons.clear_rounded,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (contextTitle.isNotEmpty) {
                          // if (events.containsKey(selectedDay)) {
                          //   events[selectedDay]!.add(Event(contextTitle));
                          // } else {
                          //   events[selectedDay] = [Event(contextTitle)];
                          // }
                          final newEvent = Event(contextTitle, contextContent);

                          saveEvent(selectedDay, newEvent);
                        }

                        setState(() {});
                        // 선택 버튼 눌렀을 때의 동작
                        Navigator.of(context).pop(context); // 선택한 날짜 반환 및 다이얼로그 닫기
                      },
                      icon: const Icon(
                        Icons.check,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100,
                        child: Align(
                          alignment: Alignment.center,
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: '일정제목',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              contextTitle = value;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        child: Align(
                          alignment: Alignment.center,
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: '일정내용',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              contextContent = value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final DateTime now = DateTime.now();
    final DateTime firstDay = DateTime(2000, 1, 1);
    final DateTime lastDay = DateTime(2024, 12, 31);

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            child: TableCalendar(
              // calendarController: _calendarController,
              locale: 'ko_KR',
              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: focusedDay,
              rangeStartDay: DateTime(2023, 9, 10),
              rangeEndDay: DateTime(2023, 9, 12),

              // format 상태표시
              calendarFormat: format,
              onFormatChanged: (CalendarFormat format) {
                setState(() {
                  this.format = format;
                });
              },

              // marker 표시
              calendarStyle: const CalendarStyle(
                markersMaxCount: 1,
                markerSize: 10,
                markerDecoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: _getEventsForDay,

              // 날짜를 선택하면 onDaySelected 콜백이 호출되고
              // 선택된 날짜의 모양을 selectedDayPredicate 함수를 통해 설정할 수 있다.
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                // 선택된 날짜의 상태를 갱신한다.
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                  widget.sel2 = this.selectedDay;
                  // _dayShow();
                });
              },
              selectedDayPredicate: (DateTime day) {
                // selectedDat 와 동일한 날짜의 모양을 바꿔준다.
                return isSameDay(selectedDay, day);
              },

              headerStyle: HeaderStyle(
                titleCentered: true,
                // title의 날짜형태
                titleTextFormatter: (date, locale) => DateFormat.yMMMMd(locale).format(date),
                // formatButton 노출여부
                formatButtonVisible: true,

                titleTextStyle: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 151, 56, 188),
                ),
                headerPadding: const EdgeInsets.symmetric(vertical: 5.0),
                leftChevronIcon: const Icon(
                  Icons.arrow_left,
                  size: 40,
                  color: Color.fromARGB(255, 151, 56, 188),
                ),
                rightChevronIcon: const Icon(
                  Icons.arrow_right,
                  size: 40,
                  color: Color.fromARGB(255, 151, 56, 188),
                ),
              ),
            ),
          ),
          const Divider(
            thickness: 1,
            height: 10,
          ),
          SizedBox(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: _dayShow,
                          child: const Text(
                            '추가',
                            style: TextStyle(color: Colors.black, fontSize: 17),
                          )),
                    ],
                  ),
                ),
                viewEvents(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
