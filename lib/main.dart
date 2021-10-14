import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:quran/models/Chapters.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Chapter>>(
        future: getQuranChapters(),
        builder: (context, snapshot) {
          ///  error
          if (snapshot.hasError)
            return Center(
              child: Text(
                'Error ${snapshot.data}', style: TextStyle(fontSize: 40, color: Colors.red),)
            );
          else if(snapshot.connectionState == ConnectionState.done){
            /// if success
            chapterList = snapshot.data!;
            return buildListView(chapterList);
          }else{
            /// if waiting
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
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

  Widget buildListView(List<Chapter> chapterList) {
    return ListView.builder(
      itemCount: chapterList.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            ListTile(
              title: Text(
                chapterList[index].name,
                style: TextStyle(fontSize: 20),
              ),
              subtitle: Text(
                chapterList[index].translation,
                style: TextStyle(fontSize: 20),
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
}
