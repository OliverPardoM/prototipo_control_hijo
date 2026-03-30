import 'package:flutter/material.dart';

class LinkCodeInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const LinkCodeInput({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      enabled: enabled,
      textCapitalization: TextCapitalization.characters,
      style: theme.textTheme.titleLarge,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: 'Ej: PARENT-1234',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        prefixIcon: Icon(Icons.key_outlined, color: theme.colorScheme.primary),
      ),
    );
  }
}
