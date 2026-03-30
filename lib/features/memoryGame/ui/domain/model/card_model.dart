class CardModel {
  final int id;
  final String emoji;
  final String label;
  bool isFaceUp;
  bool isMatched;

  CardModel({
    required this.id,
    required this.emoji,
    required this.label,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  CardModel copyWith({bool? isFaceUp, bool? isMatched}) {
    return CardModel(
      id: id,
      emoji: emoji,
      label: label,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

class GameEmojis {
  static const List<Map<String, String>> all = [
    {'emoji': '🐶', 'label': 'Perro'},
    {'emoji': '🐱', 'label': 'Gato'},
    {'emoji': '🐸', 'label': 'Rana'},
    {'emoji': '🦁', 'label': 'León'},
    {'emoji': '🐧', 'label': 'Pingüino'},
    {'emoji': '🦊', 'label': 'Zorro'},
    {'emoji': '🍎', 'label': 'Manzana'},
    {'emoji': '🍓', 'label': 'Fresa'},
    {'emoji': '🍕', 'label': 'Pizza'},
    {'emoji': '⭐', 'label': 'Estrella'},
    {'emoji': '🚗', 'label': 'Carro'},
    {'emoji': '🚀', 'label': 'Cohete'},
  ];
}
