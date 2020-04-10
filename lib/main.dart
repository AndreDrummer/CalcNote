import 'package:flutter/material.dart';
import 'package:calcnote/UI/home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => (runApp(CalcNoteHome()));

class CalcNoteHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('he'), // Hebrew
        const Locale.fromSubtags(languageCode: 'zh'),
      ],
      debugShowCheckedModeBanner: false,
      title: 'CalcNote',
      home: DrummerNote(),
      theme: ThemeData(
          textTheme: ThemeData.light().textTheme.copyWith(
              title: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 28,
              ),
              display1: TextStyle(
                fontFamily: 'OpenSans',
                color: Colors.black,
                fontSize: 20,
              ),
              display2: TextStyle(
                fontFamily: 'OpenSans',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
              subtitle: TextStyle(
                fontSize: 13,
                color: Colors.grey
              ),
              headline: TextStyle(
                  fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Quicksand',
              ),
              caption: TextStyle(
                fontSize: 16,
                fontFamily: 'Quicksand',
                  color: Colors.purple,
              ),
              button: TextStyle(
                fontSize: 16,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              )),
          primarySwatch: Colors.purple,
          accentColor: Colors.green),
    );
  }
}
