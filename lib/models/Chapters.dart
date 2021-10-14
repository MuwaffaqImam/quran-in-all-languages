class Chapter {
  late final int id;
  late final String name;
  late final String transliteration;
  late final String translation;
  late final String type;
  late final int total_verses;
  late final String link;

  Chapter(this.id, this.name, this.transliteration, this.translation, this.type,
      this.total_verses, this.link);

  Chapter.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    transliteration = json['transliteration'];
    translation = json['translation'];
    type = json['type'];
    total_verses = json['total_verses'];
    link = json['link'];
  }

  @override
  String toString() {
    return 'Chapter{id: $id, name: $name, transliteration: $transliteration, translation: $translation, type: $type, total_verses: $total_verses, link: $link}';
  }
}
