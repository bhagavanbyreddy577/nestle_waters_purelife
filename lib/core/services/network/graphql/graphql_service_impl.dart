import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:nestle_waters_purelife/core/services/network/graphql/graphql_service.dart';
import 'package:nestle_waters_purelife/utils/exceptions/custom_failures.dart';

class GraphQLServiceImpl implements GraphQLService {
  final GraphQLClient client;
  GraphQLServiceImpl(this.client);

  @override
  Future<Either<Failure, T>> query<T>({
    required String document,
    Map<String, dynamic>? variables,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final result = await client.query(
        QueryOptions(
          document: gql(document),
          variables: variables ?? {},
        ),
      );
      if (result.hasException) {
        return Left(ServerFailure(message: result.exception.toString()));
      }
      final data = result.data;
      if (data == null) {
        return Left(ServerFailure(message: "No models returned from GraphQL query"));
      }
      return Right(fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message:e.toString()));
    }
  }

  @override
  Future<Either<Failure, T>> mutate<T>({
    required String document,
    Map<String, dynamic>? variables,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(document),
          variables: variables ?? {},
        ),
      );
      if (result.hasException) {
        return Left(ServerFailure(message:result.exception.toString()));
      }
      final data = result.data;
      if (data == null) {
        return Left(ServerFailure(message:"No models returned from GraphQL mutation"));
      }
      return Right(fromJson(data));
    } catch (e) {
      return Left(ServerFailure(message:e.toString()));
    }
  }
}
