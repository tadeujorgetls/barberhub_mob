// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/barbershop_model.dart';
import '../theme/app_theme.dart';

// Importação condicional: Web carrega map_widgets_web.dart (com dart:html),
// Mobile/IO carrega map_widgets_stub.dart (com webview_flutter).
// O arquivo principal (este) não importa nenhum dos dois diretamente,
// garantindo que webview_flutter NUNCA seja compilado na Web.
// ignore: uri_does_not_exist
import 'map_widgets_web.dart' if (dart.library.io) 'map_widgets_stub.dart'
    as platform;

// ─────────────────────────────────────────────────────────────────────────────
// MapLauncher — abre Google Maps externo via url_launcher (sem API key)
// ─────────────────────────────────────────────────────────────────────────────
class MapLauncher {
  MapLauncher._();

  static Future<void> openMap(
    BuildContext context,
    BarbershopModel shop,
  ) async {
    if (!shop.hasLocation) return;
    final loc = shop.location!;

    // Tenta geo: URI primeiro — abre o app de mapas nativo no mobile
    final geoUri = Uri.parse(loc.geoUri(shop.name));
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
      return;
    }

    // Fallback: link público do Google Maps no navegador
    final webUri = Uri.parse(loc.mapUrl);
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa.')),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EmbeddedMapView — detecta plataforma em runtime e delega
//   • Web    → _WebMapView  (HtmlElementView com <iframe>)
//   • Mobile → _MobileMapView (WebViewController do webview_flutter)
//   • Fallback → _OfflineFallback (sempre funciona)
// ─────────────────────────────────────────────────────────────────────────────
class EmbeddedMapView extends StatelessWidget {
  final BarbershopModel shop;
  final double height;

