import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLClientProvider {
  static GraphQLClient createClient(String endpoint, {String? token}) {
    final httpLink = HttpLink(endpoint);
    final authLink = AuthLink(
      getToken: () async => token != null ? 'Bearer $token' : null,
    );
    final link = token != null ? authLink.concat(httpLink) : httpLink;
    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }
}
