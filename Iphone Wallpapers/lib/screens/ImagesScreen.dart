import 'dart:io';
import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:path_provider/path_provider.dart';
import 'DataHolder.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hd_wallpapers_for_iphone_11/screens/FullScreen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:backdrop/backdrop.dart';

class ImagesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ImagesScreenState();
  }
}

class ImagesScreenState extends State<ImagesScreen> {
  StorageReference photosReference =
      FirebaseStorage.instance.ref().child("Iphone wallpapers/Iphone 11/tmp");

  @override
  void initState() {
    super.initState();
    getPermission();
    clearCache();
    getImage();
  }

  getPermission() async {
    var permission = Permission.WriteExternalStorage;
    PermissionStatus permissionStatus1 =
        await SimplePermissions.requestPermission(permission);
  }

  clearCache() async {
    var tempDir = (await getTemporaryDirectory()).path;
    var tempFile = Directory(tempDir);
    var length = await tempFile.list().length;
    // debugPrint('length is $length');
    if (length > 2) {
      tempFile.deleteSync(recursive: true);
      // debugPrint('cleared chache length is more than 2');
    }
  }

  getImage() {
    for (int i = 0; i < 24; i++) {
      String imageType = 'png';
      List<int> jpgImages = [12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23];
      if (jpgImages.contains(i)) {
        imageType = 'jpg';
      }
      photosReference
          .child('image_$i.$imageType')
          .getData(1 * 1024 * 1024)
          .then((data) async {
        setState(() {
          imageData[i] = data;
        });
        //  debugPrint('i is $i');
        //debugPrint('image size is ${imageData[i].length}');
      }).catchError((error) {} //error
              );
    }
  }

  Widget decideGridTileWidget(int index) {
    if (!imageData.containsKey(index)) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Image.memory(
        imageData[index],
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropScaffold(
      title: Text('Wallpapers iphone'),
      backLayer: Center(
        child: Text('Back layer'),
      ),
      frontLayer: Center(
        child: Container(
          child: Center(
            child: GridView.builder(
              padding: EdgeInsets.all(4),
              itemCount: 24,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                childAspectRatio: 0.5,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                //              debugPrint("Index is $index");
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: Duration(milliseconds: 400),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: Card(
                      color: Colors.transparent,
                      elevation: 3,
                      child: Hero(
                        tag: 'image_$index.png',
                        child: Material(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(15),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return FullScreen(index);
                                },
                              ));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: decideGridTileWidget(index),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      iconPosition: BackdropIconPosition.none,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.view_list),
          color: Colors.white,
          onPressed: () {},
        )
      ],
    );
  }
}
