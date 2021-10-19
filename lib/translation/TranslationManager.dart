import 'package:google_ml_kit/google_ml_kit.dart';

class TranslationManager {
  late String _originLanguage = TranslateLanguage.ENGLISH;
  late String _translateTo = TranslateLanguage.FRENCH;
  static late Map<String, String> cachedText;
  final _languageModelManager = GoogleMlKit.nlp.translateLanguageModelManager();
  late OnDeviceTranslator _onDeviceTranslator;
  static final TranslationManager _singleton = TranslationManager.initObject();

  factory TranslationManager() {
    return _singleton;
  }

  TranslationManager.initObject();

  Future<bool> init({
    String originLanguage = TranslateLanguage.ENGLISH,
    String translateToLanguage = TranslateLanguage.ARABIC,
  }) async {
    _originLanguage = originLanguage;
    _translateTo = translateToLanguage;
    _onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
        sourceLanguage: _originLanguage, targetLanguage: _translateTo);
    cachedText = Map();
    return await checkModels();
  }

  Future<String> translateText(
      {required String text,}) async {
    _onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
      sourceLanguage:  _originLanguage,
      targetLanguage:  _translateTo,
    );
    String translate = await _onDeviceTranslator.translateText(text);
    return translate;
  }

  Future<bool> checkModels() async {
    bool downloadStatus = false;
    print('Checking models ..');
    await _downloadModel(_originLanguage).then((value) {
      print('$_originLanguage model is downloaded');
      downloadStatus = true;
    }).onError((error, stackTrace) {
      print('$error and $stackTrace');
      downloadStatus = false;
    });
    await _downloadModel(_translateTo).then((value) {
      print('$_translateTo model is downloaded');
      downloadStatus = true;
    }).onError((error, stackTrace) {
      print('$error and $stackTrace');
      downloadStatus = false;
    });
    return Future.value(downloadStatus);
  }

  Future<bool> _downloadModel(String language) async {
    print('^^^^^ downloading $language model');
    bool downloaded = await _languageModelManager.isModelDownloaded(language);
    if (!downloaded)
      await _languageModelManager
          .downloadModel(language)
          .then((value) => downloaded = true)
          .onError((error, stackTrace) => downloaded = false);
    return Future.value(downloaded);
  }
}
