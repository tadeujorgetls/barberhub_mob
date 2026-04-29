import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/onboarding_provider.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dados de cada etapa do onboarding
// ─────────────────────────────────────────────────────────────────────────────
class _OnboardingStep {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<_OnboardingStep> _steps = [
  _OnboardingStep(
    title: 'Bem-vindo ao\nBarber Hub',
    description:
        'Seu estilo começa aqui. Vamos mostrar tudo o que você pode fazer no app em poucos segundos.',
    icon: Icons.cut_rounded,
  ),
  _OnboardingStep(
    title: 'Encontre Barbearias',
    description:
        'Descubra as melhores barbearias perto de você, veja avaliações e escolha o seu favorito.',
    icon: Icons.storefront_rounded,
  ),
  _OnboardingStep(
    title: 'Seus Agendamentos',
    description:
        'Acompanhe todos os seus horários marcados, reagende ou cancele com facilidade.',
    icon: Icons.calendar_today_rounded,
  ),
  _OnboardingStep(
    title: 'Loja de Produtos',
    description:
        'Compre produtos premium para cuidar do seu visual diretamente pelo app.',
    icon: Icons.shopping_bag_rounded,
  ),
  _OnboardingStep(
    title: 'Seu Perfil',
    description:
        'Gerencie seus dados, histórico e preferências em um só lugar.',
    icon: Icons.person_rounded,
  ),
  _OnboardingStep(
    title: 'Tudo Pronto!',
    description:
        'Agora você conhece o Barber Hub. Agende um horário e cuide do seu estilo.',
    icon: Icons.check_circle_rounded,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Widget principal do overlay
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingOverlay extends StatefulWidget {
  final List<GlobalKey> navKeys;

  const OnboardingOverlay({super.key, required this.navKeys});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _slideCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Rect? _getNavRect(int step) {
    if (step < 1 || step > 4) return null;
    final key = widget.navKeys[step - 1];
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final offset = renderBox.localToGlobal(Offset.zero);
    return offset & renderBox.size;
  }

  Future<void> _animateToNext(OnboardingProvider prov) async {
    await _fadeCtrl.reverse();
    await _slideCtrl.reverse();
    prov.nextStep();
    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) {
      _fadeCtrl.forward();
      _slideCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OnboardingProvider>();
    if (!prov.shouldShow) return const SizedBox.shrink();

    final step = prov.step;
    final navRect = _getNavRect(step);
    final screenSize = MediaQuery.of(context).size;
    final data = _steps[step];

    // Material transparente garante que todos os Text dentro do overlay
    // herdem o DefaultTextStyle correto (sem sublinhado).
    return Material(
      type: MaterialType.transparency,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // ── Fundo escurecido com recorte (spotlight) ──────────────────
            CustomPaint(
              size: screenSize,
              painter: _SpotlightPainter(
                highlightRect: navRect,
                padding: 8,
              ),
            ),

            // ── Toque fora na tela de boas-vindas ─────────────────────────
            if (step == 0)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _animateToNext(prov),
                  behavior: HitTestBehavior.translucent,
                  child: const SizedBox.expand(),
                ),
              ),

            // ── Tooltip card ───────────────────────────────────────────────
            _buildTooltipCard(context, prov, step, data, navRect, screenSize),

            // ── Indicador pulsante no spotlight ───────────────────────────
            if (navRect != null) _buildPulseIndicator(navRect),

            // ── Botão pular ────────────────────────────────────────────────
            if (step < 5)
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 20,
                child: SafeArea(
                  child: TextButton(
                    onPressed: prov.skip,
                    child: Text(
                      'Pular',
                      style: GoogleFonts.jost(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Indicadores de progresso ───────────────────────────────────
            Positioned(
              bottom:
                  _bottomCardOffset(navRect, screenSize) + _cardHeight(step) + 12,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildProgressDots(step),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltipCard(
    BuildContext context,
    OnboardingProvider prov,
    int step,
    _OnboardingStep data,
    Rect? navRect,
    Size screenSize,
  ) {
    final isLast = step == 5;
    final isWelcome = step == 0;
    final bottom = _bottomCardOffset(navRect, screenSize);

    return Positioned(
      bottom: bottom,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.gold.withOpacity(0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppTheme.gold.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ícone + badge de etapa ──────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.gold.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      data.icon,
                      color: isLast ? Colors.greenAccent.shade400 : AppTheme.gold,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  if (!isWelcome && !isLast)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: AppTheme.divider, width: 1),
                      ),
                      child: Text(
                        '$step / 4',
                        style: GoogleFonts.jost(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Título ────────────────────────────────────────────────────
              Text(
                data.title,
                style: GoogleFonts.cormorantGaramond(
                  color: AppTheme.textPrimary,
                  fontSize: isWelcome ? 28 : 22,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.3,
                  decoration: TextDecoration.none,
                ),
              ),

              const SizedBox(height: 8),

              // ── Descrição ─────────────────────────────────────────────────
              Text(
                data.description,
                style: GoogleFonts.jost(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  decoration: TextDecoration.none,
                ),
              ),

              const SizedBox(height: 24),

              // ── Botão de ação ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _animateToNext(prov),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isLast ? Colors.greenAccent.shade700 : AppTheme.gold,
                    foregroundColor: AppTheme.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isWelcome
                        ? 'COMEÇAR TOUR'
                        : isLast
                            ? 'EXPLORAR O APP'
                            : 'PRÓXIMO',
                    style: GoogleFonts.jost(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulseIndicator(Rect rect) {
    final cx = rect.left + rect.width / 2;
    final cy = rect.top + rect.height / 2;
    final radius =
        (rect.width > rect.height ? rect.height : rect.width) / 2 + 8;

    return Positioned(
      left: cx - radius,
      top: cy - radius,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, __) => Transform.scale(
          scale: _pulseAnim.value,
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.gold.withOpacity(0.6),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots(int step) {
    const total = 6;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.gold
                : AppTheme.textHint.withOpacity(0.5),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  double _cardHeight(int step) => step == 0 ? 240 : 220;

  double _bottomCardOffset(Rect? navRect, Size screen) {
    if (navRect == null) {
      return (screen.height - _cardHeight(0)) / 2 - 40;
    }
    return screen.height - navRect.top + 16;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter do spotlight
// ─────────────────────────────────────────────────────────────────────────────
class _SpotlightPainter extends CustomPainter {
  final Rect? highlightRect;
  final double padding;

  const _SpotlightPainter({this.highlightRect, this.padding = 8});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.78);

    if (highlightRect == null) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      return;
    }

    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final spotRect = highlightRect!.inflate(padding);
    final spotPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(spotRect, const Radius.circular(12)),
      );

    final combined =
        Path.combine(PathOperation.difference, fullPath, spotPath);
    canvas.drawPath(combined, paint);

    final borderPaint = Paint()
      ..color = AppTheme.gold.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(spotRect, const Radius.circular(12)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.highlightRect != highlightRect;
}
