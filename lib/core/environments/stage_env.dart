import 'package:envied/envied.dart';

part 'stage_env.g.dart';

@Envied(path: 'stage.env')
final class StageEnv {
  // TODO: Need to replace with the actual base url here
  @EnviedField(varName: 'BASE_URL', obfuscate: true)
  static final String baseUrl = _StageEnv.baseUrl;
}