import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import '../../data/models/mood_log_model.dart';

class NativeBridgeService {
  NativeBridgeService({required Logger logger}) : _logger = logger;

  final Logger _logger;
  static const MethodChannel _nativeChannel =
      MethodChannel(AppConstants.nativeChannelName);
  static const MethodChannel _widgetChannel =
      MethodChannel(AppConstants.widgetChannelName);

  Future<void> refreshHomeWidget(MoodSignal signal) async {
    try {
      await _widgetChannel.invokeMethod<void>(
        'updateWidgetSignal',
        <String, dynamic>{
          'signal': signal.label,
          'emoji': signal.emoji,
        },
      );
    } on PlatformException catch (error) {
      _logger.w('Widget guncellenemedi', error: error);
    }
  }

  Future<void> triggerNativeCalmMode() async {
    try {
      await _nativeChannel.invokeMethod<void>('triggerCalmMode');
    } on PlatformException catch (error) {
      _logger.w('Native calm mode cagri hatasi', error: error);
    }
  }
}
