import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List<dynamic> properties;
  // If the subclasses have some properties, they'll get passed to this constructor
  // so that Equatable can perform value comparison.
  const Failure([
    this.properties = const <dynamic>[],
  ]) : super();

  @override
  List<Object?> get props => properties;
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.properties = const <dynamic>[],
  ]) : super();
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.properties = const <dynamic>[],
  ]) : super();
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.properties = const <dynamic>[],
  ]) : super();
}

class NoDataFailure extends Failure {
  const NoDataFailure([
    super.properties = const <dynamic>[],
  ]) : super();
}
