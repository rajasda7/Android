import 'package:flutter/material.dart';
import 'package:hd_wallpapers_for_iphone_11/screens/ImagesScreen.dart';

void main() {
  runApp(MaterialApp(
    title: 'HD Wallpapers iphone',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
    ),
    home: ImagesScreen(),
  ));
}
