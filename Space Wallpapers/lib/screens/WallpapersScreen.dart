import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'FullImageScreen.dart';
import 'package:launch_review/launch_review.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class WallpapersScreen extends StatefulWidget {
  @override
  _WallpapersScreenState createState() => _WallpapersScreenState();
}

class _WallpapersScreenState extends State<WallpapersScreen> {
  StreamSubscription<QuerySnapshot> subscription;
  List <DocumentSnapshot> wallpapersList;
  final CollectionReference collectionReference = Firestore.instance.collection("Space Wallpapers");

  @override
  void initState() {
    super.initState();
    debugPrint('init called');                  // debug print used

    subscription = collectionReference.snapshots().listen((dataSnapshot) {
      setState(() {
        debugPrint('subscription set state called');
        wallpapersList = dataSnapshot.documents;
      });
    });
    debugPrint('init called after subscription line');      // debug print used

  }

  @override
  void dispose() {
    subscription?.cancel();
    debugPrint('subscription close caled');   // debug print called
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Space Wallpapers'),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context){
              return[
                PopupMenuItem(child: ListTile(title: Text('Rate Us'), onTap: (){LaunchReview.launch();},),),
              ];
            },
          )
        ],
      ),
      drawer: Drawer(
        elevation: 16,
        child: Column (
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Stack(alignment:Alignment.bottomLeft, children: <Widget>[
                    Image.asset('assets/drawer.jpeg'),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Space Wallpapers', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                  ],),

                  Material(
                    color: Colors.white30,
                    child: ListTile(
                      title: Text('All'),
                      trailing: Icon(Icons.arrow_forward),
                      enabled: true,
                      onTap: (){
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('version 1.0.0', style: TextStyle(color: Colors.teal),),
              ),
            )

          ],
        ),
      ),
      body: wallpapersList != null ?
      StaggeredGridView.countBuilder(
          padding: EdgeInsets.all(3),
          crossAxisCount: 4,
          itemCount: wallpapersList.length,
          itemBuilder: (context,index){
            String imgPath = wallpapersList[index].data['url'];
            //debugPrint(imgPath);        // debug print called
            //debugPrint(i.toString());     // debug print called
            return Material(
              elevation: 8.0,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              child: InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context){
                      return FullImageScreen(imgPath,index);
                    },
                  ));
                },
                child: Hero(
                  tag: imgPath,
                  child: FadeInImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(imgPath),
                    placeholder: AssetImage(''),
                  ),
                ),
              ),
            );
          },
          staggeredTileBuilder: (i) => StaggeredTile.count(2, i.isEven ? 2 : 3),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4.0,
      ):
          Center(
            child: CircularProgressIndicator(),
          )
      ,
    );
  }
}
