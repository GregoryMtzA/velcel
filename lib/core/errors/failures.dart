import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable{

  final List<dynamic> properties;

  const Failure([this.properties = const <dynamic>[]]);

  @override
  List<Object?> get props => properties;

}


class ServerFailure extends Failure{
  String message;

  ServerFailure({
    required this.message
  });
}

class CacheFailure extends Failure{
  String message;

  CacheFailure({
    required this.message
  });
}

class ValidationFailure extends Failure{
  final String message;
  const ValidationFailure(this.message);
}