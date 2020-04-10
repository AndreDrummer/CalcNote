class CalcNote {
  final String tema;
  final int id;
  final String cardColor;

  CalcNote({this.id, this.tema, this.cardColor});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tema': tema,
      'cardColor': cardColor,
    };
  }
}

class Anotation {
  final int id;
  final String title;
  final int type;
  final double value;
  final String date;
  final String tema;

  Anotation(
      {this.id,
        this.title,
      this.type,
      this.value,
      this.date,
      this.tema});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'value': value,
      'date': date,
      'tema': tema,
    };
  }
}
