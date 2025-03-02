class PetAccessory {
  int? keyID;
  String name;
  double price;
  String category;
  String imageUrl;
  String description; // ✅ เพิ่มฟิลด์รายละเอียด
  DateTime date;

  PetAccessory({
    this.keyID,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.description, // ✅
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'keyID': keyID,
      'name': name,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'description': description, // ✅
      'date': date.toIso8601String(),
    };
  }
}
