import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/auth/domain/entities/branch_entity.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';

class BranchListWidget extends StatefulWidget {
  const BranchListWidget({super.key});

  @override
  State<BranchListWidget> createState() => _BranchListWidgetState();
}

class _BranchListWidgetState extends State<BranchListWidget> {
  late Future<dartz.Either<String, List<BranchEntity>>> _future;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  void _loadBranches() {
    _future = context.read<BranchProvider>().getAllBranchs();
  }

  void _retry() {
    setState(_loadBranches);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dartz.Either<String, List<BranchEntity>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingState(context);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _errorState(context, 'No se pudieron cargar las sucursales.');
        }

        return snapshot.data!.fold(
          (error) => _errorState(context, error),
          (branches) => branches.isEmpty
              ? _emptyState(context)
              : _branchOptions(context, branches),
        );
      },
    );
  }

  Widget _branchOptions(BuildContext context, List<BranchEntity> branches) {
    final colors = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.only(right: 4, bottom: 2),
      itemCount: branches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final branch = branches[index];

        return IsselRadioTile<BranchEntity>(
          value: branch,
          groupValue: context.watch<BranchProvider>().branch,
          label: branch.displayName,
          height: 64,
          alignment: Alignment.centerLeft,
          surfaceColor: colors.surfaceContainer,
          onChanged: (value) => context.read<BranchProvider>().branch = value,
        );
      },
    );
  }

  Widget _loadingState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IsselCircularProgressIndicator(color: colors.primary),
          const SizedBox(height: 12),
          Text(
            'Cargando sucursales...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        'No hay sucursales disponibles.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.outline,
            ),
      ),
    );
  }

  Widget _errorState(BuildContext context, String message) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.outline,
                ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh_outlined),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
