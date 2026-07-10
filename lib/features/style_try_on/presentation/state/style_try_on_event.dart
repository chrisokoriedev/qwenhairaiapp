sealed class StyleTryOnEvent {
  const StyleTryOnEvent();
}

class GetAvailableStylesEvent extends StyleTryOnEvent {
  const GetAvailableStylesEvent();
}

class ProcessImageEvent extends StyleTryOnEvent {
  final String imagePath;
  final String styleId;

  const ProcessImageEvent({
    required this.imagePath,
    required this.styleId,
  });
}

class GenerateHair3DModelEvent extends StyleTryOnEvent {
  final String frontPath;
  final String backPath;
  final String leftPath;
  final String rightPath;

  const GenerateHair3DModelEvent({
    required this.frontPath,
    required this.backPath,
    required this.leftPath,
    required this.rightPath,
  });
}
