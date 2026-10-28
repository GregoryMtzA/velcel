import 'dart:async';

import 'package:flutter/material.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/store/domain/entities/product_entity.dart';
import 'package:velcel/features/store/presentation/providers/products_provider.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/cart_state.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/widgets/cart_product_widget.dart';

class SearchProductsWidget extends StatefulWidget {
  const SearchProductsWidget({
    super.key,
    required this.onTapMenu,
  });

  final VoidCallback onTapMenu;

  @override
  State<SearchProductsWidget> createState() => _SearchProductsWidgetState();
}

class _SearchProductsWidgetState extends State<SearchProductsWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = context.read<CartState>();
    final productsProvider = context.watch<ProductsProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _searchBar(context),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: _productsContent(
              context,
              cartState,
              productsProvider.products,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton(
          tooltip: 'Abrir menú',
          onPressed: widget.onTapMenu,
          icon: const Icon(Icons.menu_outlined),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: IsselTextFormField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            hintText: 'Buscar producto',
            prefixIcon: Icons.search_outlined,
            fillColor: colors.surfaceContainer,
            height: 52,
            readOnly: _isSearching,
            textInputAction: TextInputAction.search,
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
              _scheduleSearch();
            },
            onSubmitted: (_) {
              _searchProducts();
            },
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 112,
          child: IsselButton(
            text: _isSearching ? 'Buscando...' : 'Buscar',
            height: 52,
            onTap: _isSearching ? null : _searchProducts,
          ),
        ),
      ],
    );
  }

  Widget _productsContent(
    BuildContext context,
    CartState cartState,
    List<ProductEntity> products,
  ) {
    if (_isSearching) {
      return _messageState(
        context,
        title: 'Buscando productos',
        message: 'Estamos consultando el catálogo disponible.',
        loading: true,
      );
    }

    if (_errorMessage != null) {
      return _messageState(
        context,
        title: 'No se pudo buscar',
        message: _errorMessage!,
      );
    }

    if (products.isEmpty) {
      return _messageState(
        context,
        title: 'Busca un producto',
        message: 'Escribe un nombre para mostrar los productos disponibles.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600
            ? 3
            : constraints.maxWidth >= 420
                ? 2
                : 1;

        return GridView.builder(
          padding: const EdgeInsets.only(right: 4, bottom: 4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: columns == 1 ? 1.9 : 1.1,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            return CartProductWidget(
              producto: product,
              onTap: () => _addProduct(context, cartState, product),
            );
          },
        );
      },
    );
  }

  Widget _messageState(
    BuildContext context, {
    required String title,
    required String message,
    bool loading = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading) ...[
            IsselCircularProgressIndicator(color: colors.primary),
            const SizedBox(height: 14),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.outline,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchProducts() async {
    _searchDebounce?.cancel();

    if (_isSearching) return;

    final value = _searchController.text.trim();

    if (value.isEmpty) {
      setState(() => _errorMessage = 'Escribe el nombre del producto.');
      return;
    }

    final branchType = context.read<BranchProvider>().branch?.tipo;
    if (branchType == null) {
      setState(() => _errorMessage = 'La sucursal actual no está disponible.');
      return;
    }

    _searchFocusNode.requestFocus();
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final response = await context
          .read<ProductsProvider>()
          .searchProductWithName(value, branchType);

      if (!mounted) return;

      response.fold(
        (error) => setState(() => _errorMessage = error),
        (_) {},
      );
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'No se pudo consultar el catálogo.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);

        if (_searchController.text.trim().isNotEmpty &&
            _searchController.text.trim() != value) {
          _scheduleSearch();
        }
      }
    }
  }

  void _scheduleSearch() {
    _searchDebounce?.cancel();

    if (_searchController.text.trim().isEmpty) return;

    _searchDebounce = Timer(const Duration(milliseconds: 800), () {
      if (mounted) _searchProducts();
    });
  }

  Future<void> _addProduct(
    BuildContext context,
    CartState cartState,
    ProductEntity product,
  ) async {
    final branch = context.read<BranchProvider>().branch;
    if (branch == null) {
      SnackbarService.showIncorrect(
        context,
        'Stock',
        'La sucursal actual no está disponible.',
      );
      return;
    }

    final response = await cartState.addProduct(product, branch.nombre);
    if (!mounted) return;

    response.fold(
      (error) => SnackbarService.showIncorrect(context, 'Stock', error),
      (message) => SnackbarService.showCorrect(context, 'Stock', message),
    );
  }
}
