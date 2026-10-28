import 'dart:io';

import 'package:dartz/dartz.dart' as dartz;
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/inventory/domain/entities/category_inventory_entity.dart';
import 'package:velcel/features/inventory/domain/entities/product_inventory_entity.dart';
import 'package:velcel/features/inventory/presentation/providers/inventory_provider.dart';

class ViewInventoryScreen extends StatefulWidget {
  const ViewInventoryScreen({super.key});

  @override
  State<ViewInventoryScreen> createState() => _ViewInventoryScreenState();
}

class _ViewInventoryScreenState extends State<ViewInventoryScreen> {
  static const _fileStorageChannel = MethodChannel(
    'com.velcel.velcel/file_storage',
  );

  final TextEditingController _nameController = TextEditingController();

  late Future<dartz.Either<String, List<ProductInventoryEntity>>>
      _futureProducts;
  late Future<dartz.Either<String, List<CategoryInventoryEntity>>>
      _futureCategories;

  String _sucursal = '';
  CategoryInventoryEntity? _selectedCategory;
  List<ProductInventoryEntity> _products = [];
  bool _isSearching = false;
  bool _isExporting = false;
  bool _hasSearched = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final branch = context.read<BranchProvider>().branch;
    if (branch == null) {
      _futureProducts = Future.value(
        dartz.Left<String, List<ProductInventoryEntity>>(
          'La sucursal actual no está disponible.',
        ),
      );
      _futureCategories = Future.value(
        dartz.Left<String, List<CategoryInventoryEntity>>(
          'La sucursal actual no está disponible.',
        ),
      );
      return;
    }

    _sucursal = branch.nombre;
    final provider = context.read<InventoryProvider>();
    provider.selectedCategory = null;
    _futureProducts = provider.getProducts(_sucursal);
    _futureCategories = provider.getCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final name = _nameController.text.trim();

    if (name.isEmpty && _selectedCategory == null) {
      setState(() {
        _errorMessage = 'Ingresa un nombre o selecciona una categoría.';
      });
      return;
    }

