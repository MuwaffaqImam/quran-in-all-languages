import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:quran/models/Chapters.dart';
import 'package:quran/models/Sora.dart';
import 'package:quran/newtork/Api.dart';
import 'package:quran/provider/VersisProvider.dart';
import 'package:quran/translation/TranslatedText.dart';
import 'package:quran/translation/TranslationManager.dart';

import 'models/SorasScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SoraProvider>(
            create: (context) => SoraProvider())
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // is not restarted.
          accentColor: Colors.amber,
          primarySwatch: Colors.teal,
        ),
        home: SafeArea(child: MyHomePage()),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Chapter> chapterList = [];
  List<Verses> versesList = [];
  String translate = TranslateLanguage.RUSSIAN;
  int index=44;

  @override
  Widget build(BuildContext context) {
    return Consumer<SoraProvider>(builder: (context, provider, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quran All Languages'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    translate = TranslateLanguage.RUSSIAN;
                  });
                },
                child: Center(child: Text('Russian')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    translate = TranslateLanguage.ARABIC;
                  });
                },
                child: Center(child: Text('Arabic')),
              ),
            ),
          ],
        ),
        body: buildTranslateBuilder(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            buildModelSheet();
          },
          tooltip: 'Increment',
          child: Icon(Icons.translate),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    });
  }

  FutureBuilder<Object> buildTranslateBuilder() {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: initTranslation(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return buildChapterFutureBuilder();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Translating.. to ${languages[index]} \n',
                      style: TextStyle(fontSize: 30,color: Colors.black),
                      children: const <TextSpan>[
                        TextSpan(text: 'this might take a while... \n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        TextSpan(text: 'because we are downloading an AI model to translate through it,'
                            ' once finished you will see an incredible thing, I PROMISE... \n ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        TextSpan(text: '  so say Astghefer Allah in this time time!',style: TextStyle(fontFamily: 'casual',fontSize: 30)),
                      ],
                    ),
                  ),
                ),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
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

  Widget buildListView(List<Chapter> chapterList) {
    return ListView.builder(
      itemCount: chapterList.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context, SoraScreen.getRoute(chapterList[index]));
              },
              child: ListTile(
                title: Center(
                  child: Text(
                    chapterList[index].name,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                subtitle: TranslatedText(
                  chapterList[index].translation,
                  style: TextStyle(fontSize: 24, color: Colors.teal),
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

  Future<bool> initTranslation() async {
    return await TranslationManager().init(translateToLanguage: translate);
  }

  buildModelSheet() {
    showModalBottomSheet<void>(
      enableDrag: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          color: Colors.amberAccent,
          child: Center(
            child: ListView.builder(
              itemCount: languages.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        setState(() {
                          this.index = index;
                          translate = la[index];
                        });
                        Navigator.pop(context);
                      },
                      title: Text(
                        '${languages[index]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<String> languages = [
    'AFRIKAANS',
    'ALBANIAN',
    'ARABIC',
    'BELARUSIAN',
    'BENGALI',
    'BULGARIAN',
    'CATALAN',
    'CHINESE',
    'CROATIAN',
    'CZECH',
    'DANISH',
    'DUTCH',
    'ENGLISH',
    'ESPERANTO',
    'ESTONIAN',
    'FINNISH',
    'FRENCH',
    'GALICIAN',
    'GEORGIAN',
    'GERMAN',
    'GREEK',
    'GUJARATI',
    'HAITIAN_CREOLE',
    'HEBREW',
    'HINDI',
    'HUNGARIAN',
    'ICELANDIC',
    'INDONESIAN',
    'IRISH',
    'ITALIAN',
    'JAPANESE',
    'KANNADA',
    'KOREAN',
    'LATVIAN',
    'LITHUANIAN',
    'MACEDONIAN',
    'MALAY',
    'MALTESE',
    'MARATHI',
    'NORWEGIAN',
    'PERSIAN',
    'POLISH',
    'PORTUGUESE',
    'ROMANIAN',
    'RUSSIAN',
    'SLOVAK',
    'SLOVENIAN',
    'SPANISH',
    'SWAHILI',
    'SWEDISH',
    'TAGALOG',
    'TAMIL',
    'TELUGU',
    'THAI',
    'TURKISH',
    'UKRAINIAN',
    'URDU',
    'VIETNAMESE',
    'WELSH'
  ];

  List<String> la = [
    "af",
    "sq",
    "ar",
    "be",
    "bn",
    "bg",
    "ca",
    "zh",
    "hr",
    "cs",
    "da",
    "nl",
    "en",
    "eo",
    "et",
    "fi",
    "fr",
    "gl",
    "ka",
    "de",
    "el",
    "gu",
    "ht",
    "he",
    "hi",
    "hu",
    "is",
    "id",
    "ga",
    "it",
    "ja",
    "kn",
    "ko",
    "lv",
    "lt",
    "mk",
    "ms",
    "mt",
    "mr",
    "no",
    "fa",
    "pl",
    "pt",
    "ro",
    "ru",
    "sk",
    "sl",
    "es",
    "sw",
    "sv",
    "tl",
    "ta",
    "te",
    "th",
    "tr",
    "uk",
    "ur",
    "vi",
    "cy",
  ];
}
