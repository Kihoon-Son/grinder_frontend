import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

enum MenuType { PurchaseLink, Information, Reviews, Add_comment }
late VideoPlayerController controller;

main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var showDetail = false;
  double fps = 24.0;
  double startX = 250;
  double startY = 330;

  List predictionResult = [];

  // Fetch content from the json file
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/json/MOTResult.json');
    final data = await json.decode(response);
    setState(() {
      predictionResult = data["predictions"];
    });
  }

  @override
  void initState() {
    loadVideoPlayer();
    readJson();
    super.initState();
  }

  loadVideoPlayer() {
    controller = VideoPlayerController.asset('assets/videos/sample2.mp4');
    controller.addListener(() {
      setState(() {});
    });
    controller.initialize().then((value) {
      setState(() {});
    });
  }

  int getCurrentFrameNumber() {
    double currentPosition =
        controller.value.position.inMilliseconds.toDouble() / 1000 * 24;
    return currentPosition.toInt();
  }

  List<VideoFrameObject> getObjectsInCurrentFrame() {
    List result = List.from(predictionResult);
    List<VideoFrameObject> finalResult = [];
    int currentFrameNumber = getCurrentFrameNumber();
    int startIndex =
        predictionResult.indexWhere((f) => f['frame'] == currentFrameNumber);
    int lastIndex = predictionResult
        .lastIndexWhere((f) => f['frame'] == currentFrameNumber);
    result = result.sublist(startIndex, lastIndex).toList();
    for (int i = 0; i < result.length; i++) {
      finalResult.add(VideoFrameObject(
          result[i]['frame'],
          result[i]['object_id'],
          result[i]['class_name'],
          result[i]['top'],
          result[i]['left'],
          result[i]['height'],
          result[i]['width']));
    }
    print(finalResult);
    return finalResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Grinder"),
        backgroundColor: Color.fromRGBO(95, 131, 89, 1),
      ),
      body: SizedBox(
        child: SingleChildScrollView(
          child: Center(
              child: Container(
            child: Row(
              children: [
                Flexible(
                    child: Stack(
                      children: [
                        // Video Player
                        Container(
                          width: 480,
                          height: 720,
                          margin: EdgeInsets.all(20),
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                        ),
                        // Floating Btn

                        Container(
                            // The specific location will be decided from the bbox.
                            margin:
                                EdgeInsets.fromLTRB(startX++, startY++, 0, 0),
                            width: 50,
                            height: 50,
                            child: CustomFloatingBtn()),
                      ],
                    ),
                    flex: 4),
                Flexible(
                    child: Column(children: [
                      // Video Progress Bar
                      Row(
                        children: [
                          Container(
                            width: 150,
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                            child: Container(
                                child: IconButton(
                                    onPressed: () {
                                      if (controller.value.isPlaying) {
                                        controller.pause();
                                      } else {
                                        controller.play();
                                      }
                                      setState(() {});
                                    },
                                    icon: Icon(controller.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow))),
                          ),
                          Container(
                              width: 900,
                              padding: EdgeInsets.fromLTRB(0, 0, 50, 15),
                              child: VideoProgressIndicator(controller,
                                  allowScrubbing: true,
                                  colors: VideoProgressColors(
                                    playedColor:
                                        Color.fromARGB(255, 180, 105, 20),
                                    backgroundColor:
                                        Color.fromARGB(50, 0, 0, 0),
                                    bufferedColor:
                                        Color.fromARGB(216, 235, 189, 91),
                                  ))),
                        ],
                      ),
                      // Object Detection Timeline
                      Row(
                        children: [
                          Container(
                              width: 150,
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Text(
                                "Toothbrush",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              )),
                          Container(
                              width: 900,
                              padding: EdgeInsets.fromLTRB(0, 0, 50, 0),
                              child: Stack(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: 15,
                                    color: Color.fromARGB(105, 223, 223, 223),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.fromLTRB(50, 0, 0, 0),
                                    width: 240,
                                    height: 15,
                                    color: Color.fromARGB(249, 72, 202, 78),
                                  ),
                                  VideoProgressIndicator(controller,
                                      allowScrubbing: true,
                                      colors: VideoProgressColors(
                                        playedColor: Color.fromRGBO(0, 0, 0, 0),
                                        backgroundColor:
                                            Color.fromARGB(0, 0, 0, 0),
                                        bufferedColor:
                                            Color.fromRGBO(0, 0, 0, 0),
                                      ))
                                ],
                              )),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              width: 150,
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Text(
                                "Toothbrush",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              )),
                          Container(
                              width: 900,
                              padding: EdgeInsets.fromLTRB(0, 0, 50, 0),
                              child: Stack(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: 15,
                                    color: Color.fromARGB(105, 223, 223, 223),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.fromLTRB(50, 0, 0, 0),
                                    width: 240,
                                    height: 15,
                                    color: Color.fromARGB(249, 72, 202, 78),
                                  ),
                                  VideoProgressIndicator(controller,
                                      allowScrubbing: true,
                                      colors: VideoProgressColors(
                                        playedColor: Color.fromRGBO(0, 0, 0, 0),
                                        backgroundColor:
                                            Color.fromARGB(0, 0, 0, 0),
                                        bufferedColor:
                                            Color.fromRGBO(0, 0, 0, 0),
                                      ))
                                ],
                              )),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              width: 150,
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Text(
                                "Toothbrush",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              )),
                          Container(
                              width: 900,
                              padding: EdgeInsets.fromLTRB(0, 0, 50, 0),
                              child: Stack(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: 15,
                                    color: Color.fromARGB(105, 223, 223, 223),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.fromLTRB(50, 0, 0, 0),
                                    width: 240,
                                    height: 15,
                                    color: Color.fromARGB(249, 72, 202, 78),
                                  ),
                                  VideoProgressIndicator(controller,
                                      allowScrubbing: true,
                                      colors: VideoProgressColors(
                                        playedColor: Color.fromRGBO(0, 0, 0, 0),
                                        backgroundColor:
                                            Color.fromARGB(0, 0, 0, 0),
                                        bufferedColor:
                                            Color.fromRGBO(0, 0, 0, 0),
                                      ))
                                ],
                              )),
                        ],
                      ),
                      // Info Tab
                      Container(
                        margin: EdgeInsets.all(20),
                        height: 700,
                        color: Colors.black,
                      )
                    ]),
                    flex: 7),
              ],
            ),
          )),
        ),
      ),
    );
  }
}

