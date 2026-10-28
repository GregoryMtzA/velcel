import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:provider/provider.dart';
import 'package:velcel/core/app/dialogs.dart';
import 'package:velcel/core/app/expresiones_regulares.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/core/app/snackbars.dart';
import 'package:velcel/features/auth/presentation/providers/branch_provider.dart';
import 'package:velcel/features/auth/presentation/providers/user_provider.dart';
import 'package:velcel/features/services/domain/entities/reporte_servicio_entity.dart';
import 'package:velcel/features/services/presentation/providers/services_provider.dart';
import 'package:velcel/features/services/presentation/screens/home_service_screen.dart';

import '../../../widgets/impresora/reporte_servicio.dart';

class OrderServiceScreen extends StatefulWidget {
  const OrderServiceScreen({super.key});

  @override
  State<OrderServiceScreen> createState() => _OrderServiceScreenState();
}

class _OrderServiceScreenState extends State<OrderServiceScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  final TextEditingController _reportedFaultController =
      TextEditingController();
  final TextEditingController _observationsController = TextEditingController();
  final TextEditingController _collectionDateController =
      TextEditingController();

  DateTime _collectionDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _collectionDateController.text = _formatDate(_collectionDate);
  }

  @override
  void dispose() {
    _contactNumberController.dispose();
    _customerNameController.dispose();
    _brandController.dispose();
    _imeiController.dispose();
    _modelController.dispose();
    _seriesController.dispose();
    _shortDescriptionController.dispose();
    _reportedFaultController.dispose();
    _observationsController.dispose();
    _collectionDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear orden'),
        leading: NavigationService.appBarLeading(context),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;
            final isWide = constraints.maxWidth >= 820;
            const verticalPadding = 24.0;
            final availableHeight = constraints.maxHeight - verticalPadding * 2;
            final availableWidth = constraints.maxWidth - horizontalPadding * 2;
            final formWidth = availableWidth.clamp(0.0, 980.0).toDouble();

            final content = SizedBox(
              width: formWidth,
              child: _surfaceCard(
                context,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionHeader(
                        context,
                        'Datos de la orden',
                        'Completa la información del cliente y del equipo.',
                      ),
                      const SizedBox(height: 20),
                      _clientSection(context),
                      const SizedBox(height: 16),
                      _deviceSection(context),
                      const SizedBox(height: 16),
                      _serviceSection(context),
                      const SizedBox(height: 24),
                      IsselButton(
                        text:
                            _isSubmitting ? 'Creando orden...' : 'Crear orden',
                        height: 58,
                        onTap: _isSubmitting ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ),
            );

            final scrollContent = isWide
                ? ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: availableHeight > 0 ? availableHeight : 0,
                    ),
                    child: Center(child: content),
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: content,
                  );

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                verticalPadding,
              ),
              child: scrollContent,
            );
          },
        ),
      ),
    );
  }

  Widget _clientSection(BuildContext context) {
    return _sectionCard(
      context,
      title: 'Cliente',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fieldsAreWide = constraints.maxWidth >= 520;
          final customerName = _textField(
            context,
            controller: _customerNameController,
            hintText: 'Nombre del cliente',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
          );
          final contactNumber = _textField(
            context,
            controller: _contactNumberController,
            hintText: 'Número de contacto',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [TextInputFormatters().cellPhoneNumber],
            textInputAction: TextInputAction.next,
            validator: (value) {
              final validation =
                  _required(value, 'Ingresa el número de contacto');
              if (validation != null) return validation;
              if (value!.length != 10) {
                return 'Ingresa un número de 10 dígitos';
              }
              return null;
            },
          );

          if (!fieldsAreWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                customerName,
                const SizedBox(height: 14),
                contactNumber,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: customerName),
              const SizedBox(width: 14),
              Expanded(child: contactNumber),
            ],
          );
        },
      ),
    );
  }

  Widget _deviceSection(BuildContext context) {
    return _sectionCard(
      context,
      title: 'Equipo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final fieldsAreWide = constraints.maxWidth >= 520;
              final brand = _textField(
                context,
                controller: _brandController,
                hintText: 'Marca',
                prefixIcon: Icons.phone_android_outlined,
                textInputAction: TextInputAction.next,
              );
              final model = _textField(
                context,
                controller: _modelController,
                hintText: 'Modelo',
                prefixIcon: Icons.devices_other_outlined,
                textInputAction: TextInputAction.next,
              );

              if (!fieldsAreWide) {
                return Column(
                  children: [
                    brand,
                    const SizedBox(height: 14),
                    model,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: brand),
                  const SizedBox(width: 14),
                  Expanded(child: model),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final fieldsAreWide = constraints.maxWidth >= 520;
              final series = _textField(
                context,
                controller: _seriesController,
                hintText: 'Número de serie',
                prefixIcon: Icons.numbers_outlined,
                textInputAction: TextInputAction.next,
              );
              final imei = _textField(
                context,
                controller: _imeiController,
                hintText: 'IMEI',
                prefixIcon: Icons.qr_code_2_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                textInputAction: TextInputAction.next,
              );

              if (!fieldsAreWide) {
                return Column(
                  children: [
                    series,
                    const SizedBox(height: 14),
                    imei,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: series),
                  const SizedBox(width: 14),
                  Expanded(child: imei),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          _textField(
            context,
            controller: _shortDescriptionController,
            hintText: 'Descripción corta del equipo',
            maxLines: 2,
            height: 86,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }

  Widget _serviceSection(BuildContext context) {
    return _sectionCard(
      context,
      title: 'Servicio',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dateField(context),
              const SizedBox(height: 14),
              _textField(
                context,
                controller: _reportedFaultController,
                hintText: 'Falla reportada',
                maxLines: 2,
                height: 86,
                textInputAction: TextInputAction.next,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _textField(
            context,
            controller: _observationsController,
            hintText: 'Observaciones de recepción',
            maxLines: 4,
            height: 118,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }

  Widget _textField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    double height = 58,
    String? Function(String?)? validator,
  }) {
    return IsselTextFormField(
      controller: controller,
      hintText: hintText,
      prefixIcon: prefixIcon,
      fillColor: Theme.of(context).colorScheme.surface,
      height: height,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      readOnly: _isSubmitting,
      validator:
          validator ?? (value) => _required(value, 'Completa este campo'),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _dateField(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isSubmitting ? null : _pickCollectionDate,
      child: IgnorePointer(
        child: IsselTextFormField(
          controller: _collectionDateController,
          hintText: 'Fecha de entrega',
          prefixIcon: Icons.calendar_today_outlined,
          fillColor: Theme.of(context).colorScheme.surface,
          height: 58,
          readOnly: true,
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.outline,
          ),
        ),
      ],
    );
  }

  Widget _surfaceCard(BuildContext context, {required Widget child}) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Future<void> _pickCollectionDate() async {
    final today = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _collectionDate,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 2, today.month, today.day),
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      _collectionDate = pickedDate;
      _collectionDateController.text = _formatDate(pickedDate);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final branch = context.read<BranchProvider>().branch;
    final user = context.read<UserProvider>().userEntity;

    if (branch == null || user?.usuario == null) {
      SnackbarService.showIncorrect(
        context,
        'Orden',
        'La sucursal o el usuario actual no están disponibles.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await context.read<ServicesProvider>().createService(
            branch.nombre,
            user!.usuario!,
            _customerNameController.text.trim(),
            _contactNumberController.text.trim(),
            _brandController.text.trim(),
            _modelController.text.trim(),
            _seriesController.text.trim(),
            _shortDescriptionController.text.trim(),
            _imeiController.text.trim(),
            _collectionDate,
            _reportedFaultController.text.trim(),
            _observationsController.text.trim(),
          );

      if (!mounted) return;

      await response.fold<Future<void>>(
        (error) async {
          SnackbarService.showIncorrect(context, 'Orden', error);
        },
        (service) async {
          final ticketEntity = ReporteServicioEntity(
            sucursal: branch.nombre,
            fecha: service.fechaRec,
            cliente: service.cliente,
            descripcionCorta: service.descCorta,
            fallaReportada: service.fallaRep,
            fechaEstimada: service.fechaSal,
            folio: service.folio,
            imei: service.imei,
            marca: service.marca,
            modelo: service.modelo,
            observacionLlega: service.observLleg,
            serie: service.serie,
          );

          await generarReporteServicio(ticketEntity);

          if (!mounted) return;

          SnackbarService.showCorrectWithoutRemoveCurrent(
            context,
            'servicio',
            'Generado exitosamente',
          );

          DialogService.infoDialog(
            context: context,
            barrierDismissible: false,
            title: 'Número de folio',
            text: service.folio.toString(),
            backButtonText: 'Copiar',
            onTap: () async {
              await Clipboard.setData(
                ClipboardData(text: service.folio.toString()),
              );
              if (!mounted) return;
              SnackbarService.showCorrectWithoutRemoveCurrent(
                context,
                'servicio',
                'Folio copiado',
              );
              await NavigationService.navigateTo(
                context,
                HomeServiceScreen(),
              );
            },
          );
        },
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
}
