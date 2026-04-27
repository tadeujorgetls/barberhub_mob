// Implementação MOBILE (dart.library.io) — Android e iOS.
// Usa webview_flutter — seguro porque este arquivo nunca é compilado na Web.
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/barbershop_model.dart';
import '../theme/app_theme.dart';

/// No mobile, registerMapView não faz nada
/// (HtmlElementView não existe no mobile).
void registerMapView(String viewType, String embedUrl) {
  // Não-op no mobile — a renderização é feita pelo _MobileMapView
}

/// Constrói o WebView nativo com iframe do Google Maps.
Widget buildMobileMapView({
  required BarbershopModel shop,
  required double height,
  required dynamic loadState,
  required void Function(dynamic) onStateChange,
  required VoidCallback onOpenMaps,
  required Widget loadingWidget,
  required Widget offlineWidget,
}) {
  return _MobileWebViewContainer(
    shop: shop,
    height: height,
    onOpenMaps: onOpenMaps,
    loadingWidget: loadingWidget,
    offlineWidget: offlineWidget,
  );
}

// ── Widget interno que gerencia o WebViewController ───────────────────────────
class _MobileWebViewContainer extends StatefulWidget {
  final BarbershopModel shop;
  final double height;
  final VoidCallback onOpenMaps;
  final Widget loadingWidget;
  final Widget offlineWidget;

  const _MobileWebViewContainer({
    required this.shop,
    required this.height,
    required this.onOpenMaps,
    required this.loadingWidget,
    required this.offlineWidget,
  });

  @override
  State<_MobileWebViewContainer> createState() =>
      _MobileWebViewContainerState();
}

enum _State { loading, loaded, offline }

class _MobileWebViewContainerState
    extends State<_MobileWebViewContainer> {
  late final WebViewController _ctrl;
  _State _state = _State.loading;

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1A2235))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _state = _State.loaded);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _state = _State.offline);
          },
          onNavigationRequest: (req) {
            if (!req.url.contains('maps.google.com') &&
                !req.url.contains('about:blank')) {
              widget.onOpenMaps();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_html(widget.shop.location!.embedUrl));
  }

  String _html(String embedUrl) => '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    * { margin:0; padding:0; box-sizing:border-box; }
    html, body { width:100%; height:100%; background:#1A2235; overflow:hidden; }
    iframe {
      width:100%; height:100%; border:none;
      filter: invert(90%) hue-rotate(180deg) saturate(0.85) brightness(0.88);
    }
  </style>
</head>
<body>
  <iframe src="$embedUrl" allowfullscreen="" loading="lazy"
    referrerpolicy="no-referrer-when-downgrade"></iframe>
</body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // WebView
            if (_state != _State.offline)
              WebViewWidget(controller: _ctrl),

            // Loading skeleton
            if (_state == _State.loading)
              widget.loadingWidget,

            // Offline fallback
            if (_state == _State.offline)
              widget.offlineWidget,

            // Borda + botão "Abrir Maps"
            if (_state == _State.loaded) ...[
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.gold.withOpacity(0.18),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                right: 14,
                child: GestureDetector(
                  onTap: widget.onOpenMaps,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.gold,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gold.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_new_rounded,
                            size: 13, color: AppTheme.background),
                        SizedBox(width: 5),
                        Text(
                          'Abrir Maps',
                          style: TextStyle(
                            color: AppTheme.background,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