    if (_sucursal.isEmpty) {
      setState(() {
        _errorMessage = 'La sucursal actual no está disponible.';
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _errorMessage = null;
      _products = [];
    });

    try {
      final provider = context.read<InventoryProvider>();
      final response = name.isNotEmpty
          ? await provider.getProductsWithName(name, _sucursal)
          : await provider.getProductsWithCategory(
              _sucursal,
              _selectedCategory!.categoria,
            );

      if (!mounted) return;

      String? searchError;
      int? resultCount;
      response.fold(
        (error) => searchError = error,
        (_) {
          _products = List<ProductInventoryEntity>.from(provider.products);
          resultCount = _products.length;
        },
      );

      setState(() {
        _errorMessage = searchError;
        _isSearching = false;
      });

      if (searchError == null && resultCount != null && mounted) {
        await _showResultsDialog(resultCount!);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No se pudo completar la consulta.';
          _isSearching = false;
        });
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _clearFilters() {
    _nameController.clear();
    final provider = context.read<InventoryProvider>();
    provider.selectedCategory = null;

    setState(() {
      _selectedCategory = null;
      _products = [];
      _hasSearched = false;
      _isSearching = false;
      _errorMessage = null;
      _futureProducts = provider.getProducts(_sucursal);
    });
  }

  void _onNameChanged(String value) {
    if (value.isEmpty || _selectedCategory == null) return;

    final provider = context.read<InventoryProvider>();
    provider.selectedCategory = null;
    setState(() {
      _selectedCategory = null;
      _errorMessage = null;
    });
  }

  void _onCategoryChanged(CategoryInventoryEntity? value) {
    if (value != null) _nameController.clear();

    final provider = context.read<InventoryProvider>();
    provider.selectedCategory = value;
    setState(() {
      _selectedCategory = value;
      _errorMessage = null;
    });
  }

  void _retryCategories() {
    setState(() {
      _futureCategories = context.read<InventoryProvider>().getCategories();
    });
  }

  void _retryProducts() {
    final provider = context.read<InventoryProvider>();
    setState(() {
      _futureProducts = provider.getProducts(_sucursal);
      _hasSearched = false;
      _isSearching = false;
      _errorMessage = null;
    });
  }

  Future<void> _showResultsDialog(int resultCount) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final resultWord =
        resultCount == 1 ? 'producto encontrado' : 'productos encontrados';

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Consulta completada',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: IsselPill(
                    text: '$resultCount $resultWord',
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: colors.surfaceContainer,
                    textColor: colors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                IsselButton(
                  text: 'Aceptar',
                  height: 52,
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final inventoryProvider = context.watch<InventoryProvider>();
    final canExport =
        !_isSearching && !_isExporting && inventoryProvider.products.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Consultar inventario',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: NavigationService.appBarLeading(context),
        actions: [
          IconButton(
            tooltip: 'Descargar inventario en Excel',
            onPressed: canExport
                ? () => _exportInventory(
                      List<ProductInventoryEntity>.from(
                        inventoryProvider.products,
                      ),
                    )
                : null,
            icon: const Icon(Icons.file_download_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child:
            FutureBuilder<dartz.Either<String, List<CategoryInventoryEntity>>>(
          future: _futureCategories,
          builder: (context, categorySnapshot) {
            if (categorySnapshot.connectionState == ConnectionState.waiting) {
              return _messageState(
                context,
                title: 'Cargando categorías',
                message: 'Estamos preparando los filtros disponibles.',
                loading: true,
              );
            }

            if (categorySnapshot.hasError || !categorySnapshot.hasData) {
              return _filterError(
                context,
                'No se pudieron cargar las categorías.',
              );
            }

            return categorySnapshot.data!.fold(
              (error) => _filterError(context, error),
              (categories) => _productsContent(context, categories),
            );
          },
        ),
      ),
    );
  }

  Widget _productsContent(
    BuildContext context,
    List<CategoryInventoryEntity> categories,
  ) {
    return FutureBuilder<dartz.Either<String, List<ProductInventoryEntity>>>(
      future: _futureProducts,
      builder: (context, productSnapshot) {
        if (productSnapshot.connectionState == ConnectionState.waiting) {
          return _content(
            context,
            categories,
            initialLoading: true,
          );
        }

        if (productSnapshot.hasError || !productSnapshot.hasData) {
          return _content(
            context,
            categories,
            initialError: 'No se pudo cargar el inventario.',
          );
        }

        return productSnapshot.data!.fold(
          (error) => _content(
            context,
            categories,
            initialError: error,
          ),
          (products) => _content(
            context,
            categories,
            initialProducts: products,
          ),
        );
      },
    );
  }

  Widget _content(
    BuildContext context,
    List<CategoryInventoryEntity> categories, {
    List<ProductInventoryEntity>? initialProducts,
    bool initialLoading = false,
    String? initialError,
  }) {
    final products = _hasSearched ? _products : initialProducts ?? _products;

    return LayoutBuilder(
      builder: (context, constraints) {
        const verticalPadding = 24.0;
        final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _filtersCard(context, categories),
              const SizedBox(height: 20),
              Expanded(
                child: _resultsCard(
                  context,
                  products,
                  initialLoading: initialLoading,
                  initialError: initialError,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filtersCard(
    BuildContext context,
    List<CategoryInventoryEntity> categories,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          return isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _nameField(context)),
                    const SizedBox(width: 14),
                    Expanded(child: _categoryField(context, categories)),
                    const SizedBox(width: 14),
                    _filterActions(context),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _nameField(context),
                    const SizedBox(height: 14),
                    _categoryField(context, categories),
                    const SizedBox(height: 14),
                    _filterActions(
                      context,
                      expanded: true,
                    ),
                  ],
                );
        },
      ),
    );
  }

  Widget _nameField(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Nombre del producto',
          style: theme.textTheme.labelMedium?.copyWith(color: colors.outline),
        ),
        const SizedBox(height: 6),
        IsselTextFormField(
          controller: _nameController,
          hintText: 'Ej. iPhone',
          prefixIcon: Icons.search_outlined,
          fillColor: colors.surfaceContainer,
          height: 50,
          textInputAction: TextInputAction.search,
          onChanged: _onNameChanged,
          onSubmitted: (_) => _search(),
        ),
      ],
    );
  }

  Widget _categoryField(
    BuildContext context,
    List<CategoryInventoryEntity> categories,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Categoría',
          style: theme.textTheme.labelMedium?.copyWith(color: colors.outline),
        ),
        const SizedBox(height: 6),
        IsselDropdown<CategoryInventoryEntity>(
          value: _selectedCategory,
          items: categories
              .map(
                (category) => DropdownMenuItem<CategoryInventoryEntity>(
                  value: category,
                  child: Text(category.displayName),
                ),
              )
              .toList(),
          hintText: 'Seleccionar categoría',
          height: 50,
          color: colors.surfaceContainer,
          onChanged: _isSearching ? null : _onCategoryChanged,
        ),
      ],
    );
  }

  Widget _filterActions(
    BuildContext context, {
    bool expanded = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    final searchButton = IsselButton(
      text: _isSearching ? 'Buscando...' : 'Buscar',
      height: 50,
      onTap: _isSearching ? null : _search,
    );
    final clearButton = IsselButton(
      text: 'Limpiar',
      height: 50,
      color: colors.surfaceContainer,
      textColor: colors.primary,
      onTap: _isSearching ? null : _clearFilters,
    );

    return Row(
      children: [
        if (expanded)
          Expanded(child: searchButton)
        else
          SizedBox(width: 140, child: searchButton),
        const SizedBox(width: 10),
        if (expanded)
          Expanded(child: clearButton)
        else
          SizedBox(width: 140, child: clearButton),
      ],
    );
  }

  Future<void> _exportInventory(List<ProductInventoryEntity> products) async {
    if (products.isEmpty || _isExporting) return;

    setState(() => _isExporting = true);

    try {
      final excel = Excel.createExcel();
      excel.rename('Sheet1', 'Inventario');
      final sheet = excel['Inventario'];

      final headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('FF2F6FED'),
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
      final headers = [
        'Categoría',
        'Nombre',
        'Disponibles',
        'Descripción',
      ];

      for (var column = 0; column < headers.length; column++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[column]);
        cell.cellStyle = headerStyle;
      }

      for (var row = 0; row < products.length; row++) {
        final product = products[row];
        final values = <CellValue>[
          TextCellValue(product.categoria),
          TextCellValue(product.nombre),
          IntCellValue(product.disponibles),
          TextCellValue(product.descripcion),
        ];

        for (var column = 0; column < values.length; column++) {
          sheet
              .cell(
                CellIndex.indexByColumnRow(
                  columnIndex: column,
                  rowIndex: row + 1,
                ),
              )
              .value = values[column];
        }
      }

      sheet.setColumnWidth(0, 22);
      sheet.setColumnWidth(1, 32);
      sheet.setColumnWidth(2, 16);
      sheet.setColumnWidth(3, 48);

      final bytes = excel.save();
      if (bytes == null) {
        throw StateError('No se pudo generar el archivo Excel.');
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'inventario_$timestamp.xlsx';
      if (Platform.isAndroid) {
        await _fileStorageChannel.invokeMethod<String>(
          'saveToPublicDownloads',
          {
            'fileName': fileName,
            'bytes': Uint8List.fromList(bytes),
            'mimeType':
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          },
        );
      } else {
        Directory? directory;
        try {
          directory = await getDownloadsDirectory();
        } catch (_) {
          // Algunas plataformas no exponen una carpeta de descargas.
        }
        directory ??= await getApplicationDocumentsDirectory();
        final file = File(
          '${directory.path}${Platform.pathSeparator}$fileName',
        );
        await file.writeAsBytes(bytes, flush: true);
      }

      if (Platform.isAndroid) {
        try {
          final notificationStatus = await Permission.notification.request();
          if (notificationStatus.isGranted) {
            await _fileStorageChannel.invokeMethod<void>(
              'showDownloadNotification',
              {'fileName': fileName},
            );
          }
        } catch (_) {
          // La notificación es opcional; no debe invalidar la descarga.
        }
      }

      if (!mounted) return;
      SnackbarService.showCorrect(
        context,
        'Inventario',
        'Archivo guardado en Descargas: $fileName',
      );
    } catch (_) {
      if (mounted) {
        SnackbarService.showIncorrect(
          context,
          'Inventario',
          'No se pudo generar el archivo Excel.',
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _resultsCard(
    BuildContext context,
    List<ProductInventoryEntity> products, {
    required bool initialLoading,
    required String? initialError,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _resultsContent(
            context,
            constraints,
            products,
            initialLoading: initialLoading,
            initialError: initialError,
          );
        },
      ),
    );
  }

  Widget _resultsContent(
    BuildContext context,
    BoxConstraints constraints,
    List<ProductInventoryEntity> products, {
    required bool initialLoading,
    required String? initialError,
  }) {
    if (_isSearching) {
      return _messageState(
        context,
        title: 'Buscando productos',
        message: 'Estamos consultando el inventario disponible.',
        loading: true,
      );
    }

    if (_errorMessage != null) {
      return _messageState(
        context,
        title: 'No se pudo completar la consulta',
        message: _errorMessage!,
      );
    }

    if (initialLoading) {
      return _messageState(
        context,
        title: 'Cargando inventario',
        message: 'Estamos preparando los productos disponibles.',
        loading: true,
      );
    }

    if (initialError != null) {
      return _messageState(
        context,
        title: 'No se pudo cargar el inventario',
        message: initialError,
        action: IsselButton(
          text: 'Reintentar',
          height: 46,
          width: 140,
          onTap: _retryProducts,
        ),
      );
    }

    if (!_hasSearched && products.isEmpty) {
      return _messageState(
        context,
        title: 'No hay productos disponibles',
        message: 'El inventario actual no tiene productos registrados.',
      );
    }

    if (products.isEmpty) {
      return _messageState(
        context,
        title: 'No encontramos productos',
        message: 'Prueba con otro nombre o categoría.',
      );
    }

    return constraints.maxWidth < 760
        ? _compactResults(context, products)
        : _tableResults(context, products);
  }

  Widget _tableResults(
    BuildContext context,
    List<ProductInventoryEntity> products,
  ) {
    final colors = Theme.of(context).colorScheme;

    return IsselTableWidget(
      color: colors.surface,
      header: IsselHeaderTable(
        titleHeaders: const [
          'Categoría',
          'Nombre',
          'Disponibles',
          'Descripción',
        ],
        colorPills: colors.surfaceContainer,
      ),
      rows: products
          .map(
            (product) => IsselRowTable(
              cells: [
                _resultCell(context, product.categoria),
                _resultCell(context, product.nombre),
                _resultCell(context, product.disponibles.toString()),
                _resultCell(context, product.descripcion),
              ],
            ),
          )
          .toList(),
      onTapRow: (index) => _showProductDetails(products[index]),
    );
  }

  IsselPill _resultCell(BuildContext context, String value) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cellText = Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface),
    );

    return IsselPill(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      color: colors.surfaceContainer,
      widget: Tooltip(message: value, child: cellText),
    );
  }

  Widget _compactResults(
    BuildContext context,
    List<ProductInventoryEntity> products,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.only(right: 4),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = products[index];
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return Material(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => _showProductDetails(product),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.nombre,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IsselPill(
                        text: '${product.disponibles} disponibles',
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        color: colors.surface,
                        textColor: colors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.categoria,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showProductDetails(ProductInventoryEntity product) async {
    final provider = context.read<InventoryProvider>();
    provider.imeis = [];
    await provider.getImeis(product.nombre);

    if (!mounted) return;

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final imeis = List<String>.from(provider.imeis);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Detalle del producto',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  IsselInfoField(
                    title: 'Categoría',
                    value: product.categoria,
                    backColor: colors.surfaceContainer,
                    valueBackColor: colors.surface,
                  ),
                  const SizedBox(height: 10),
                  IsselInfoField(
                    title: 'Disponibles',
                    value: product.disponibles.toString(),
                    backColor: colors.surfaceContainer,
                    valueBackColor: colors.surface,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.nombre,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.descripcion,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'IMEIs',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (imeis.isEmpty)
                    Text(
                      'No hay IMEIs registrados para este producto.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.outline,
                      ),
                    )
                  else
                    ...imeis.map(
                      (imei) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: IsselPill(
                          height: 40,
                          color: colors.surfaceContainer,
                          padding: const EdgeInsets.only(left: 12, right: 4),
                          widget: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  imei,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Copiar IMEI',
                                onPressed: () => _copyImei(context, imei),
                                icon: Icon(
                                  Icons.copy_outlined,
                                  size: 18,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  IsselButton(
                    text: 'Cerrar',
                    height: 52,
                    onTap: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copyImei(BuildContext context, String imei) async {
    await Clipboard.setData(ClipboardData(text: imei));
    if (!context.mounted) return;
    SnackbarService.showCorrect(
      context,
      'IMEI',
      'El IMEI se copió al portapapeles.',
    );
  }

  Widget _messageState(
    BuildContext context, {
    required String title,
    required String message,
    bool loading = false,
    Widget? action,
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
          if (action != null) ...[
            const SizedBox(height: 16),
            action,
          ],
        ],
      ),
    );
  }

  Widget _filterError(BuildContext context, String message) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _messageState(
              context,
              title: 'No se pudieron cargar los filtros',
              message: message,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 140,
              child: IsselButton(
                text: 'Reintentar',
                height: 46,
                onTap: _retryCategories,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
