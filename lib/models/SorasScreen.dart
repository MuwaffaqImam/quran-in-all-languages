import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:quran/translation/TranslatedText.dart';

import 'Chapters.dart';
import 'Sora.dart';

class SoraScreen extends StatefulWidget {
  Chapter chapter;

  static getRoute(Chapter chapter) {
    return PageRouteBuilder(pageBuilder: (_, animation, child) {
      return FadeTransition(opacity: animation, child: new SoraScreen(chapter));
    });
  }

  SoraScreen(this.chapter, {Key? key}) : super(key: key);

  @override
  _SoraScreenState createState() => _SoraScreenState(chapter);
}

class _SoraScreenState extends State<SoraScreen> {
  Chapter chapter;

  _SoraScreenState(this.chapter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildVersesFutureBuilder());
  }

  FutureBuilder<List<Verses>> buildVersesFutureBuilder() {
    return FutureBuilder<List<Verses>>(
      future: getSoraVerses(widget.chapter),
      builder: (context, snapshot) {
        ///  error
        if (snapshot.hasError)
          return Center(
              child: Text(
            'Error ${snapshot.data}',
            style: TextStyle(fontSize: 40, color: Colors.red),
          ));
        else if (snapshot.connectionState == ConnectionState.done) {
          /// if success
          return buildSora(snapshot.data!);
        } else {
          /// if waiting
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<List<Verses>> getSoraVerses(Chapter chapter) async {
    List<Verses> versesList = [];
    var url = Uri.parse(chapter.link);
    print('start the calling $url');
    Response response = await http.get(url);
    if (response.statusCode == 200) {
      var versesJsonArray = response.body;
      Map decode = json.decode(versesJsonArray);
      List verseList = decode['verses'];
      verseList.forEach((versesDictionary) {
        Verses verses = Verses.fromJson(versesDictionary);
        versesList.add(verses);
      });
    } else {
      // error
      debugPrint("Connection error");
    }
    return versesList;
  }

  Widget buildSora(List<Verses> versesList) {
    return Scaffold(
      appBar: AppBar(title: Text("temporary title")),
      body: ListView.builder(
        itemCount: versesList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              ListTile(
                title: Text(
                  versesList[index].text,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: TranslatedText(
                  versesList[index].translation,
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}
