import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:http/http.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:path_provider/path_provider.dart';

class FullImageScreen extends StatefulWidget {
  String imgPath;
  int index;

  FullImageScreen(this.imgPath, this.index);

  @override
  _FullImageScreenState createState() =>
      _FullImageScreenState(this.imgPath, this.index);
}

class _FullImageScreenState extends State<FullImageScreen> {
  String imgPath;
  int index;
  bool imgDownloaded = false;
  String dataDirectory;
  String pixels = '0';
  _FullImageScreenState(this.imgPath, this.index);
  static const platform = const MethodChannel('wallpaperChannel');

  @override
  void initState() {
    super.initState();
    getImage();

  }

  getImage() async {
    // Getting external directory
    var dir = await getExternalStorageDirectory();
    var path = dir.path;
    dataDirectory = path;
    //Checking image exists or not
    var file = File('$path/img_$index.jpeg');
    bool isFile = await file.exists();
    // Downloading image
    if(isFile == false){
      debugPrint('img is downloading'); // debug print used

      var response = await get(imgPath+pixels);
     // print('content length is : ${response.contentLength}');
      File file = new File(
        join(path,'img_$index.jpeg')
      );
      file.writeAsBytesSync(response.bodyBytes);

      setState(() {
          imgDownloaded = true;

        });

    } else{
      debugPrint('img is downloaded'); // debug print used
      setState(() {
        imgDownloaded = true;
      });
    }

  }

  saveToGallery()async{
    if(imgDownloaded == true) {
      Directory downloadsDirectory;
      downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
      var downloadsDirectoryPath = downloadsDirectory.path;
      debugPrint(downloadsDirectory.path);
      var file = File('$dataDirectory/img_$index.jpeg');
      file.copy('$downloadsDirectoryPath/img_$index.jpeg').whenComplete(() {
        Fluttertoast.showToast(msg: 'Saved to Gallery');
      });
    }else{
      Fluttertoast.showToast(msg: 'Please Wait..');
    }
  }

  Future<void> _setWallpaper(int wallpaperType) async {
    if(imgDownloaded==true) {
      var dir = await getExternalStorageDirectory();
      var path = dir.path;
      var file = File('$path/img_$index.jpeg');
      try {
        final int result = await platform
            .invokeMethod('setWallpaper', [file.path, wallpaperType]);
        print('Wallpaer Updated.... $result');
        Fluttertoast.showToast(
            msg: 'Set Wallpaper Successfully', toastLength: Toast.LENGTH_LONG);
      } on PlatformException catch (e) {
        print("Failed to Set Wallpaer: '${e.message}'.");
      }
    }else{
      Fluttertoast.showToast(msg: 'Please Wait..');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          color: Colors.grey,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Hero(
                  tag: imgPath,
                  child:imgDownloaded == true ?  Image.file(
                    File('$dataDirectory/img_$index.jpeg'),
                  ): Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      //Image.asset('assets/track.png'),
                      Align(alignment: Alignment.center,child: CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
              Positioned(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: FlatButton(
                            splashColor: Colors.white70,
                            padding: EdgeInsets.all(16.0),
                            onPressed: () {saveToGallery();},
                            child: Text(
                              'Save to Gallery',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.black.withOpacity(0.8),
                          ),
                          fit: FlexFit.tight,
                        ),
                        Flexible(
                          child: FlatButton(
                            splashColor: Colors.white70,
                            padding: EdgeInsets.all(16.0),
                            onPressed: () async {
                              await _setWallpaper(1);
                              },
                            onLongPress: (){_setWallpaper(3);},
                            child: Text(
                              'Set Wallpaper',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            color: Colors.black.withOpacity(0.8),
                          ),
                          fit: FlexFit.tight,
                        )
                      ],
                    )
                  ],
                ),
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
