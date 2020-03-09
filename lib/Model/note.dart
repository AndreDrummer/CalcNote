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
  final String title;
  final String type;
  final double value;
  final String day;
  final String month;
  final String year;
  final String tema;

  Anotation(
      {this.title,
      this.type,
      this.value,
      this.day,
      this.month,
      this.year,
      this.tema});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'value': value,
      'day': day,
      'month': month,
      'year': year,
      'tema': tema,
    };
  }
}
