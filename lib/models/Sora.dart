class Sora {
 late final int id;
 late final String name;
 late final String transliteration;
 late final String translation;
 late final String type;
 late final int totalVerses;
 late final List<Verses> verses;

  Sora(
      this.id,
        this.name,
        this.transliteration,
        this.translation,
        this.type,
        this.totalVerses,
        this.verses);

  Sora.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    transliteration = json['transliteration'];
    translation = json['translation'];
    type = json['type'];
    totalVerses = json['total_verses'];
    if (json['verses'] != null) {
      verses = [];
      json['verses'].forEach((v) {
        verses.add(new Verses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['transliteration'] = this.transliteration;
    data['translation'] = this.translation;
    data['type'] = this.type;
    data['total_verses'] = this.totalVerses;
    data['verses'] = this.verses.map((v) => v.toJson()).toList();
    return data;
  }
}

class Verses {
 late final int id;
 late final String text;
 late final String translation;
 late final String transliteration;

  Verses(this.id, this.text, this.translation, this.transliteration);

  Verses.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    text = json['text'];
    translation = json['translation'];
    transliteration = json['transliteration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['text'] = this.text;
    data['translation'] = this.translation;
    data['transliteration'] = this.transliteration;
    return data;
  }
}
