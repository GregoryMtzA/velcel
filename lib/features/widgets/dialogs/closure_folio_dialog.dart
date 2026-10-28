import 'dart:async';

import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';

class ClosureFolioDialog extends StatefulWidget {
  const ClosureFolioDialog({
    super.key,
    required this.folio,
    this.printError,
  });

  final int folio;
  final String? printError;

  @override
  State<ClosureFolioDialog> createState() => _ClosureFolioDialogState();
}

class _ClosureFolioDialogState extends State<ClosureFolioDialog> {
  Timer? _continueTimer;
  int _remainingSeconds = 3;

  bool get _canContinue => _remainingSeconds == 0;
  String? get printError => widget.printError;

  @override
  void initState() {
    super.initState();
    _continueTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds = (_remainingSeconds - 1).clamp(0, 3).toInt();
      });

      if (_canContinue) timer.cancel();
    });
  }

  @override
  void dispose() {
    _continueTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dialog(
      backgroundColor: colors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: colors.primary,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Corte realizado',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'El número de folio es:',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.outline,
                ),
              ),
              const SizedBox(height: 12),
              IsselInfoField2(
                icon: Icons.receipt_long_outlined,
                label: widget.folio.toString(),
                copy: true,
                backColor: colors.surfaceContainer,
              ),
              const SizedBox(height: 8),
              Text(
                widget.printError == null
                    ? 'Toca el icono para copiarlo al portapapeles.'
                    : 'El corte se guardó, pero no se pudo imprimir: $printError',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      widget.printError == null ? colors.outline : colors.error,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              if (!_canContinue)
                Text(
                  'El boton se activara en $_remainingSeconds segundos.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.outline,
                    fontSize: 12,
                  ),
                ),
              if (!_canContinue) const SizedBox(height: 8),
              IsselButton(
                text: _canContinue
                    ? 'Continuar'
                    : 'Continuar ($_remainingSeconds)',
                height: 50,
                onTap: _canContinue ? () => Navigator.of(context).pop() : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
