import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:launch_review/launch_review.dart';
import 'dart:io';
import 'package:nature_wallpapers/utils/DataHolder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nature_wallpapers/screens/FullScreen.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;

class ImagesScreen extends StatefulWidget {
 // final bool darkThemeEnabled;
  ImagesScreen();
  @override
  _ImagesScreenState createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  //Constructors
  // bool darkThemeEnabled;
  _ImagesScreenState();

// Instance variables
  StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot> wallpaperList;
  final CollectionReference collectionReference =
  Firestore.instance.collection('NatureWallpapers');
  bool _showAppbar = true;
  ScrollController _scrollAppbarController = new ScrollController();
  bool isScrollingDown = false;
  bool permissionGranted = false;
  String dataDirectory;
  bool isSwitched = false;

// Init & Dispose States
  @override
  void initState() {
    super.initState();
    print('dark theme : ');
    getSubscription();
    getPermission();
    myScroll();
    getDataDirectory();
  }
  @override
  void dispose() {
    subscription?.cancel();
    _scrollAppbarController.removeListener((){});
    print('subscription disposed');
    super.dispose();
  }

// Methods / Functions
  void getSubscription() async{
    print('subscription called');
    subscription =  collectionReference.snapshots().listen((dataSnapshots) {
      setState(() {
        print('wallpaperList updated');
        wallpaperList = dataSnapshots.documents;
        getImages();
      });
    });
  }
  void getImages() async{
    print('get image called');
    for(int i = 0; i < wallpaperList.length; i++){
      http.Response response = await http.get('${wallpaperList[i].data['url']}crop=entropy&cs=srgb&dl=a_$i.jpg&fit=crop&fm=jpg&h=402&w=256');
      imgData[i] = response.bodyBytes;
      setState(() {
        print('set state called for $i image getted ..');
        print('size of image $i is : ${imgData[i].length/1000} kb');
      });
    }
  }
  void getPermission() async {
    PermissionStatus permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    print(PermissionStatus);
    if (permissionStatus != PermissionStatus.granted) {
      Map<PermissionGroup,
          PermissionStatus> permissions = await PermissionHandler()
          .requestPermissions([PermissionGroup.storage]).whenComplete((){
        setState(() {
          permissionGranted = true;
        });
      });
    } else{
      setState(() {
        permissionGranted = true;
      });
    }
  }
  void myScroll() async{
    _scrollAppbarController.addListener((){
      if(_scrollAppbarController.position.userScrollDirection == ScrollDirection.reverse){
        if(!isScrollingDown){
          isScrollingDown = true;
          _showAppbar = false;
          setState(() {
          });
        }
      }
      if(_scrollAppbarController.position.userScrollDirection == ScrollDirection.forward){
        if(isScrollingDown){
          isScrollingDown = false;
          _showAppbar = true;
          //showAppBar();
          setState(() {

          });
        }
      }
    });
  }
  void getDataDirectory() async{
    Directory dir = await getExternalStorageDirectory();
    dataDirectory = dir.path;
  }

// Widget UI part
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      drawer: Drawer(
        elevation:16,
        child:Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: <Widget>[
                      wallpaperList != null ? Image.network('${wallpaperList[1].data['url']}auto=compress&cs=tinysrgb&dpr=1&w=500'): Container(),
                    ],
                  ),

                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    onTap: (){Navigator.pop(context);},
                  ),
                  ListTile(
                    leading: Icon(Icons.terrain),
                    title: Text('Dark Theme'),
                    trailing: Switch(
                      value: isSwitched,
                      onChanged:(value){
                        DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark);
                        isSwitched = Theme.of(context).brightness == Brightness.dark ? false : true;
                      },


                    ),
                    onTap: (){Navigator.pop(context);},
                  ),
                  ListTile(
                    leading: Icon(Icons.favorite),
                    title: Text('Rate this App'),
                    onTap:(){
                      LaunchReview.launch();
                    },
                  )

                ],
              ),
            )
          ],
        ),
      ),
      appBar: _showAppbar ? AppBar(
        title: Text('Nature Wallpapers'),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                    title: Text('Rate this App'),
                    onTap: () {LaunchReview.launch();},
                  ),
                ),

              ];
            },
          )
        ],
      ) : PreferredSize(child: Container(),preferredSize: Size(0.0,0.0),),
      body: wallpaperList != null
          ? StaggeredGridView.countBuilder(
              controller: _scrollAppbarController,
              padding: EdgeInsets.all(3),
              itemCount: wallpaperList.length,
              crossAxisCount: 4,
              itemBuilder: (context,index){
                String imgUrl = wallpaperList[index].data['url'];
                if(index == 1) {
                  print('length of list is ${wallpaperList.length}');
                }
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  columnCount: 2,
                  duration: Duration(milliseconds: 150),
                  child: ScaleAnimation(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Material(
                        elevation: 12.0,
                       // borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: (){
                            if(permissionGranted == false){getPermission();}
                            if(imgData.containsKey(index)){
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                            return FullScreen(imgUrl,index,dataDirectory);
                          }));}},
                          child: Hero(
                            tag: imgUrl,
                            child: imgData.containsKey(index) ?
                            Image.memory(imgData[index],fit: BoxFit.cover,):
                            Center(child: CircularProgressIndicator(),),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              staggeredTileBuilder: (i) =>
                  StaggeredTile.count(2, i.isEven ? 2 :3),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
      )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

}
