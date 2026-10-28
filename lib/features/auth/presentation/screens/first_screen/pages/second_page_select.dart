import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/features/auth/domain/entities/branch_entity.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/screens/first_screen/widgets/branch_list_widget.dart';
import 'package:velcel/features/auth/presentation/screens/splash_screen/splash_screen.dart';

class SecondPageSelect extends StatefulWidget {
  const SecondPageSelect({super.key});

  @override
  State<SecondPageSelect> createState() => _SecondPageSelectState();
}

class _SecondPageSelectState extends State<SecondPageSelect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showAnimation = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.addStatusListener((status) {
      if (!mounted) return;
      setState(() => _showAnimation = status == AnimationStatus.forward);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branch = context.watch<BranchProvider>().branch;

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: SizedBox(
                    height: constraints.maxHeight - 48,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _branchesCard(context, branch)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (_showAnimation)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Lottie.asset(
                  'assets/lotties/confetti.json',
                  controller: _controller,
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  fit: BoxFit.cover,
                  repeat: false,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _branchesCard(BuildContext context, BranchEntity? branch) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final branchCount = context.watch<BranchProvider>().allBranchs.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sucursales disponibles',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IsselPill(
                text: '$branchCount disponibles',
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: colors.surfaceContainer,
                textColor: colors.primary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const SizedBox(height: 14),
          const Expanded(child: BranchListWidget()),
          const SizedBox(height: 16),
          IsselButton(
            text: _isSaving ? 'Guardando...' : 'Continuar',
            height: 54,
            onTap: branch == null || _isSaving ? null : _confirmSelection,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSelection() async {
    final branch = context.read<BranchProvider>().branch;
    if (branch == null || _isSaving) return;

    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Confirmar sucursal',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta sucursal se usará para iniciar la sesión.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.outline,
                      ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          branch.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: IsselButton(
                        text: 'Cancelar',
                        height: 50,
                        color: Colors.transparent,
                        textColor: Colors.red,
                        onTap: () => Navigator.of(dialogContext).pop(false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: IsselButton(
                        text: 'Confirmar',
                        height: 50,
                        onTap: () => Navigator.of(dialogContext).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    await context.read<BranchProvider>().saveBranch();
    if (!mounted) return;

    await _controller.forward();
    if (!mounted) return;
    _controller.reset();
    await NavigationService.navigateTo(context, SplashScreen.init(context));
  }
}
