import 'package:package_info_plus/package_info_plus.dart';

/// A helper class that provides app version information
class NVersionHelper {

  /// Get formatted version string in the format "Version X.Y.Z (Build 123)"
  static Future<String> getFormattedVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final String version = packageInfo.version;
    final String buildNumber = packageInfo.buildNumber;

    return 'Version $version (Build $buildNumber)';
  }

  /// Get only the version number (e.g. "1.2.3")
  static Future<String> getVersionNumber() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Get only the build number (e.g. "42")
  static Future<String> getBuildNumber() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber;
  }

  /// Get app name as defined in pubspec.yaml
  static Future<String> getAppName() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.appName;
  }

  /// Get package name/bundle identifier
  static Future<String> getPackageName() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.packageName;
  }
}

/// TODO: Example usage (Need to remove in production)
/*
class VersionInfoWidget extends StatelessWidget {
  const VersionInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: NVersionHelper.getFormattedVersion(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading version info...');
        }

        if (snapshot.hasError) {
          return const Text('Error loading version info');
        }

        return Text(
          snapshot.data ?? 'Unknown version',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}*/
