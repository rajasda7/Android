import 'package:flutter/material.dart';
import 'screens/ImagesScreen.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

void main(){
  runApp(DynamicTheme(
    defaultBrightness: Brightness.light,
    data: (brightness) => ThemeData(
      primarySwatch: Colors.red,
      brightness: brightness,
    ),
    themedWidgetBuilder: (context, theme){
      return MaterialApp(
        title: 'Nature Wallpapers',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: ImagesScreen(),
      );
    },
  ));
}