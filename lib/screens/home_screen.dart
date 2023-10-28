import 'dart:typed_data';
import 'package:coupleapp/widgets/image_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // 추가

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Color main = const Color.fromARGB(255, 255, 237, 237);
  Color heart = const Color.fromARGB(255, 255, 119, 119);
  Color main = const Color.fromARGB(255, 255, 255, 255);
  late SharedPreferences _prefs;
  List<Uint8List> imagesData = []; // Uint8List로 변경
  int dDay = 0;
  List<Uint8List> myProfiles = [];
  List<Uint8List> oppProfiles = [];
  String name1 = '';
  String name2 = '';
  int aDay = 0;
  int nDay = 0;

  @override
  void initState() {
    super.initState();
    // clearSharedPreferences();
    _initSharedPreferences();
  }

  Future<void> _loadAnniver() async {
    aDay = 100 - (dDay % 100);
    nDay = aDay + dDay;
  }

  Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 모든 SharedPreferences 데이터 삭제
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadImages(); // SharedPreferences에서 이미지 데이터 불러옴
    _loadDDay();
    _loadName();
    _loadAnniver();
    // print("imagesData : ${imagesData.length}");
    // print("myProfile : ${myProfiles.length}");
    // print("oppProfile : ${oppProfiles.length}");
  }

  // 저장된 날짜 불러오기
  Future<void> _loadDDay() async {
    // final savedDDay = _prefs.getInt('dDay') ?? 0; // 저장된 D-Day 값 불러오기
    final savedSDayString = _prefs.getString('sDay') ?? DateTime.now().toString();
    final savedSDay = DateTime.parse(savedSDayString);

    setState(() {
      dDay = (savedSDay.difference(DateTime.now()).inDays).abs() + 1;
    });
  }

  // 저장된 이미지 불러오기 (SharedPreferences -> 이미지 데이터를 문자열로 디코딩)
  Future<void> _loadImages() async {
    final savedImageList = _prefs.getStringList('myImages');

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
        imagesData.insertAll(0, savedImagesData);
      });
    }
  }

  // 이미지 데이터 저장하기. (이미지 데이터를 문자열로 인코딩 -> SharedPreferences 저장)
  Future<void> _saveImages() async {
    final imageList = imagesData.map((data) {
      final encoded = base64Encode(data); // 이미지 데이터를 Uint8List에서 Base64로 인코딩
      return encoded;
    }).toList();
    await _prefs.setStringList('myImages', imageList);
  }

  // 이미지 picker
  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final imageBytes = await pickedImage.readAsBytes();
      setState(() {
        imagesData.insert(0, Uint8List.fromList(imageBytes)); // 이미지 데이터를 Uint8List로 저장
        _saveImages();
      });
    }
  }

  Future<void> _loadName() async {
    final myProfile = _prefs.getStringList("myProfile");
    final oppProfile = _prefs.getStringList("oppProfile");
    name1 = _prefs.getString('name1') ?? "본인";
    name2 = _prefs.getString('name2') ?? "상대";

    print("name2, $name2");

    if (myProfile != null) {
      final savedImagesData = <Uint8List>[];

      for (final base64String in myProfile) {
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
        myProfiles.insertAll(0, savedImagesData);
      });
    }
    if (oppProfile != null) {
      final savedImagesData = <Uint8List>[];

      for (final base64String in oppProfile) {
        try {
          // 아래) 이미지 데이터를 문자열에서 바이트 배열로 변환하는 과정
          final decoded = base64Decode(base64String);
          savedImagesData.add(Uint8List.fromList(decoded)); // Uint8List형식으로 리스트에 저장
        } catch (e) {
          print("예외 발생: $e");
        }
      }
      setState(() {
        oppProfiles.insertAll(0, savedImagesData);
      });
    }
  }

  void onIconClick(int index) {
    print(index);
    print("이미지 길이 ${imagesData.length}");
    imagesData.removeAt(index);
    setState(() {
      _saveImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imagesData.isNotEmpty)
          ImageViewer(imagesData, main, onIconClick)
        else
          Container(
            height: 200,
            color: main,
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "아래 버튼으로 사진등록",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    Icon(
                      Icons.arrow_downward_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: main),
                height: 40,
                width: 130,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: heart,
                    ),
                    Text(
                      "$dDay",
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _getImage,
                icon: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: main, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.camera_alt_sharp),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  if (myProfiles.isNotEmpty)
                    Container(
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(50), color: main),
                      height: 100,
                      width: 100,
                      clipBehavior: Clip.hardEdge,
                      child: Image.memory(
                        myProfiles.first,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(50), color: main),
                      height: 100,
                      width: 100,
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    name1,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  )
                ],
              ),
              Icon(Icons.favorite, size: 35, color: heart),
              Column(
                children: [
                  if (oppProfiles.isNotEmpty)
                    Container(
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(50), color: main),
                      height: 100,
                      width: 100,
                      clipBehavior: Clip.hardEdge,
                      child: Image.memory(
                        oppProfiles.first,
                        // imagesData[0], // 이미지 데이터를 바이트 배열로 표시
                        // width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(50), color: main),
                      height: 100,
                      width: 100,
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    name2,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: main),
                height: 40,
                width: 130,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: heart,
                    ),
                    const Text(
                      "D-Day",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            children: [
              Text(
                "다음 $nDay일까지 앞으로 $aDay일 남았습니다.",
                style: const TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
