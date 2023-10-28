import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetScreen extends StatefulWidget {
  const SetScreen({super.key});

  @override
  State<SetScreen> createState() => _SetScreenState();
}

class _SetScreenState extends State<SetScreen> {
  Color main = const Color.fromARGB(255, 255, 166, 166);
  DateTime selectedDate = DateTime.now();
  DateTime today = DateTime.now();
  int dDay = 0;
  DateTime sDay = DateTime.now();
  int tDay = 0;

  bool myopp = true;
  List<Uint8List> proImagesData = [];
  List<Uint8List> myProfile = [];
  List<Uint8List> oppProfile = [];

  String name1 = '';
  String name2 = '';

  @override
  void initState() {
    super.initState();
    loadDDay(); // 앱 시작 시 D-Day 값을 불러옴
    loadName();
    _loadImages();
  }

  void _selectDate() async {
    DateTime? pickedDate = await showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (BuildContext builder) {
        return SizedBox(
          height: MediaQuery.of(context).copyWith().size.height / 2.5,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedDate = DateTime.now();
                      });
                      // 취소 버튼 눌렀을 때의 동작
                      Navigator.of(context).pop(null); // 다이얼로그 닫기
                    },
                    icon: const Icon(Icons.clear_rounded),
                  ),
                  IconButton(
                    onPressed: () {
                      // 선택 버튼 눌렀을 때의 동작
                      Navigator.of(context).pop(selectedDate); // 선택한 날짜 반환 및 다이얼로그 닫기
                    },
                    icon: const Icon(Icons.check),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).copyWith().size.height / 3,
                child: CupertinoDatePicker(
                  initialDateTime: sDay,
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  },
                  maximumDate: DateTime(2024),
                  minimumYear: 2000,
                  maximumYear: 2024,
                  use24hFormat: false,
                ),
              ),
            ],
          ),
        );
      },
    );

    print("pickedDate = $pickedDate, selectDate = $selectedDate");

    // 다이얼로그를 닫거나 "취소" 버튼을 누르면 pickedDate는 null이 된다.
    if (pickedDate != null) {
      // 날짜를 선택한 경우에만 D-Day를 다시 계산하고 저장
      var days = selectedDate.difference(today).inDays;
      sDay = selectedDate;

      setState(() {
        selectedDate = pickedDate;
        dDay = days.abs() + 1; // 음수인 경우 양수로 변환
      });

      savedDDay();
    } else {
      setState(() {
        selectedDate = DateTime.now();
      });
    }
  }

  Future<void> loadDDay() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDDay = prefs.getInt('dDay') ?? 0; // 저장된 D-Day 값 불러오기

    final savedSDayString = prefs.getString('sDay') ?? DateTime.now().toString();
    final savedSDay = DateTime.parse(savedSDayString);

    print('---$savedDDay'); // D-Day 값 출력

    setState(() {
      dDay = selectedDate.difference(savedSDay).inDays + 1;

      sDay = savedSDay;
    });
  }

  // D-Day 값을 저장
  Future<void> savedDDay() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dDay', dDay);

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    await prefs.setString('sDay', formattedDate);
  }

  //이름값을 저장
  Future<void> saveName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name1', name1);
    await prefs.setString('name2', name2);
  }

  //이름값을 불러오기
  Future<void> loadName() async {
    final prefs = await SharedPreferences.getInstance();
    name1 = prefs.getString('name1') ?? "본인";
    name2 = prefs.getString('name2') ?? "상대";
  }

