import 'package:control_parental_child/features/link_device/domain/data/link_device_service.dart';
import 'package:control_parental_child/features/link_device/domain/link_device_result.dart';
import 'package:flutter/material.dart';

enum LinkDeviceState { idle, loading, success, error }

class LinkDeviceController extends ChangeNotifier {
  final LinkDeviceService _service;

  LinkDeviceController({LinkDeviceService? service})
    : _service = service ?? LinkDeviceService();

  LinkDeviceState _state = LinkDeviceState.idle;
  String _errorMessage = '';
  String _scannedCode = '';

  LinkDeviceState get state => _state;
  String get errorMessage => _errorMessage;
  String get scannedCode => _scannedCode;
  bool get isLoading => _state == LinkDeviceState.loading;

  void setScannedCode(String code) {
    _scannedCode = code;
    notifyListeners();
  }

  Future<void> linkDevice(String code, BuildContext context) async {
    if (_state == LinkDeviceState.loading) return;

    _state = LinkDeviceState.loading;
    _errorMessage = '';
    notifyListeners();

    final result = await _service.linkDevice(code);

    switch (result.status) {
      case LinkDeviceStatus.success:
        _state = LinkDeviceState.success;
        notifyListeners();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/link-success');
        }
        break;
      case LinkDeviceStatus.invalidCode:
      case LinkDeviceStatus.networkError:
        _state = LinkDeviceState.error;
        _errorMessage = result.message ?? 'Error desconocido.';
        notifyListeners();
        if (context.mounted) {
          Navigator.pushNamed(context, '/link-error', arguments: _errorMessage);
        }
        break;
    }
  }

  void reset() {
    _state = LinkDeviceState.idle;
    _errorMessage = '';
    _scannedCode = '';
    notifyListeners();
  }
}
