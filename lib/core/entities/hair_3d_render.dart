class Hair3DRender {
  final String id;
  final String modelUrl;
  final String status; // 'processing', 'completed', 'failed'

  const Hair3DRender({
    required this.id,
    required this.modelUrl,
    required this.status,
  });
}