// 이름값
  void _editDate() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (BuildContext builder) {
        return SizedBox(
          height: MediaQuery.of(context).copyWith().size.height / 2.5,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        loadName();
                      });
                      // 취소 버튼 눌렀을 때의 동작
                      Navigator.of(context).pop(null); // 다이얼로그 닫기
                    },
                    icon: const Icon(Icons.clear_rounded),
                  ),
                  IconButton(
                    onPressed: () {
                      saveName();
                      // 선택 버튼 눌렀을 때의 동작
                      Navigator.of(context).pop(); // 선택한 날짜 반환 및 다이얼로그 닫기
                    },
                    icon: const Icon(Icons.check),
                  ),
                ],
              ),
              SizedBox(
                  // height: MediaQuery.of(context).copyWith().size.height / 3,
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      child: Align(
                        alignment: Alignment.center,
                        child: TextField(
                          decoration:
                              const InputDecoration(labelText: '본인', border: OutlineInputBorder()),
                          onChanged: (value) {
                            setState(() {
                              name1 = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: Align(
                        alignment: Alignment.center,
                        child: TextField(
                          decoration:
                              const InputDecoration(labelText: '상대', border: OutlineInputBorder()),
                          onChanged: (value) {
                            setState(() {
                              name2 = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  //imagePicker----
  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final imageBytes = await pickedImage.readAsBytes();
      setState(() {
        proImagesData.clear();
        proImagesData.add(Uint8List.fromList(imageBytes));
        _saveImages();
      });
    }
  }

  Future<void> _loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImageList = prefs.getStringList('myProfile');

    if (savedImageList != null) {
      final savedImagesData = <Uint8List>[];

      for (final base64String in savedImageList) {
        try {
          // 아래) 이미지 데이터를 문자열에서 바이트 배열로 변환하는 과정
          final decoded = base64Decode(
              base64String); // Shared...에서 받아온 문자열을 Base64로 디코딩하여 바이트 배열(Uint8List)형태로 변환
          savedImagesData.add(Uint8List.fromList(decoded)); // Uint8List형식으로 리스트에 저장
        } catch (e) {
          // 예외 처리: 잘못된 데이터는 건너뜀
          print("예외 발생: $e");
        }
      }
      setState(() {
        myProfile.insertAll(0, savedImagesData);
      });
    }

    final oppsavedImageList = prefs.getStringList('oppProfile');

    if (oppsavedImageList != null) {
      final oppsavedImageData = <Uint8List>[];

      for (final base64String in oppsavedImageList) {
        try {
          final decoded = base64Decode(base64String);
          oppsavedImageData.add(Uint8List.fromList(decoded));
        } catch (e) {
          print("예외 발생: $e");
        }
      }
      setState(() {
        oppProfile.insertAll(0, oppsavedImageData);
      });
    }
  }

  Future<void> _saveImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final imageList = proImagesData.map((data) {
      final encoded = base64Encode(data); // 이미지 데이터를 Uint8List에서 Base64로 인코딩
      return encoded;
    }).toList();

    if (myopp == true) {
      await prefs.setStringList('myProfile', imageList);
    } else {
      await prefs.setStringList('oppProfile', imageList);
    }
    setState(() {
      _loadImages();
    });
    print("proImagesData : ${proImagesData.length}");
  }

  Future<void> _editPicture() async {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '${sDay.year}.${sDay.month}.${sDay.day}',
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                '$dDay',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${today.year}.${today.month}.${today.day}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _selectDate(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: main, // 배경색 설정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 모양 설정
                  ),
                  minimumSize: const Size(130, 40), // 최소 크기 설정
                ),
                child: const Text(
                  "날짜 선택",
                  style: TextStyle(
                    fontSize: 19,
                  ),
                ),
              ),
              //숨기기
              Visibility(
                visible: false,
                child: ElevatedButton(
                  onPressed: () => _editPicture(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: main, // 배경색 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // 모양 설정
                    ),
                    minimumSize: const Size(130, 40), // 최소 크기 설정
                  ),
                  child: const Text(
                    "배너 사진",
                    style: TextStyle(
                      fontSize: 19,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 40,
          ),
          // 사진선택
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 150,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  name1,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              if (myProfile.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        50,
                      ),
                      color: main),
                  height: 100,
                  width: 100,
                  clipBehavior: Clip.hardEdge,
                  child: GestureDetector(
                    onTap: () {
                      myopp = true;
                      _getImage();
                    },
                    child: Stack(
                      children: [
                        Image.memory(
                          myProfile.first,
                          // imagesData[0], // 이미지 데이터를 바이트 배열로 표시
                          // width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 15,
                          left: 15,
                          child: Icon(
                            Icons.camera, // 여기에 사용하고자 하는 아이콘을 지정하세요.
                            color: Colors.white.withOpacity(0.5),
                            size: 70,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: main.withOpacity(0.5),
                  ),
                  height: 100,
                  width: 100,
                  child: GestureDetector(onTap: () {
                    myopp = true;
                    _getImage();
                  }),
                ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 150,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  name2,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              if (oppProfile.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: main,
                  ),
                  height: 100,
                  width: 100,
                  clipBehavior: Clip.hardEdge,
                  child: GestureDetector(
                    onTap: () {
                      myopp = false;
                      _getImage();
                    },
                    child: Stack(children: [
                      Image.memory(
                        oppProfile.first,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 15,
                        left: 15,
                        child: Icon(
                          Icons.camera, // 여기에 사용하고자 하는 아이콘을 지정하세요.
                          color: Colors.white.withOpacity(0.5),
                          size: 70,
                        ),
                      ),
                    ]),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: main.withOpacity(0.5),
                  ),
                  height: 100,
                  width: 100,
                  child: GestureDetector(
                    onTap: () {
                      myopp = false;
                      _getImage();
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _editDate(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: main, // 배경색 설정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 모양 설정
                  ),
                  minimumSize: const Size(130, 40), // 최소 크기 설정
                ),
                child: const Text(
                  "이름 편집",
                  style: TextStyle(
                    fontSize: 19,
                  ),
                ),
              ),
              Visibility(
                visible: false,
                child: ElevatedButton(
                  onPressed: () => _editDate(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: main, // 배경색 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // 모양 설정
                    ),
                    minimumSize: const Size(130, 40), // 최소 크기 설정
                  ),
                  child: const Text(
                    "날짜 설정",
                    style: TextStyle(
                      fontSize: 19,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
