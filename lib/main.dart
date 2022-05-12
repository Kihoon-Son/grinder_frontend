import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:grinder_frontend/products.dart';

enum MenuType { Information, RelatedProduct, Reviews }
List<String> menu = ["제품 정보", "관련상품 추가", "리뷰 추가"];
late VideoPlayerController controller;
int totalDuration = 20800;

int FSbanana = 0;
int LSbanana = 5200;
int FSTooth = 5200;
int LSTooth = 8508;
int FSSoap = 8508;
int LSSoap = 13998;
int FSTowel = 13998;
int LSTowel = 20800;

String clickedPurchaseLinkProduct = "";
String clickedPurchaseLinkProductName = "";

bool itemselected = false;
int selectedItem = -1;
Marker candyMarker = Marker(300, 420, true);
Marker toothbrushMarker = Marker(350, 500, true);
Marker soapMarker = Marker(350, 480, true);
Marker towelMarker = Marker(350, 300, true);

Product candy = Product(candyMarker, "사탕", FSbanana, LSbanana);
Product toothBrush = Product(toothbrushMarker, "칫솔", FSTooth, LSTooth);
Product soap = Product(soapMarker, "비누", FSSoap, LSSoap);
Product towel = Product(towelMarker, "타월", FSTowel, LSTowel);

Review pre_review1 = new Review(4.5, "비누거품 양이 적절해요.", 10000);
Review pre_review2 = new Review(4.0, "칫솔 솔이 생각보다 부드러움", 6500);

