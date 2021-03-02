import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo canvas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'NetworkImage canvas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ui.Image _mapImage;
  ui.Image _peopleImage;
  @override
  void initState() {
    super.initState();
    _initImage();
  }

  Future<ui.Image> _getImage(String path, Function setFunc) async {
    Completer<ImageInfo> completer = Completer();
    NetworkImage(path)
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    setFunc(imageInfo.image);
  }

  void _initImage() async {
    _getImage(
        'https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/282054/1d84931c-a655-5131-e8b0-26a4768f9730.png',
        (image) {
      setState(() {
        _mapImage = image;
      });
    });
    _getImage(
        'https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/282054/fe1bd18d-098f-99a2-4dbe-721355aa88ac.png',
        (image) {
      setState(() {
        _peopleImage = image;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter: MyMapPainter(
            map: _mapImage,
            people: _peopleImage,
          ),
        ),
      ),
    );
  }
}

class MyMapPainter extends CustomPainter {
  final ui.Image map;
  final ui.Image people;
  MyMapPainter({this.map, this.people});

  @override
  void paint(Canvas canvas, Size size) async {
    if (map != null) {
      canvas.drawImageRect(
        map,
        Rect.fromLTWH(0, 0, size.width.toDouble(), size.height.toDouble()),
        Rect.fromLTWH(
            size.width / 2 - map.width / 2,
            size.height / 2 - map.height / 2,
            size.width.toDouble(),
            size.height.toDouble()),
        new Paint(),
      );
    }
    if (people != null) {
      double peopleWidth = people.width / 12;
      double peopleHeight = people.height / 8;
      canvas.drawImageRect(
        people,
        Rect.fromLTWH(
          peopleWidth * 4,
          peopleHeight * 1,
          peopleWidth,
          peopleHeight,
        ),
        Rect.fromLTWH(
          size.width.toDouble() / 2 - peopleWidth,
          size.height.toDouble() / 2 - peopleHeight,
          peopleWidth,
          peopleHeight,
        ),
        new Paint(),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
