import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:velcel/features/store/domain/entities/cart_entity.dart';
import 'package:velcel/features/store/domain/entities/cart_method_pay.dart';
import 'package:velcel/features/store/domain/entities/product_entity.dart';
import 'package:velcel/features/store/domain/entities/ticket_entity.dart';
import 'package:velcel/features/store/domain/repositories/products_repository.dart';
import 'package:velcel/features/store/domain/requests/venta_request.dart';
import 'package:velcel/features/store/domain/response/venta_response.dart';
import 'package:velcel/features/store/presentation/screens/home_screen/states/imei_product_entity.dart';
import 'package:velcel/features/widgets/impresora/ticket.dart';

import '../../../../../../core/app/enums/enums.dart';
import '../../../../../../core/errors/failures.dart';
import '../../../../domain/entities/cart_payment_type.dart';


class CartState extends ChangeNotifier {

  ProductsRepository productRepository;

  CartState({
    required this.productRepository,
  });

  final formKeyValidate = GlobalKey<FormState>();
  final creditFormKey = GlobalKey<FormState>();

  TextEditingController creditNameController = TextEditingController();
  TextEditingController creditPhoneController = TextEditingController();
  TextEditingController creditAddressController = TextEditingController();
  TextEditingController creditEnchangeController = TextEditingController();

  /// CONTROLADOR DE LAS VISTAS
  PageController cartPageController = PageController();

  /// ESTADOS DEL CARRITO
  CartStates _cartState = CartStates.cart;
  CartStates get cartState => _cartState;
  set cartState(CartStates value) {
    if (value == CartStates.cart){
      cartPageController.animateToPage(0, duration: const Duration(milliseconds: 350), curve: Curves.linear);
    } else if (value == CartStates.pay){
      cartPageController.animateToPage(1, duration: const Duration(milliseconds: 350), curve: Curves.linear);
    } else if (value == CartStates.purchase){
      cartPageController.animateToPage(2, duration: const Duration(milliseconds: 350), curve: Curves.linear);
    }
    _cartState = value;
    notifyListeners();
  }

  /// TIPO DE VENTA SELECCIONADO

  CartPaymentTypeEntity? _cartPaymentType;
  CartPaymentTypeEntity? get cartPaymentType => _cartPaymentType;
  set cartPaymentType(CartPaymentTypeEntity? value) {
    _cartPaymentType = value;
    notifyListeners();
  }

  /// TIPO DE PAGO SELECCIONADO
  CartMethodPayEntity? _cartMethodPayEntity;
  CartMethodPayEntity? get cartMethodPayEntity => _cartMethodPayEntity;
  set cartMethodPayEntity(CartMethodPayEntity? value) {
    _cartMethodPayEntity = value;
    notifyListeners();
  }

  /// CARRITO Y TOTAL
  List<CartProductEntity> cart = [];
  List<ImeiProductEntity> imeiProductEntitiesCart = [];
  double total = 0;

  /// PRODUCTO SELECCIONADO EN EL CARRITO
  ProductEntity? _selectedProduct;
  ProductEntity? get selectedProduct => _selectedProduct;
  set selectedProduct(ProductEntity? value) {
    _selectedProduct = value;
    notifyListeners();
  }

  /// VERIFICAR METODO

  bool applyForPaguitos () {

    // Si solo hay un producto en el carrito | Y | Si el producto es de categoria Celulares | Entonces | Aplica
    if (cart.length == 1 && cart.any((element) => element.product.category == "CELULARES",) && cart.first.quantity == 1) return true;

    return false;
  }

  List<ImeiProductEntity> getCartsWithImeiApply () {

    List<ImeiProductEntity> imeiProductEntities = [];

    List<CartProductEntity> productsWithImei = cart.where((cartProduct) => cartProduct.product.rimei == true,).toList();

    for (CartProductEntity cartProductEntity in productsWithImei){
      List<ImeiProductEntity> newList = List.generate(cartProductEntity.quantity, (index) {
        return ImeiProductEntity(cartProductEntity: cartProductEntity, imeiController: TextEditingController());
      },);
      imeiProductEntities.addAll(newList);
    }

    imeiProductEntitiesCart = imeiProductEntities;

    return imeiProductEntities;

  }

