import 'dart:math';
import 'package:control_parental_child/features/link_device/domain/link_device_result.dart';

class LinkDeviceService {
  static const List<String> _validCodes = [
    'PARENT-1234',
    'PARENT-5678',
    'PARENT-ABCD',
    'DEMO-0000',
  ];

  Future<LinkDeviceResult> linkDevice(String code) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final normalized = code.trim().toUpperCase();

    if (normalized.isEmpty) {
      return const LinkDeviceResult(
        status: LinkDeviceStatus.invalidCode,
        message: 'El código no puede estar vacío.',
      );
    }

    final random = Random();
    if (random.nextDouble() < 0.05) {
      return const LinkDeviceResult(
        status: LinkDeviceStatus.networkError,
        message: 'Error de red. Intenta de nuevo.',
      );
    }

    if (_validCodes.contains(normalized)) {
      return const LinkDeviceResult(
        status: LinkDeviceStatus.success,
        message: 'Dispositivo vinculado correctamente.',
      );
    }

    return const LinkDeviceResult(
      status: LinkDeviceStatus.invalidCode,
      message: 'Código inválido. Verifica e intenta de nuevo.',
    );
  }
}
