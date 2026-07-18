import 'package:package_info_plus/package_info_plus.dart';

abstract interface class AppVersionService {
  Future<String> loadVersionLabel();
}

class PackageInfoAppVersionService implements AppVersionService {
  PackageInfoAppVersionService({
    Future<PackageInfo> Function()? packageInfoProvider,
  }) : _packageInfoProvider = packageInfoProvider ?? PackageInfo.fromPlatform;

  final Future<PackageInfo> Function() _packageInfoProvider;

  @override
  Future<String> loadVersionLabel() async {
    final packageInfo = await _packageInfoProvider();
    final buildNumber = packageInfo.buildNumber.trim();
    if (buildNumber.isEmpty) {
      return packageInfo.version;
    }
    return '${packageInfo.version}+$buildNumber';
  }
}