  const EmbeddedMapView({
    super.key,
    required this.shop,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    if (!shop.hasLocation) {
      return _OfflineFallback(shop: shop, height: height);
    }

    if (kIsWeb) {
      return _WebMapView(shop: shop, height: height);
    }

    return _MobileMapView(shop: shop, height: height);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WebMapView — Flutter Web: usa HtmlElementView com <iframe> nativo.
// Registra o viewType uma única vez via ui.platformViewRegistry.
// Sem necessidade de webview_flutter — usa apenas HTML/CSS do navegador.
// ─────────────────────────────────────────────────────────────────────────────
class _WebMapView extends StatefulWidget {
  final BarbershopModel shop;
  final double height;
  const _WebMapView({required this.shop, required this.height});

  @override
  State<_WebMapView> createState() => _WebMapViewState();
}

class _WebMapViewState extends State<_WebMapView> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    final loc = widget.shop.location!;
    // viewType único por barbearia para evitar conflito entre instâncias
    _viewType = 'barber-map-${widget.shop.id}';

    // Registra o iframe via platform view do Flutter Web
    platform.registerMapView(_viewType, loc.embedUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // iframe nativo do navegador
            HtmlElementView(viewType: _viewType),

            // Borda dourada sutil sobre o iframe
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.gold.withOpacity(0.20),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Botão "Abrir Maps" flutuante
            Positioned(
              bottom: 14,
              right: 14,
              child: _OpenMapsButton(
                onTap: () => MapLauncher.openMap(context, widget.shop),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MobileMapView — Android/iOS: usa webview_flutter com WebViewController.
// Só é instanciado quando kIsWeb == false, logo o import condicional
// do webview_flutter no arquivo separado não é carregado na Web.
// ─────────────────────────────────────────────────────────────────────────────
class _MobileMapView extends StatefulWidget {
  final BarbershopModel shop;
  final double height;
  const _MobileMapView({required this.shop, required this.height});

  @override
  State<_MobileMapView> createState() => _MobileMapViewState();
}

class _MobileMapViewState extends State<_MobileMapView> {
  _MapLoadState _state = _MapLoadState.loading;

  @override
  Widget build(BuildContext context) {
    // Delega para o stub de plataforma (mobile_map_view.dart ou stub)
    return platform.buildMobileMapView(
      shop: widget.shop,
      height: widget.height,
      loadState: _state,
      onStateChange: (s) {
        if (mounted) setState(() => _state = s);
      },
      onOpenMaps: () => MapLauncher.openMap(context, widget.shop),
      loadingWidget: _LoadingSkeleton(height: widget.height),
      offlineWidget: _OfflineFallback(shop: widget.shop, height: widget.height),
    );
  }
}

enum _MapLoadState { loading, loaded, offline }

// ─────────────────────────────────────────────────────────────────────────────
// LocationSection — seção completa de localização
// ─────────────────────────────────────────────────────────────────────────────
class LocationSection extends StatelessWidget {
  final BarbershopModel shop;

  const LocationSection({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    if (!shop.hasLocation) return const SizedBox.shrink();
    final loc = shop.location!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Mapa embutido (Web ou Mobile) ──────────────────────────────
        EmbeddedMapView(shop: shop, height: 220),
        const SizedBox(height: 14),

        // ── Card de endereço ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.inputBorder),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on_rounded,
                        color: AppTheme.gold, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          shop.address,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    height: 1.4,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${loc.neighborhood} · Goiânia, GO',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                    color: AppTheme.textHint,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: AppTheme.divider),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.my_location_rounded,
                      size: 14, color: AppTheme.textHint),
                  const SizedBox(width: 8),
                  Text(
                    '${loc.latitude.toStringAsFixed(5)}, '
                    '${loc.longitude.toStringAsFixed(5)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppTheme.textHint,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Botão "Abrir no Google Maps" ───────────────────────────────
        MapLinkButton(shop: shop),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MapLinkButton — compacto (cards da lista) ou full-width (detalhe)
// ─────────────────────────────────────────────────────────────────────────────
class MapLinkButton extends StatelessWidget {
  final BarbershopModel shop;
  final bool compact;

  const MapLinkButton({super.key, required this.shop, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (!shop.hasLocation) return const SizedBox.shrink();

    if (compact) {
      return GestureDetector(
        onTap: () => MapLauncher.openMap(context, shop),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.gold.withOpacity(0.10),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.gold.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map_outlined, size: 12, color: AppTheme.gold),
              const SizedBox(width: 4),
              Text(
                'Ver no mapa',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => MapLauncher.openMap(context, shop),
        icon: const Icon(Icons.map_outlined, size: 16),
        label: const Text('Abrir no Google Maps'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.gold,
          side: BorderSide(color: AppTheme.gold.withOpacity(0.4)),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NeighborhoodBadge — chip de bairro para cards da lista
// ─────────────────────────────────────────────────────────────────────────────
class NeighborhoodBadge extends StatelessWidget {
  final BarbershopLocation location;

  const NeighborhoodBadge({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppTheme.gold.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.place_outlined, size: 10, color: AppTheme.gold),
          const SizedBox(width: 3),
          Text(
            location.neighborhood,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppTheme.gold, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OpenMapsButton — botão flutuante "Abrir Maps"
// ─────────────────────────────────────────────────────────────────────────────
class _OpenMapsButton extends StatelessWidget {
  final VoidCallback onTap;
  const _OpenMapsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LoadingSkeleton — skeleton animado enquanto o mapa carrega
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingSkeleton extends StatefulWidget {
  final double height;
  const _LoadingSkeleton({required this.height});

  @override
  State<_LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<_LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        height: widget.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Container(
                color: const Color(0xFF1A2235),
                child: Opacity(
                  opacity: _anim.value,
                  child: CustomPaint(
                    size: Size(double.infinity, widget.height),
                    painter: _MapGridPainter(),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppTheme.gold.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Carregando mapa...',
                      style: TextStyle(color: AppTheme.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OfflineFallback — fallback visual quando offline ou sem localização
// ─────────────────────────────────────────────────────────────────────────────
class _OfflineFallback extends StatelessWidget {
  final BarbershopModel shop;
  final double height;
  const _OfflineFallback({required this.shop, required this.height});

  @override
  Widget build(BuildContext context) {
    final loc = shop.location;
    return GestureDetector(
      onTap: () => MapLauncher.openMap(context, shop),
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Container(
                color: const Color(0xFF1A2235),
                child: CustomPaint(
                  size: Size(double.infinity, height),
                  painter: _MapGridPainter(),
                ),
              ),
              // Pin com emoji
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.gold,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withOpacity(0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(shop.coverEmoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 6,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              // Badge de bairro
              if (loc != null)
                Positioned(
                  top: 12,
                  left: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 12, color: AppTheme.gold),
                        const SizedBox(width: 4),
                        Text(
                          loc.neighborhood,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              // Coordenadas
              if (loc != null)
                Positioned(
                  bottom: 12,
                  left: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${loc.latitude.toStringAsFixed(4)}, '
                      '${loc.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              // Botão abrir Maps
              Positioned(
                bottom: 12,
                right: 14,
                child: _OpenMapsButton(
                    onTap: () => MapLauncher.openMap(context, shop)),
              ),
              // Decoração da borda
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.gold.withOpacity(0.18), width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MapGridPainter — grade de ruas estilizada, puro Flutter, sem API key
// ─────────────────────────────────────────────────────────────────────────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFF1A2235));

    final thin = Paint()
      ..color = const Color(0xFF2A3550)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final thick = Paint()
      ..color = const Color(0xFF334060)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    for (double y = 0; y <= size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), thin);
    }
    for (double x = 0; x <= size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), thin);
    }
    for (final y in [size.height * 0.28, size.height * 0.62]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), thick);
    }
    for (final x in [size.width * 0.22, size.width * 0.58, size.width * 0.82]) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), thick);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.62, size.height * 0.1, size.width * 0.14,
            size.height * 0.38),
        const Radius.circular(4),
      ),
      Paint()
        ..color = const Color(0xFF1E3A2F)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.32, size.width * 0.14,
            size.height * 0.26),
        const Radius.circular(3),
      ),
      Paint()
        ..color = const Color(0xFF232C42)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
