import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_service.dart';
import 'weather_provider.dart';

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

class GithubRepoNotifier extends Notifier<String> {
  @override
  String build() {
    final cache = ref.watch(cacheServiceProvider);
    return cache.getGithubRepo();
  }

  Future<void> setRepo(String repo) async {
    state = repo.trim();
    await ref.read(cacheServiceProvider).setGithubRepo(state);
    ref.invalidate(appUpdateProvider);
  }
}

final githubRepoProvider = NotifierProvider<GithubRepoNotifier, String>(GithubRepoNotifier.new);

class AppUpdateNotifier extends AsyncNotifier<AppUpdateInfo> {
  @override
  Future<AppUpdateInfo> build() async {
    final repo = ref.watch(githubRepoProvider);
    final service = ref.watch(updateServiceProvider);

    if (repo.isEmpty) {
      return AppUpdateInfo.noUpdate('1.0.0');
    }

    final parts = repo.split('/');
    if (parts.length != 2) {
      return AppUpdateInfo.noUpdate('1.0.0');
    }

    return await service.checkForUpdate(
      repoOwner: parts[0].trim(),
      repoName: parts[1].trim(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(githubRepoProvider);
      final service = ref.read(updateServiceProvider);
      final parts = repo.split('/');
      if (parts.length != 2) return AppUpdateInfo.noUpdate('1.0.0');
      return await service.checkForUpdate(
        repoOwner: parts[0].trim(),
        repoName: parts[1].trim(),
      );
    });
  }

  Future<bool> launchDownload(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}

final appUpdateProvider = AsyncNotifierProvider<AppUpdateNotifier, AppUpdateInfo>(AppUpdateNotifier.new);
