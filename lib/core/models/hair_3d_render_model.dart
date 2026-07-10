import 'package:qwenhairaiapp/core/entities/hair_3d_render.dart';

class Hair3DRenderModel extends Hair3DRender {
  const Hair3DRenderModel({
    required super.id,
    required super.modelUrl,
    required super.status,
  });

  factory Hair3DRenderModel.fromJson(Map<String, dynamic> json) {
    return Hair3DRenderModel(
      id: json['id'] as String,
      modelUrl: json['modelUrl'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelUrl': modelUrl,
      'status': status,
    };
  }
}
