import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:nature_wallpapers/utils/DataHolder.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class FullScreen extends StatefulWidget {
  String imgUrl;
  int index;
  String dataDirectory;
  FullScreen(String imgUrl, int index, String dataDirectory){
    this.imgUrl = imgUrl;
    this.index = index;
    this.dataDirectory = dataDirectory;
  }

 // const Thumbnail({Key key, this.size, this.image}) : super(key:key);
  @override
  _FullScreenState createState() => _FullScreenState(this.imgUrl,this.index,this.dataDirectory);
}

class _FullScreenState extends State<FullScreen> {
// Constructors
  String imgUrl;
  int index;
  String dataDirectory;
  _FullScreenState(String imgUrl, int index, String dataDirectory){
    this.imgUrl = imgUrl;
    this.index = index;
    this.dataDirectory = dataDirectory;
    print('img url : $imgUrl index is : $index dataDirectory is $dataDirectory');
  }

// Instance Variables
  static const platform = const MethodChannel('wallpaperChannel');
  bool _isFile = false;
  bool getImg = false;
  double progress = 1;

// Init and Dispose
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    checkFileExists();
   // _asyncInit();
  }

// Methods
  void checkFileExists() async{
    File file = File('$dataDirectory/img_$index.jpeg');
    bool isFile = await file.exists();
    setState(() {
      _isFile = isFile;
    });
    print('is file img_$index.jpeg : $isFile');
  }

  void bottomDialog(context){
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),
      builder: (BuildContext context){
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(title: Text('Home Screen'),onTap: (){
                Navigator.pop(context);
                setState(() {
                getImg = true;
              });getImage(1);
              },),
              ListTile(title: Text('Lock Screen'),onTap: (){
                Navigator.pop(context);
                setState(() {
                  getImg = true;
                });getImage(2);                },),
              ListTile(title: Text('Both Home & Lock'),onTap: (){
                Navigator.pop(context);
                setState(() {
                  getImg = true;
                });getImage(3);                },),
            ],
          ),
        );
      }
    );
  }
  void getImage(int wallpaperType) async{
    Dio dio = Dio();
    File file = File('$dataDirectory/img_$index.jpeg');
    if(_isFile != true) {
      await dio.download(
          '${imgUrl}crop=entropy&cs=srgb&dl=a_$index.jpg&fit=crop&fm=jpg&h=3222&w=2048',
          '$dataDirectory/img_$index.jpeg',
          onReceiveProgress: (rec, total) {
            print('Rec : $rec , Total : $total');
            setState(() {
              progress = ((rec / total) * 100);
            });
          }).catchError((e){
            print(' got error during downloading');
            file.delete(recursive: true);
            print('deleted img_$index.jpeg');
      }).whenComplete((){

      });
    }
    print('downloded img_$index');
    setState(() {
      getImg = false;
      _isFile = true;
      _setWallpaper(wallpaperType);
    });
  }
  Future<void> _setWallpaper(int wallpaperType) async{
    var file = File('$dataDirectory/img_$index.jpeg');
    try{
      final int result = await platform.invokeMethod('setWallpaper', [file.path,wallpaperType]);
      print ('wallpaper updated.... $result');
      Fluttertoast.showToast(msg: 'Setting Wallpaper Successful');
    }on PlatformException catch (e){
      print('failed to set wallpaper ${e.message}');
      Fluttertoast.showToast(msg: 'Something went wrong');
    }
  }

// Widgets / UI
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.pop(context);
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: _isFile != true ? MemoryImage(imgData[index]): FileImage(File('$dataDirectory/img_$index.jpeg')
            ), fit: BoxFit.cover,)),
          child: Stack(
            children: <Widget>[
              Visibility(
                visible: getImg,
                child: Align(
                  alignment: Alignment.center,
                  child:Stack(
                    children: <Widget>[
                      Center(
                        child: CircularPercentIndicator(
                          radius: 60,
                          lineWidth: 7,
                          percent: progress/100,
                          center: Text('${progress.toInt().toString()}%',style: TextStyle(fontWeight: FontWeight.bold),),
                          progressColor: Colors.green,
                        ),
                      ),
                      Center(child: Container(margin: EdgeInsets.only(top: 256),child: Text('Downloading HD Image',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)))
                    ],
                  ) ,
                ),
              ),
              Visibility(
                visible: !getImg,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: OutlineButton(
                      borderSide: BorderSide(color: Colors.transparent),
                      color: Colors.red,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                      ),
                      //label: Text('Set Wallpaper'),
                      child: Chip(backgroundColor:Colors.cyan,label: Text('Set Wallpaper'),),
                      onPressed: (){
                        bottomDialog(context);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      );
  }
}
