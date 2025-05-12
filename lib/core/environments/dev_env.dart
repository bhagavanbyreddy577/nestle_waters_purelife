import 'package:envied/envied.dart';

part 'dev_env.g.dart';

@Envied(path: 'dev.env')
final class DevEnv {
  // TODO: Need to replace with the actual base url here
  @EnviedField(varName: 'BASE_URL', obfuscate: true)
  static final String baseUrl = _DevEnv.baseUrl;
}