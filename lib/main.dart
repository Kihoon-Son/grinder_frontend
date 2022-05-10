import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:rating_dialog/rating_dialog.dart';

enum MenuType { PurchaseLink, Information, Reviews, Add_comment }
late VideoPlayerController controller;
int totalDuration = 20800;

int FSbanana = 0;
int LSbanana = 5440;
int FSTooth = 5440;
int LSTooth = 8508;
int FSSoap = 8508;
int LSSoap = 13998;
int FSTowel = 13998;
int LSTowel = 20800;

bool itemselected = false;
int selectedItem = -1;

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
  double fps = 24.0;
  double startX = 350;
  double startY = 500;

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
      body: Container(
        color: Colors.white,
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
                                EdgeInsets.fromLTRB(startX++, startY--, 0, 0),
                            width: 50,
                            height: 50,
                            child: checkToothBrushCondition(FSTooth, LSTooth)
                                ? CustomMarking()
                                : null),
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
                                        print(controller.value.position
                                            .inMicroseconds.runtimeType);
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
                      ObjectDetectionTimeline(
                          objectName: "Vitamin",
                          start: FSbanana,
                          end: LSbanana),
                      ObjectDetectionTimeline(
                          objectName: "ToothBrush",
                          start: FSTooth,
                          end: LSTooth),
                      ObjectDetectionTimeline(
                          objectName: "Soap", start: FSSoap, end: LSSoap),
                      ObjectDetectionTimeline(
                          objectName: "Towel", start: FSTowel, end: LSTowel),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 100, 20, 0),
                          height: 600,
                          child: ShowInfo())
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

class ObjectDetectionTimeline extends StatelessWidget {
  ObjectDetectionTimeline(
      {Key? key, this.objectName, required this.start, required this.end})
      : super(key: key);
  final objectName;
  int start;
  int end;
  final int progressWidth = 900;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 150,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Text(
              objectName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: checkToothBrushCondition(start, end)
                      ? Color.fromARGB(255, 0, 0, 0)
                      : Color.fromARGB(50, 0, 0, 0)),
            )),
        Container(
            width: progressWidth.toDouble(),
            padding: EdgeInsets.fromLTRB(0, 0, 50, 0),
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 15,
                  color: checkToothBrushCondition(start, end)
                      ? Color.fromARGB(105, 223, 223, 223)
                      : Color.fromARGB(50, 223, 223, 223),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(
                      progressWidth * (start / totalDuration), 0, 0, 0),
                  width: progressWidth *
                      (end / totalDuration - start / totalDuration),
                  height: 15,
                  color: checkToothBrushCondition(start, end)
                      ? Color.fromARGB(248, 73, 151, 77)
                      : Color.fromARGB(50, 73, 151, 77),
                ),
                VideoProgressIndicator(controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Color.fromRGBO(0, 0, 0, 0),
                      backgroundColor: Color.fromARGB(0, 0, 0, 0),
                      bufferedColor: Color.fromRGBO(0, 0, 0, 0),
                    ))
              ],
            )),
      ],
    );
  }
}

class ShowInfo extends StatefulWidget {
  const ShowInfo({Key? key}) : super(key: key);

  @override
  State<ShowInfo> createState() => _ShowInfoState();
}

class _ShowInfoState extends State<ShowInfo> {
  String imageName = "";
  @override
  Widget build(BuildContext context) {
    if (selectedItem == 0) {
      imageName = 'assets/images/purchase_page.png';
    } else if (selectedItem == 1) {
      imageName = 'assets/images/detail_page.png';
    }
    if (selectedItem == 0 || selectedItem == 1) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  imageName,
                  alignment: Alignment.center,
                )),
            Container(
              width: 20,
              height: 20,
              margin: EdgeInsets.fromLTRB(0, 5, 5, 0),
              child: Stack(
                children: [
                  FloatingActionButton.extended(
                      label: Text("X"),
                      backgroundColor: Colors.red,
                      onPressed: () {
                        setState(() {
                          itemselected = false;
                          selectedItem = -1;
                        });
                      })
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
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
        itemselected = true;
        selectedItem = value.index;
        print(itemselected);
        print(selectedItem);
        if (value.index == 0) {
          print("hello purchace");
        } else if (value.index == 1) {
          print("hello info");
        } else if (value.index == 2) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => _dialog(),
          );
        } else if (value.index == 3) {
          print("hello comment");
        }
      },
      icon: Icon(
        Icons.add_box_rounded,
        size: 50.0,
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

class CustomMarking extends StatelessWidget {
  const CustomMarking({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          CustomFloatingBtn(),
        ],
      ),
    );
  }
}

bool checkToothBrushCondition(int start, int end) {
  print(controller.value.position.inMilliseconds);
  if (controller.value.position.inMilliseconds > start &&
      controller.value.position.inMilliseconds < end) {
    return true;
  } else {
    return false;
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

Widget _dialog() => RatingDialog(
      initialRating: 1.0,
      // your app's name?
      title: Text(
        '리뷰 남기기',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      // encourage your user to leave a high rating?
      message: Text(
        '제품에 대한 별점과 짧은 후기를 남겨주세요.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15),
      ),
      // your app's logo?
      // image: const FlutterLogo(size: 100),
      submitButtonText: '제출',
      commentHint: '제품에 대해 평가해주세요',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        print(response.comment);
        itemselected = false;
        selectedItem = -1;
      },
    );