List<Product> allProducts = [candy, toothBrush, soap, towel];
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
    soap.reviews.add(pre_review1);
    toothBrush.reviews.add(pre_review2);
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

  uploadVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.single;
      setState(() {
        // _controller = VideoPlayerController.file(file, videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
        // _controller?.play();
        // uploadFile(file.bytes as List<int>);
      });
    } else {
      // User canceled the picker
    }
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
        elevation: 100,
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          margin: EdgeInsets.all(20),
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                        ),

                        // Floating Btn
                        GenerateMarker(
                            marker: toothbrushMarker, product: toothBrush),
                        GenerateMarker(marker: candyMarker, product: candy),
                        GenerateMarker(marker: soapMarker, product: soap),
                        GenerateMarker(marker: towelMarker, product: towel),
                      ],
                    ),
                    flex: 4),
                Flexible(
                    child: Column(children: [
                      // Video Progress Bar
                      Container(
                        child: Row(
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
                      ),
                      // Object Detection Timeline
                      ObjectDetectionTimeline(
                        objectName: "사탕",
                        product: candy,
                      ),
                      ObjectDetectionTimeline(
                        objectName: "칫솔",
                        product: toothBrush,
                      ),
                      ObjectDetectionTimeline(
                        objectName: "비누",
                        product: soap,
                      ),
                      ObjectDetectionTimeline(
                        objectName: "타월",
                        product: towel,
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 10, 70, 0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 10,
                                height: 20,
                                color: Color.fromARGB(248, 73, 151, 77),
                              ),
                              Text("  상품등장 타임라인   "),
                              Container(
                                width: 10,
                                height: 20,
                                color: Colors.yellow,
                              ),
                              Text("  리뷰 정보  "),
                              Container(
                                width: 10,
                                height: 20,
                                color: Color.fromARGB(248, 0, 179, 255),
                              ),
                              Text("  관련 상품")
                            ]),
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 40, 20, 0),
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

class GenerateMarker extends StatelessWidget {
  const GenerateMarker({Key? key, required this.marker, required this.product})
      : super(key: key);
  final Marker marker;
  final Product product;
  @override
  Widget build(BuildContext context) {
    if (marker.isCreated) {
      return Container(
          // The specific location will be decided from the bbox.
          margin: EdgeInsets.fromLTRB(marker.x, marker.y, 0, 0),
          child: checkToothBrushCondition(product.start, product.end)
              ? CustomMarking(
                  marker: marker,
                  product: product,
                )
              : null);
    } else {
      return Container();
    }
  }
}

class ObjectDetectionTimeline extends StatelessWidget {
  ObjectDetectionTimeline({Key? key, this.objectName, required this.product})
      : super(key: key);
  Product product;
  final objectName;
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
                  color: checkToothBrushCondition(product.start, product.end)
                      ? Color.fromARGB(255, 0, 0, 0)
                      : Color.fromARGB(50, 0, 0, 0)),
            )),
        Container(
            width: progressWidth.toDouble(),
            padding: EdgeInsets.fromLTRB(0, 0, 50, 0),
            child: Stack(
              children: [
                // for whole progress bar
                Container(
                  alignment: Alignment.center,
                  height: 15,
                  color: checkToothBrushCondition(product.start, product.end)
                      ? Color.fromARGB(214, 211, 211, 211)
                      : Color.fromARGB(50, 223, 223, 223),
                ),
                // for object presenting timeline
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(
                      progressWidth * (product.start / totalDuration), 0, 0, 0),
                  width: progressWidth *
                      (product.end / totalDuration -
                          product.start / totalDuration),
                  height: 15,
                  color: checkToothBrushCondition(product.start, product.end)
                      ? Color.fromARGB(248, 73, 151, 77)
                      : Color.fromARGB(50, 73, 151, 77),
                ),
                // for current position

                // for reviews
                for (Review rv in product.reviews)
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        progressWidth * (rv.time! / totalDuration), 0, 0, 0),
                    width: 10,
                    height: 15,
                    color: Color.fromARGB(255, 255, 242, 0),
                    child: Tooltip(
                        textStyle: TextStyle(fontSize: 15, color: Colors.white),
                        height: 100,
                        margin: EdgeInsets.all(20),
                        message: "평점: " +
                            rv.rating.toString() +
                            "\n" +
                            "의견: " +
                            rv.comment.toString()),
                  ),
                // for reviews
                for (RelProduct rp in product.relProducts)
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        progressWidth * (rp.time! / totalDuration), 0, 0, 0),
                    width: 10,
                    height: 15,
                    color: Color.fromARGB(255, 0, 179, 255),
                    child: Tooltip(
                        textStyle: TextStyle(fontSize: 15, color: Colors.white),
                        height: 100,
                        margin: EdgeInsets.all(20),
                        message: "관련 상품: " + rp.productName.toString()),
                  ),
                VideoProgressIndicator(controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Color.fromRGBO(0, 0, 0, 0),
                      backgroundColor: Color.fromARGB(0, 0, 0, 0),
                      bufferedColor: Color.fromRGBO(0, 0, 0, 0),
                    )),
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
    TextEditingController _controller = new TextEditingController();
    String link;

    if ((clickedPurchaseLinkProduct != "" && selectedItem == 1) ||
        selectedItem == 0) {
      if (selectedItem == 1) {
        imageName = 'assets/images/purchase_page.png';
      } else if (selectedItem == 0) {
        String productName = "";
        if (clickedPurchaseLinkProductName == "사탕") {
          productName = "candy";
        } else if (clickedPurchaseLinkProductName == "칫솔") {
          productName = "toothbrush";
        } else if (clickedPurchaseLinkProductName == "비누") {
          productName = "soap";
        } else if (clickedPurchaseLinkProductName == "타월") {
          productName = "towel";
        }
        imageName = 'assets/images/' + productName + '_detail.png';
      }
      if (selectedItem == 1 || selectedItem == 0) {
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
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 2), // changes position of shadow
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
                            controller.play();
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
    } else if (clickedPurchaseLinkProduct == "" && selectedItem == 1) {
      return ProductPickerPage();
    } else {
      // TEXT box!!
      return SizedBox.shrink();
    }
    ;
  }
}

class CustomFloatingBtn extends StatefulWidget {
  const CustomFloatingBtn(
      {Key? key, required this.marker, required this.product})
      : super(key: key);
  final Marker marker;
  final Product product;

  @override
  State<CustomFloatingBtn> createState() => _CustomFloatingBtnState();
}

