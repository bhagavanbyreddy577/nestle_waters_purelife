import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<void> setupHive() async {
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  // Register adapters
}
