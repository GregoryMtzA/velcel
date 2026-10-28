import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/features/auth/domain/entities/user_entity.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';

class LoginFormUsers extends StatefulWidget {
  const LoginFormUsers({super.key});

  @override
  State<LoginFormUsers> createState() => _LoginFormUsersState();
}

class _LoginFormUsersState extends State<LoginFormUsers> {
  late Future<dartz.Either<String, List<UserEntity>>> _future;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    final branch = context.read<BranchProvider>().branch;
    if (branch == null) {
      _future = Future.value(
        const dartz.Left<String, List<UserEntity>>(
          'No hay una sucursal seleccionada.',
        ),
      );
      return;
    }

    _future = context.read<UserProvider>().getAllUsers(branch.nombre);
  }

  void _retry() {
    setState(_loadUsers);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dartz.Either<String, List<UserEntity>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingState(context);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _errorState(context, 'No se pudieron cargar los usuarios.');
        }

        return snapshot.data!.fold(
          (error) => _errorState(context, error),
          (users) => users.isEmpty
              ? _emptyState(context)
              : _userSelector(context, users),
        );
      },
    );
  }

  Widget _userSelector(BuildContext context, List<UserEntity> users) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = context.watch<UserProvider>().userEntity;

    return IsselDropdown2<UserEntity>(
      value: _matchingUser(users, selected),
      hintText: 'Seleccionar usuario',
      color: colors.surfaceContainer,
      height: 58,
      items: users.map((user) {
        final name = user.nombre?.trim();
        final username = user.usuario?.trim();
        final label = name?.isNotEmpty == true
            ? '$name${username?.isNotEmpty == true ? ' · $username' : ''}'
            : username?.isNotEmpty == true
                ? username!
                : 'Usuario';

        return DropdownMenuItem<UserEntity>(
          value: user,
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        );
      }).toList(),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null) return 'Selecciona un usuario';
        return null;
      },
      onChanged: (value) => context.read<UserProvider>().userEntity = value,
    );
  }

  UserEntity? _matchingUser(
    List<UserEntity> users,
    UserEntity? selected,
  ) {
    if (selected == null) return null;
    for (final user in users) {
      if (user.id == selected.id) return user;
    }
    return null;
  }

  Widget _loadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IsselShimmer(width: double.infinity, height: 58),
        const SizedBox(height: 8),
        Text(
          'Cargando usuarios...',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.outline,
          ),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      'No hay usuarios disponibles para esta sucursal.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.outline,
          ),
    );
  }

  Widget _errorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.outline,
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _retry,
          icon: const Icon(Icons.refresh_outlined, size: 18),
          label: const Text('Reintentar'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
        ),
      ],
    );
  }
}