class _CustomFloatingBtnState extends State<CustomFloatingBtn> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuType>(
      tooltip: "Click!",
      onSelected: (value) {
        controller.pause();
        itemselected = true;
        selectedItem = value.index;
        print(widget.product.name);
        if (value.index == 0) {
          print("hello purchace");
          clickedPurchaseLinkProduct = widget.product.purchaseLink;
          clickedPurchaseLinkProductName = widget.product.name;
          print(clickedPurchaseLinkProductName);
          print("---");
        } else if (value.index == 1) {
          clickedPurchaseLinkProduct = widget.product.purchaseLink;
          clickedPurchaseLinkProductName = widget.product.name;
          print("hello info");
        } else if (value.index == 2) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => _dialog(widget.product),
          );
        }
      },
      icon: Icon(Icons.add, size: 25.0, color: Colors.white),
      itemBuilder: (BuildContext context) => MenuType.values
          .map((value) => PopupMenuItem(
                value: value,
                child: Text(menu[value.index]),
              ))
          .toList(),
    );
  }
}

class CustomMarking extends StatelessWidget {
  const CustomMarking({Key? key, required this.marker, required this.product})
      : super(key: key);
  final Marker marker;
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Text(
              product.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 73, 122, 64),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: CustomFloatingBtn(
              marker: marker,
              product: product,
            ),
          ),
        ],
      ),
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

Widget _dialog(Product product) => RatingDialog(
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
        style: const TextStyle(fontSize: 25),
      ),
      // your app's logo?
      // image: const FlutterLogo(size: 100),
      submitButtonText: '제출',
      commentHint: '제품에 대해 평가해주세요',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        print(response.comment);
        print(product.name);
        product.reviews.add(Review(response.rating, response.comment,
            controller.value.position.inMilliseconds));
        controller.play();
        itemselected = false;
        selectedItem = -1;
      },
    );

bool checkToothBrushCondition(int start, int end) {
  if (controller.value.position.inMilliseconds > start &&
      controller.value.position.inMilliseconds < end) {
    return true;
  } else {
    return false;
  }
}

class Review {
  double? rating;
  String? comment;
  int? time;

  Review(double rating, String comment, int time) {
    this.rating = rating;
    this.comment = comment;
    this.time = time;
  }
}

class RelProduct {
  String? originProductName;
  String? productName;
  int? time;

  RelProduct(String originProductName, String productName, int time) {
    this.originProductName = originProductName;
    this.productName = productName;
    this.time = time;
  }
}

class Marker {
  double x = 0;
  double y = 0;
  bool isCreated = false;

  Marker(double x, double y, bool isCreated) {
    this.x = x;
    this.y = y;
    this.isCreated = isCreated;
  }
}

class Product {
  Marker? marker = Marker(0, 0, false);
  List<Review> reviews = [];
  List<RelProduct> relProducts = [];
  String name = "";
  String purchaseLink = "";
  int start = 0;
  int end = 0;

  Product(Marker? marker, String name, int start, int end) {
    this.marker = marker;
    this.name = name;
    this.start = start;
    this.end = end;
  }

  void printAllReviews() {
    for (int i = 0; i < reviews.length; i++) {
      print(reviews[i].comment);
    }
  }
}

class ProductPickerPage extends StatefulWidget {
  ProductPickerPage({Key? key}) : super(key: key);
  @override
  State<ProductPickerPage> createState() => _ProductPickerPageState();
}

class _ProductPickerPageState extends State<ProductPickerPage> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: products.length, itemBuilder: buildProductItem);
  }

  Widget buildProductItem(BuildContext context, int index) {
    var product = products.elementAt(index);
    return Center(
      child: InkWell(
        onTap: () => onProductSelect(product),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(product.thumb, width: 100),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 15),
                      Text(
                        product.thumb,
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider()
          ],
        ),
      ),
    );
  }

  onProductSelect(Prod product) {
    print("HI there!!!!");
    print(clickedPurchaseLinkProductName);
    print(product.name);
    print(controller.value.position.inMilliseconds);
    int index = 0;
    for (index = 0; index < allProducts.length; index++) {
      if (allProducts[index].name == clickedPurchaseLinkProductName) break;
    }
    allProducts[index].relProducts.add(RelProduct(clickedPurchaseLinkProduct,
        product.name, controller.value.position.inMilliseconds));

    setState(() {
      itemselected = false;
      selectedItem = -1;
      controller.play();
    });
  }
}
