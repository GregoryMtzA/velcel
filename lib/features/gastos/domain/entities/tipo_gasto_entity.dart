import 'package:equatable/equatable.dart';

class TipoGastoEntity extends Equatable {
  final String tipoGasto;

  TipoGastoEntity({
    required this.tipoGasto,
  });

  @override
  List<Object?> get props => [tipoGasto];


}