class ShowDetailInfo extends StatelessWidget {
  const ShowDetailInfo({Key? key, this.showDetail}) : super(key: key);
  final showDetail;
  show() {
    print(showDetail);
    return Image.asset(
      'assets/images/sample1.png',
      height: 600,
      fit: BoxFit.fill,
    );
  }

  notShow() {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.black,
        child: showDetail ? show() : notShow(),
      ),
    );
  }
}

class CustomFloatingBtn extends StatefulWidget {
  const CustomFloatingBtn({Key? key}) : super(key: key);
  @override
  State<CustomFloatingBtn> createState() => _CustomFloatingBtnState();
}

class _CustomFloatingBtnState extends State<CustomFloatingBtn> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuType>(
      onSelected: (value) {
        controller.pause();
      },
      icon: Icon(
        Icons.add_box_rounded,
        size: 40.0,
        color: Color.fromARGB(255, 73, 122, 64),
      ),
      itemBuilder: (BuildContext context) => MenuType.values
          .map((value) => PopupMenuItem(
                value: value,
                child: Text(value.name),
              ))
          .toList(),
    );
  }
}

class VideoFrameObject {
  int? frame;
  int? object_id;
  String? class_name;
  double? top;
  double? left;
  double? height;
  double? width;

  VideoFrameObject(int frame, int object_id, String class_name, double top,
      double left, double height, double width) {
    this.frame = frame;
    this.object_id = object_id;
    this.class_name = class_name;
    this.top = top;
    this.left = left;
    this.height = height;
    this.width = width;
  }
}
