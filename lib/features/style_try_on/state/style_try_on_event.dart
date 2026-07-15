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
  final String faceScanPath;
  final String targetHairStylePath;

  const GenerateHair3DModelEvent({
    required this.faceScanPath,
    required this.targetHairStylePath,
  });
}
