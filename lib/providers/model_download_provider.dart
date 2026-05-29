import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/services/model_download_service.dart';

sealed class ModelState { const ModelState(); }

class ModelStateNotReady extends ModelState { const ModelStateNotReady(); }

class ModelStateDownloading extends ModelState {
  final double progress; // 0.0–1.0
  const ModelStateDownloading(this.progress);
}

class ModelStateReady extends ModelState {
  final String modelPath;
  const ModelStateReady(this.modelPath);
}

class ModelStateError extends ModelState {
  final String message;
  const ModelStateError(this.message);
}

class ModelDownloadNotifier extends AsyncNotifier<ModelState> {
  StreamSubscription<double>? _sub;

  @override
  Future<ModelState> build() async {
    ref.onDispose(() => _sub?.cancel());
    final ready = await ModelDownloadService.isReady();
    if (ready) {
      return ModelStateReady(await ModelDownloadService.modelPath());
    }
    return const ModelStateNotReady();
  }

  Future<void> startDownload() async {
    if (state.value is ModelStateDownloading) return;
    state = const AsyncData(ModelStateDownloading(0));
    _sub = ModelDownloadService.download().listen(
      (progress) => state = AsyncData(ModelStateDownloading(progress)),
      onDone: () async {
        final path = await ModelDownloadService.modelPath();
        state = AsyncData(ModelStateReady(path));
      },
      onError: (Object err) async {
        await ModelDownloadService.deletePartial();
        state = AsyncData(ModelStateError(err.toString()));
      },
      cancelOnError: true,
    );
  }

  Future<void> cancelDownload() async {
    await _sub?.cancel();
    _sub = null;
    await ModelDownloadService.deletePartial();
    state = const AsyncData(ModelStateNotReady());
  }

  Future<void> retry() async {
    await cancelDownload();
    await startDownload();
  }

  Future<void> deleteModel() async {
    await ModelDownloadService.deleteModel();
    state = const AsyncData(ModelStateNotReady());
  }
}

final modelDownloadProvider =
    AsyncNotifierProvider<ModelDownloadNotifier, ModelState>(
  ModelDownloadNotifier.new,
);
