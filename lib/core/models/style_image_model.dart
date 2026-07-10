import 'package:qwenhairaiapp/core/entities/style_image.dart';

class StyleImageModel extends StyleImage {
  const StyleImageModel({
    required super.id,
    required super.imageUrl,
    required super.styleName,
  });

  factory StyleImageModel.fromJson(Map<String, dynamic> json) {
    return StyleImageModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      styleName: json['styleName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'styleName': styleName,
    };
  }
}
