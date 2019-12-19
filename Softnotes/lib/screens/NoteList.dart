import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:Softnotes/screens/NoteDetail.dart';
import 'package:backdrop/backdrop.dart';
import 'package:Softnotes/models/Note.dart';
import 'package:Softnotes/utils/database_helper.dart';
import 'package:local_notifications/local_notifications.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:async';

class NoteList extends StatefulWidget {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  ScrollController controller;
  double fabOpacity = 1; String payload = "null";
  List<Note> noteList; int position;
  int call = 0;
  int count = 0; List notificationActivePos = [];

//  FlutterLcalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    controller.addListener(scrollListener);
  }

  scrollListener() {
    if (call == 0 && controller.offset > 0) {
      setState(() {
        fabOpacity = 0;
        call = 1;
      });
    } else {
      if (controller.offset == 0) {
        setState(() {
          fabOpacity = 1;
          call = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }
    return BackdropScaffold(
      iconPosition: BackdropIconPosition.none,
      title: Text('Softnotes'),
      backLayer: Center(child: Text('back')),
      frontLayer: Center(
        child: Padding(padding: EdgeInsets.all(8), child: getListView()),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.list),
          onPressed: () {},
        )
      ],
    );
  }

  getListView() {
    TextStyle textStyle1 = Theme.of(context).textTheme.subhead;
    return Container(
      child: Stack(
        children: <Widget>[
          noteList.length == 0 ? Center(child:Text('Create some notes by tapping on + Add Icon')) : ListView.builder(
              itemCount: count,
              controller: controller,
              itemBuilder: (BuildContext context, int position) {
                return AnimationConfiguration.staggeredList(
                  delay: Duration(milliseconds: 50),
                  position: position,
                  duration: Duration(milliseconds: 400),
                  child: ScaleAnimation(
                    //    verticalOffset: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Card(
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.yellow,
                            child: Icon(Icons.arrow_right),
                          ),
                          title: Text(
                            this.noteList[position].title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            this.noteList[position].date,
                            style: textStyle1,
                          ),
                          trailing: GestureDetector(
                            child: getTrailingIcon(position),
                            onTap: () {

                              LocalNotifications.createNotification(
                                  title: this.noteList[position].title,
                                  onNotificationClick: NotificationAction(
                                    actionText: 'launchDetail',
                                    callback: launchDetail,
                                    payload: "$position",
                                    callbackName: 'launch',
                                  ),
content: this.noteList[position].description,
                                  id: position,
                                  androidSettings: AndroidSettings(
                                      priority:
                                          AndroidNotificationPriority.HIGH,
                                      isOngoing: false));
                              Fluttertoast.showToast(msg: 'Notified');
                              if(!notificationActivePos.contains(position)){
                                setState(() {
                                  notificationActivePos.add(position);
                                });
                              } else{
                                setState(() {
                                  LocalNotifications.removeNotification(position);
                                  notificationActivePos.remove(position);
                                });
                              }
                            },
                          ),
                          onTap: () {
                            navigateToNoteDetail(
                                this.noteList[position], false);
                          },
                        ),
                      ),
                    ),
                  ),
                );
              }),
          Opacity(
            opacity: fabOpacity,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  elevation: 7,
                  child: Icon(Icons.add),
                  onPressed: () {
                    navigateToNoteDetail(Note('', '', ''), true);
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  getTrailingIcon(int position){
    if(notificationActivePos.contains(position)){
      return Icon(Icons.notifications_active);
    } else{
      return Icon(Icons.notifications);
    }
  }
  void launchDetail(String payload) async{
      var id = int.parse(payload);
      // await LocalNotifications.removeNotification(4);
   //Fluttertoast.showToast(msg: 'Payload is $payload');
   navigateToNoteDetail(this.noteList[id], false);

  }

  void removeNotification(String payload) async{
    debugPrint('payload is $payload');
    var id = int.parse(payload);
    await LocalNotifications.removeNotification(id);
    Fluttertoast.showToast(msg: 'Payload is $payload');
    navigateToNoteDetail(Note('','',''), true);

  }
  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  void navigateToNoteDetail(Note note, bool autoFocus) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, autoFocus);
    }));

    if (result == true) {
      updateListView();
    }
  }
}
