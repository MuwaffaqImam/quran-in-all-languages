import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:quran/models/Chapters.dart';
import 'package:quran/models/Sora.dart';
import 'package:quran/newtork/Api.dart';

class SoraProvider extends ChangeNotifier {
  List soras = [];


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

      });
    } else {
      // error ...
    }
    return [];
  }

  SoraProvider() {
    print('im a constructor');
  }

  void addSora(String sora) {
    print(sora);
    soras.add(sora);
    notifyListeners();
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
}
