enum LinkDeviceStatus { success, invalidCode, networkError }

class LinkDeviceResult {
  final LinkDeviceStatus status;
  final String? message;

  const LinkDeviceResult({required this.status, this.message});
}
