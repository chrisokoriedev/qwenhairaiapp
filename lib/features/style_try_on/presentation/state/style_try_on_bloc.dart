import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qwenhairaiapp/core/errors/failures.dart';
import 'package:qwenhairaiapp/features/style_try_on/domain/usecases/process_camera_image.dart';
import 'package:qwenhairaiapp/core/repositories/style_try_on_repository.dart';
import 'style_try_on_event.dart';
import 'style_try_on_state.dart';

class StyleTryOnBloc extends Bloc<StyleTryOnEvent, StyleTryOnState> {
  final StyleTryOnRepository repository;
  final ProcessCameraImage processCameraImageUseCase;

  StyleTryOnBloc({
    required this.repository,
    required this.processCameraImageUseCase,
  }) : super(const StyleTryOnInitial()) {
    on<GetAvailableStylesEvent>(_onGetAvailableStyles);
    on<ProcessImageEvent>(_onProcessImage);
  }

  Future<void> _onGetAvailableStyles(
    GetAvailableStylesEvent event,
    Emitter<StyleTryOnState> emit,
  ) async {
    emit(const StyleTryOnLoading());
    final result = await repository.getAvailableStyles();
    switch (result) {
      case Success(value: final styles):
        emit(StylesLoaded(styles));
      case FailureResult(failure: final failure):
        emit(StyleTryOnError(failure.message));
    }
  }

  Future<void> _onProcessImage(
    ProcessImageEvent event,
    Emitter<StyleTryOnState> emit,
  ) async {
    emit(const StyleTryOnLoading());
    final result = await processCameraImageUseCase(
      ProcessCameraImageParams(
        imagePath: event.imagePath,
        styleId: event.styleId,
      ),
    );
    switch (result) {
      case Success(value: final processedImage):
        emit(StyleProcessSuccess(processedImage));
      case FailureResult(failure: final failure):
        emit(StyleTryOnError(failure.message));
    }
  }
}
