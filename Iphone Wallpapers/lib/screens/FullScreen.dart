import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter/services.dart';

class FullScreen extends StatefulWidget {
  int index;
  FullScreen(this.index);
  @override
  State<StatefulWidget> createState() {
    return FullScreenState(this.index);
  }
}

class FullScreenState extends State<FullScreen> {
  MethodChannel _channel = MethodChannel('wallpaper');
  StorageReference storageReference =
      FirebaseStorage.instance.ref().child("Iphone wallpapers/Iphone 11");
  bool isFile = false;
  double progress = 1;
  String imageExt = 'png';
  String externalImgPath;
  int index;
  FullScreenState(this.index);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    getPermission();
    getImageExt();
    getTempImgPath();
    getImg();
    // debugPrint(isFile.toString()); // debug print
    // getImage();
  }

  getPermission() async {
    var permission = Permission.WriteExternalStorage;
    PermissionStatus permissionStatus =
        await SimplePermissions.requestPermission(permission);
  }

  getImageExt() {
    List<int> jpgImages = [12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23];
    if (jpgImages.contains(index)) {
      imageExt = 'jpg';
    }
  }

  getTempImgPath() async {
    var dir = await getTemporaryDirectory();
    setState(() {
      externalImgPath = '${dir.path}/data_$index.$imageExt';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          child: Hero(
            tag: 'image_$index.png',
            child: imageLoader(index),
          ),
        ),
        floatingActionButton: MaterialButton(
          child: Text(
            'Set',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textScaleFactor: 1.3,
          ),
          padding: EdgeInsets.all(4),
          // textColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onPressed: () {
            if (isFile == true) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text('Set as...'),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ListTile(
                          title: Text('Home Screen'),
                          onTap: () {
                            setAsWallpaper('HomeScreen');
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ListTile(
                          title: Text('Lock Screen'),
                          onTap: () {
                            setAsWallpaper('LockScreen');
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ListTile(
                          title: Text('Both Home and Lock'),
                          onTap: () {
                            setAsWallpaper('Both');
                            Navigator.pop(context);
                          },
                        ),
                      )
                    ],
                  );
                },
              );
            } else {
              Fluttertoast.showToast(msg: 'Please wait getting image!');
            }
          },
          color: Colors.blueGrey,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  createImgToExternalStorage() async {
    var dir = await getExternalStorageDirectory();
    var dir1 = await getTemporaryDirectory();
    var path = dir.path;
    var file = File('${dir1.path}/data_$index.$imageExt');
    var externalImgPath1 = '$path/data.png';
    file.copy(externalImgPath1);
    // Fluttertoast.showToast(msg: 'File copied');
    //  debugPrint('file copied!');
  }

  Widget imageLoader(int index) {
    if (!isFile) {
      return Center(
          child: CircularPercentIndicator(
        radius: 120,
        lineWidth: 13,
        percent: progress / 100,
        center: Text(
          '${progress.toInt().toString()}%',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        footer: Text('Getting Image'),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: Colors.purple,
      ));
    } else {
      createImgToExternalStorage();
      //debugPrint(externalImgPath);
      return Image.file(
        File(externalImgPath),
        fit: BoxFit.cover,
      );
    }
  }

  void setAsWallpaper(String screen) async {
    await _channel.invokeMethod(screen, 'data.png').catchError((error) {
      Fluttertoast.showToast(msg: 'Something went wrong');
    });
    Fluttertoast.showToast(msg: 'Set Wallpaper Successfully');
    // debugPrint('Setted as wallpper');
  }

  getImg() async {
    var dir = await getTemporaryDirectory();
    var path = dir.path;
    var file = File('$path/data_$index.$imageExt');
    bool isf = await file.exists();
    setState(() {
      isFile = isf;
    });
    //debugPrint('file exist in get img $isFile');
    if (isFile == false) {
      //debugPrint(this.index.toString()); // debug print
      String imageUrl = await storageReference
          .child('image_$index.$imageExt')
          .getDownloadURL()
          .then((data) async {
        return data;
      });
      Dio dio = Dio();
      var dir = await getTemporaryDirectory();
      var path = dir.path;

      await dio.download(imageUrl, '$path/data_$index.$imageExt',
          onReceiveProgress: (rec, total) {
      //  print('Rec : $rec, Total: $total');
        setState(() {
          progress = ((rec / total) * 100);
          //  debugPrint(progress.toString());
        });
      }).whenComplete(() {
        setState(() {
          isFile = true;
        });
      }).catchError((error) {
        //    Fluttertoast.showToast(msg: 'error');
        File('$path/data_$index.$imageExt').delete(recursive: true);
        // debugPrint('File deleted on error');
      });
    }
  }
}
