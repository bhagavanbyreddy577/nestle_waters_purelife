import 'package:dartz/dartz.dart';
import 'package:nestle_waters_purelife/utils/exceptions/custom_failures.dart';

abstract class GraphQLService {
  Future<Either<Failure, T>> query<T>({
    required String document,
    Map<String, dynamic>? variables,
    required T Function(Map<String, dynamic> json) fromJson,
  });

  Future<Either<Failure, T>> mutate<T>({
    required String document,
    Map<String, dynamic>? variables,
    required T Function(Map<String, dynamic> json) fromJson,
  });
}
