import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:quran/models/Chapters.dart';
import 'package:quran/models/Sora.dart';
import 'package:quran/newtork/Api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Chapter> chapterList = [];
  List<Verses> versesList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: buildChapterFutureBuilder(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getQuranChapters();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Finished calling')));
        },
        tooltip: 'Increment',
        child: Icon(Icons.arrow_back),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  FutureBuilder<List<Chapter>> buildChapterFutureBuilder() {
    return FutureBuilder<List<Chapter>>(
      future: getQuranChapters(),
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
          chapterList = snapshot.data!;
          return buildListView(chapterList);
        } else {
          /// if waiting
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  FutureBuilder<List<Verses>> buildVersesFutureBuilder(chapterNumber) {
    return FutureBuilder<List<Verses>>(
      future: getSoraVerses(chapterList[chapterNumber]),
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
          versesList = snapshot.data!;
          return buildSora(versesList);
        } else {
          /// if waiting
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget buildListView(List<Chapter> chapterList) {
    return ListView.builder(
      itemCount: chapterList.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => buildVersesFutureBuilder(index),
                  ),
                );
              },
              child: ListTile(
                title: Text(
                  chapterList[index].name,
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: Text(
                  chapterList[index].translation,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Divider(),
          ],
        );
      },
    );
  }

  Future<List<Chapter>> getQuranChapters() async {
    var url = Uri.parse(Api.chapters);
    print('start the calling $url');
    Response response = await http.get(url);
    if (response.statusCode == 200) {
      // success
      var chaptersJsonArray = response.body;
      List decode = json.decode(chaptersJsonArray) as List;
      decode.forEach((chapterDictionary) {
        Chapter chapter = Chapter.fromJson(chapterDictionary);
        chapterList.add(chapter);
      });
    } else {
      // error ...
    }
    return chapterList;
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
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 20,),
                ),
                subtitle: Text(
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

  Future<List<Verses>> getSoraVerses(Chapter chapter) async {
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
}
