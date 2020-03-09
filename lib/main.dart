import 'package:flutter/material.dart';
import 'package:calcnote/UI/home.dart';

final ThemeData iOSTheme = new ThemeData(
    primarySwatch: Colors.black,
    primaryColor: Colors.black,
    primaryColorBrightness: Brightness.dark);

final ThemeData androidTheme =
    new ThemeData(primarySwatch: Colors.black, accentColor: Colors.black);

void main() => (runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CalcNote',
      home: DrummerNote(),
    )));
