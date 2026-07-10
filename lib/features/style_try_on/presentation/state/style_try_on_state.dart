import 'package:qwenhairaiapp/core/entities/style_image.dart';
import 'package:qwenhairaiapp/core/entities/hair_3d_render.dart';

sealed class StyleTryOnState {
  const StyleTryOnState();
}

class StyleTryOnInitial extends StyleTryOnState {
  const StyleTryOnInitial();
}

class StyleTryOnLoading extends StyleTryOnState {
  const StyleTryOnLoading();
}

class StylesLoaded extends StyleTryOnState {
  final List<StyleImage> styles;
  const StylesLoaded(this.styles);
}

class StyleProcessSuccess extends StyleTryOnState {
  final StyleImage processedImage;
  const StyleProcessSuccess(this.processedImage);
}

class StyleTryOnError extends StyleTryOnState {
  final String message;
  const StyleTryOnError(this.message);
}

class Hair3DProcessing extends StyleTryOnState {
  const Hair3DProcessing();
}

class Hair3DLoaded extends StyleTryOnState {
  final Hair3DRender render;
  const Hair3DLoaded(this.render);
}

class Hair3DError extends StyleTryOnState {
  final String message;
  const Hair3DError(this.message);
}
