import 'package:envied/envied.dart';

part 'prod_env.g.dart';

@Envied(path: 'prod.env')
final class ProdEnv {
  // TODO: Need to replace with the actual base url here
  @EnviedField(varName: 'BASE_URL', obfuscate: true)
  static final String baseUrl = _ProdEnv.baseUrl;
}