import 'package:flutter/material.dart';
import 'package:Softnotes/screens/NoteList.dart';

void main(){
  runApp(

    MaterialApp(

      title: "Softnotes",
      home:NoteList(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    )


  );


}