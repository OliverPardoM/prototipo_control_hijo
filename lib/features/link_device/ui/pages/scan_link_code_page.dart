import 'package:control_parental_child/features/link_device/domain/controllers/link_device_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/link_code_input.dart';
import '../widgets/link_primary_button.dart';
import '../widgets/qr_scanner_view.dart';

class ScanLinkCodePage extends StatefulWidget {
  const ScanLinkCodePage({super.key});

  @override
  State<ScanLinkCodePage> createState() => _ScanLinkCodePageState();
}

class _ScanLinkCodePageState extends State<ScanLinkCodePage> {
  final TextEditingController _codeController = TextEditingController();
  bool _showScanner = true;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeDetected(String code, LinkDeviceController controller) {
    _codeController.text = code;
    setState(() => _showScanner = false);
    controller.setScannedCode(code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => LinkDeviceController(),
      child: Consumer<LinkDeviceController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              title: Text(
                'Vincular dispositivo',
                style: theme.textTheme.titleLarge,
              ),
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escanea el código QR',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pídele al padre que muestre el código QR en su dispositivo o ingresa el código manualmente.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _showScanner
                          ? SizedBox(
                              key: const ValueKey('scanner'),
                              height: 280,
                              child: QrScannerView(
                                onCodeDetected: (code) =>
                                    _onCodeDetected(code, controller),
                              ),
                            )
                          : Container(
                              key: const ValueKey('scanned'),
                              height: 280,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.08,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.qr_code_scanner_rounded,
                                      size: 64,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Código escaneado',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _codeController.text,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6),
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextButton.icon(
                                      onPressed: () =>
                                          setState(() => _showScanner = true),
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text('Escanear de nuevo'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: theme.colorScheme.outline),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'o ingresa el código',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LinkCodeInput(
                      controller: _codeController,
                      enabled: !controller.isLoading,
                    ),
                    const SizedBox(height: 28),
                    LinkPrimaryButton(
                      label: 'Vincular dispositivo',
                      isLoading: controller.isLoading,
                      onPressed: () {
                        final code = _codeController.text.trim();
                        if (code.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor ingresa un código.'),
                            ),
                          );
                          return;
                        }
                        controller.linkDevice(code, context);
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Códigos de prueba: PARENT-1234, PARENT-ABCD',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
