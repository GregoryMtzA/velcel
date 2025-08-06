import 'package:equatable/equatable.dart';

class CategoryInventoryEntity extends Equatable {

  String categoria;

  CategoryInventoryEntity({
    required this.categoria
  });

  @override
  // TODO: implement props
  List<Object?> get props => [categoria];

}