  Future<void> verifyImei() async {

    for (CartProductEntity cartProductEntity in cart){
      cartProductEntity.imeiList.clear();
    }

    for (ImeiProductEntity imeiProductEntity in imeiProductEntitiesCart){

      Either<Failure, bool> usecase = await productRepository.verifyImei(imeiProductEntity.cartProductEntity.product.name, imeiProductEntity.imeiController.text);

      usecase.fold(
        (l) {

        },
        (boolValue) {

          if (boolValue) {

            int index = cart.indexOf(imeiProductEntity.cartProductEntity);
            imeiProductEntity.error = false;
            cart[index].imeiList.add(imeiProductEntity.imeiController.text);

          } else {

            int index = cart.indexOf(imeiProductEntity.cartProductEntity);
            cart[index].imeiList.clear();
            imeiProductEntity.error = true;

          }

        },
      );

      notifyListeners();

    }

  }


  /// PRODUCTOS

  Future<Either<String, String>> addProduct(ProductEntity tempProduct, String sucursal) async {

    Either<Failure, int> usecase = await productRepository.checkStock(tempProduct.name, sucursal);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (stock) {

        int index = cart.indexWhere((cartProduct) => cartProduct.product == tempProduct,);



        if (index != -1){

          if (cart[index].quantity < stock) {
            cart[index].quantity += 1;
            getCartsWithImeiApply();
            calculateTotal();
            return const Right("Agregado Correctamente");
          }

          return const Left("Sin suficiente stock");

        }

        // Si no se encuentra el producto dentro del carrito
        // se agrega un nuevo producto

        CartProductEntity cartProductEntity = CartProductEntity(product: tempProduct, quantity: 1, imeiList: []);
        cart.add(cartProductEntity);
        getCartsWithImeiApply();

        calculateTotal();
        return const Right("Agregado Correctamente");

      },
    );
  }

  deleteProduct(CartProductEntity tempCartProduct) {
    cart.remove(tempCartProduct);
    getCartsWithImeiApply();
    calculateTotal();
  }

  void calculateTotal() {

    total = cart.fold(0, (previousValue, element) => (element.quantity * element.product.price) + previousValue,);

    notifyListeners();

  }


  /// VENTA
  Future<Either<String, String>> purchase(idCorte, usuario, sucursal) async {

    VentaRequest ventaRequest = VentaRequest(
      total: cartPaymentType!.enumType == PaymentTypes.paguitos ? double.parse(creditEnchangeController.text) : total,
      metodo: _cartMethodPayEntity!.name,
      sucursal: sucursal,
      usuario: usuario,
      idCorte: idCorte,
      credito: cartPaymentType!.enumType == PaymentTypes.paguitos ? cartPaymentType!.name : "No",
      nombres: cart.map((e) => e.product.name,).toList(),
      cantidades: cart.map((e) => e.quantity,).toList(),
      imeis: cart.expand((element) => element.imeiList,).toList(),
      nombreC: cartPaymentType!.enumType == PaymentTypes.paguitos ? creditNameController.text : null,
      telefonoC: cartPaymentType!.enumType == PaymentTypes.paguitos ? creditPhoneController.text : null,
      domicilioC: cartPaymentType!.enumType == PaymentTypes.paguitos ? creditAddressController.text : null,
    );

    Either<Failure,VentaResponse> usecase = await productRepository.generarVenta(ventaRequest);

    return usecase.fold(
      (l) => Left( (l as ServerFailure).message ),
      (ventaResponse) async {
        // Generar entidad de ticket
        TicketEntity ticketEntity = TicketEntity(
          sucursal: sucursal,
          total: cartPaymentType!.enumType == PaymentTypes.paguitos ? double.parse(creditEnchangeController.text) : total,
          ventaResponse: ventaResponse,
          cart: cart,
          supplierName: usuario,
          paguitos: cartPaymentType!.enumType == PaymentTypes.paguitos ? true : false
        );
        // Guardar Ticket
        await generarPdfTicketVenta(ticketEntity);
        // limpiar carrito y notificar
        clearAll();
        // retornar mensaje de éxito
        return const Right("Venta creada con éxito");
      },
    );

  }

  void clearAll(){
    cart.clear();
    imeiProductEntitiesCart.clear();
    creditNameController.text = "";
    creditPhoneController.text = "";
    creditAddressController.text = "";
    creditEnchangeController.text= "";
    cartPaymentType = null;
    cartMethodPayEntity = null;
    selectedProduct = null;
    calculateTotal();
    cartState = CartStates.cart;
  }



}

