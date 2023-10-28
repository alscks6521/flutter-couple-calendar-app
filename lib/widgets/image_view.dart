import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final List<Uint8List> imagesData;
  final Color main;
  final Function(int) onIconClick;

  const ImageViewer(this.imagesData, this.main, this.onIconClick, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: main,
      child: ListView.builder(
        itemCount: imagesData.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Image.memory(
                imagesData[index], // 이미지 데이터를 바이트 배열로 표시
                height: 200,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    onIconClick(index);
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
