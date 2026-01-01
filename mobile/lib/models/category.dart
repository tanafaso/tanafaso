import 'package:azkar/models/zekr.dart';

class Category {
  Category({
    required this.id,
    required this.name,
    required this.azkar,
  });

  int id;
  String name;
  List<Zekr> azkar;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        azkar: List<Zekr>.from(json["azkar"].map((x) => Zekr.fromJson(x))),
      );
}
