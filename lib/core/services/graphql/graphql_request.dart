class GraphQLRequest<T> {
  final String document;
  final Map<String, dynamic>? variables;
  final T Function(Map<String, dynamic>) fromJson;
  GraphQLRequest({
    required this.document,
    this.variables,
    required this.fromJson,
  });
}
