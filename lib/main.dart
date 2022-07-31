import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({Key? key}) : super(key: key);

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  List hits = [];

  Future<void> fetchImages(String text) async {
    Response response = await Dio().get(
        'https://pixabay.com/api/?key=28885949-dc2f61ba7f15747f367fa328f&q=$text&image_type=photo&per_page=30');
    hits = response.data['hits'];
    setState(() {});
    print(hits);
  }

  @override
  void initState() {
    super.initState(); //最初に一度だけ呼ばれる
    fetchImages('花');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          initialValue: '花',
          decoration: const InputDecoration(
            fillColor: Colors.white,
            filled: true,
          ),
          onFieldSubmitted: (text) {
            fetchImages(text);
          },
        ),
      ),
      body: GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemCount: hits.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> hit = hits[index];
            return InkWell(
              onTap: () async {
                // 1.URLから画像をDL
                Response response = await Dio().get(
                  hit['webformatURL'],
                  options: Options(responseType: ResponseType.bytes),
                );

                // 2.DLしたデータをファイルに保存
                Directory dir = await getTemporaryDirectory();
                File file = await File(dir.path + '/image.png')
                    .writeAsBytes(response.data);

                // 3.Shareパッケージを呼び出して共有
                Share.shareFiles([file.path]);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    hit['previewURL'],
                    fit: BoxFit.cover,
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.thumb_up_off_alt_outlined,
                                size: 14,
                              ),
                              Text('${hit['likes']}'),
                            ],
                          ))),
                ],
              ),
            );
          }),
    );
  }
}
