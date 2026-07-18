import 'package:url_launcher/url_launcher.dart';

abstract interface class ExternalLinkLauncher {
  Future<bool> open(Uri uri);
}

class UrlLauncherExternalLinkLauncher implements ExternalLinkLauncher {
  const UrlLauncherExternalLinkLauncher();

  @override
  Future<bool> open(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
