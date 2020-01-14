import "package:flutter/material.dart";
import 'screens/WallpapersScreen.dart';

void main(){
  runApp(MaterialApp(
    title: 'Space wallpapers',
//    theme: ThemeData(
//      fontFamily: 'NunitoSans',
//      brightness: Brightness.dark,
//      primaryColor: Color(0xff070b16),
//      primaryColorDark: Color(0xff070a11),
//      primaryColorLight: Color(0xff141622),
//      accentColor: Color(0xffffC126),
//      backgroundColor: Color(0xff0b101d)
//    ),
    home: WallpapersScreen(),
    debugShowCheckedModeBanner: false,
  ));
}