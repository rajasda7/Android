import 'package:flutter/material.dart';
import 'package:Softnotes/models/Note.dart';
import 'package:intl/intl.dart';
import 'package:Softnotes/utils/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NoteDetail extends StatefulWidget {
  Note note;
  bool autoFocus;

  NoteDetail(this.note, this.autoFocus);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.autoFocus);
  }
}

class NoteDetailState extends State<NoteDetail> with WidgetsBindingObserver {
  Note note;
  bool autoFocus;

  NoteDetailState(this.note, this.autoFocus);

  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    myController.addListener(printVal);
    myController.text = note.description;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    myController.dispose();
    super.dispose();
  }

  printVal() {
    updateDescription();
  }

  TextEditingController titleController = TextEditingController();
  DatabaseHelper helper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    titleController.text = note.title;
    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
        _save();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
              _save();
            },
          ),
          title: TextField(
            controller: titleController,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
            decoration: InputDecoration.collapsed(hintText: 'Title'),
            onChanged: (value) {
              updateTitle();
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
               var alertDialog =  AlertDialog(title: Text('Delete'),content: Text('Do you really wants to delete note?'),actions: <Widget>[FlatButton(child: Text('Yes'),onPressed: (){
                Navigator.pop(context);
                 moveToLastScreen();
                helper.deleteNote(note.id);
                Fluttertoast.showToast(msg: 'Deleted');
               },),
               FlatButton(child: Text('No'),onPressed: (){
                Navigator.pop(context);
               },)],);
                showDialog(context: context, builder: (BuildContext context) => alertDialog);
//
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 5, left: 5, right: 2),
          child: Container(
            child: TextField(
              controller: myController,
              autofocus: autoFocus,
              style: TextStyle(fontSize: 23,),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration.collapsed(hintText: 'Enter note..'),
              maxLines: null,
              /*onChanged: (value){
                setState(() {
                  updateDescription();

                });
              },*/
            ),
          ),
        ),
      ),
    );
  }

  // update tittle of note object
  void updateTitle() {
    note.title = titleController.text;
  }

  void updateDescription() {
    note.description = myController.text;
  }

// save data to database
  void _save() async {
    note.date = DateFormat.yMMMd().format(DateTime.now());
    if (note.id != null) {
      await helper.updateNote(note);
      Fluttertoast.showToast(msg: 'saved');
    } else {
      if (note.title == '') {
        if (note.description == '') {
          note.title = 'Untitled';
        } else {
          var title = note.description.split(' ');
          if (title.length >= 1 && title.length < 2) {
            note.title = title[0];
          }

          if (title.length >= 2) {
            note.title = title[0] + ' ' + title[1];
          }
        }
      }
      await helper.insertNote(note);
      Fluttertoast.showToast(msg: 'saved');
    }
  }

  moveToLastScreen() {
    Navigator.pop(context, true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _save();
      Fluttertoast.showToast(msg: 'saved');
    }
  }
}
