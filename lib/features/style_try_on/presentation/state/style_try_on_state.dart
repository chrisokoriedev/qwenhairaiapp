import 'package:qwenhairaiapp/core/entities/style_image.dart';

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
