import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_hub/core/utils/app_router.dart';

/// Listens for incoming deep links (e.g. Firebase password-reset emails)
/// and navigates to the correct screen.
///
/// Migrated from `uni_links` → `app_links` (the official successor).
/// API differences:
///   uni_links:  getInitialUri()     (top-level fn)  / uriLinkStream  (global)
///   app_links:  AppLinks().getInitialLink()          / AppLinks().uriLinkStream
///
/// The stream in app_links emits non-nullable Uri values, so the null-guard
/// inside the listener has been removed.
class DeepLinkListener extends StatefulWidget {
  final Widget child;

  const DeepLinkListener({
    super.key,
    required this.child,
  });

  @override
  State<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends State<DeepLinkListener> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Handle the link that cold-started the app.
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (_) {}

    // Handle links received while the app is already running.
    _sub = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
  }

  void _handleUri(Uri uri) {
    final mode = uri.queryParameters['mode'];
    final oobCode = uri.queryParameters['oobCode'];
    if (mode == 'resetPassword' && oobCode != null && mounted) {
      GoRouter.of(context).go(AppRouter.kReset, extra: oobCode);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
