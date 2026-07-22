import 'package:equatable/equatable.dart';

class CategoryInventoryEntity extends Equatable {
  final String categoria;
  final String categoriaVer;

  CategoryInventoryEntity({
    required this.categoria,
    required this.categoriaVer,
  });

  String get displayName => categoriaVer;

  @override
  List<Object?> get props => [categoria, categoriaVer];
}
