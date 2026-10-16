import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateInfo {
  final bool hasUpdate;
  final String currentVersion;
  final String latestVersion;
  final String releaseNotes;
  final String downloadUrl;
  final DateTime? publishedAt;

  const AppUpdateInfo({
    required this.hasUpdate,
    required this.currentVersion,
    required this.latestVersion,
    this.releaseNotes = '',
    this.downloadUrl = '',
    this.publishedAt,
  });

  factory AppUpdateInfo.noUpdate(String currentVersion) {
    return AppUpdateInfo(
      hasUpdate: false,
      currentVersion: currentVersion,
      latestVersion: currentVersion,
    );
  }
}

class UpdateService {
  final http.Client _client;

  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  /// Compares two semver strings like "1.0.1" and "1.0.0".
  /// Returns 1 if v1 > v2, -1 if v1 < v2, 0 if equal.
  static int compareVersions(String v1, String v2) {
    final clean1 = v1.replaceAll(RegExp(r'[^0-9.]'), '').split('.');
    final clean2 = v2.replaceAll(RegExp(r'[^0-9.]'), '').split('.');

    final maxLen = clean1.length > clean2.length ? clean1.length : clean2.length;
    for (int i = 0; i < maxLen; i++) {
      final p1 = i < clean1.length ? int.tryParse(clean1[i]) ?? 0 : 0;
      final p2 = i < clean2.length ? int.tryParse(clean2[i]) ?? 0 : 0;
      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }
    return 0;
  }

  /// Checks GitHub Releases API for updates.
  Future<AppUpdateInfo> checkForUpdate({
    required String repoOwner,
    required String repoName,
  }) async {
    String currentVersion = '1.0.0';
    try {
      final info = await PackageInfo.fromPlatform();
      currentVersion = info.version;
    } catch (_) {
      // Fallback if platform channels not available in tests
    }

    if (repoOwner.isEmpty || repoName.isEmpty || repoOwner.contains('YOUR_GITHUB')) {
      return AppUpdateInfo.noUpdate(currentVersion);
    }

    final url = Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest');

    try {
      final response = await _client.get(
        url,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'WeatherMb-UpdateChecker',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return AppUpdateInfo.noUpdate(currentVersion);
      }

      final dynamic data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        return AppUpdateInfo.noUpdate(currentVersion);
      }

      final tagName = (data['tag_name'] as String? ?? '').trim();
      final latestVersion = tagName.replaceFirst(RegExp(r'^[vV]'), '');
      final releaseNotes = data['body'] as String? ?? '';
      final releaseHtmlUrl = data['html_url'] as String? ?? '';
      final publishedAtStr = data['published_at'] as String?;
      final publishedAt = publishedAtStr != null ? DateTime.tryParse(publishedAtStr) : null;

      // Look for .apk file in assets
      String apkDownloadUrl = '';
      if (data['assets'] is List) {
        for (final asset in data['assets'] as List) {
          if (asset is Map<String, dynamic>) {
            final name = (asset['name'] as String? ?? '').toLowerCase();
            if (name.endsWith('.apk')) {
              apkDownloadUrl = asset['browser_download_url'] as String? ?? '';
              break;
            }
          }
        }
      }

      // If no direct APK asset found, link to release page
      if (apkDownloadUrl.isEmpty) {
        apkDownloadUrl = releaseHtmlUrl;
      }

      final hasUpdate = compareVersions(latestVersion, currentVersion) > 0;

      return AppUpdateInfo(
        hasUpdate: hasUpdate,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        releaseNotes: releaseNotes,
        downloadUrl: apkDownloadUrl,
        publishedAt: publishedAt,
      );
    } catch (_) {
      return AppUpdateInfo.noUpdate(currentVersion);
    }
  }
}
