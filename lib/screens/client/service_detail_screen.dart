import 'package:flutter/material.dart';
import '../../models/barbershop_model.dart';
import '../../models/service_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

/// Aceita dois formatos de arguments:
///   1) Map{'service': ServiceModel, 'barbershop': BarbershopModel}  ← novo
///   2) ServiceModel direto                                           ← legado
class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    final ServiceModel service;
    final BarbershopModel? barbershop;

    if (args is Map) {
      service = args['service'] as ServiceModel;
      barbershop = args['barbershop'] as BarbershopModel?;
    } else {
      service = args as ServiceModel;
      barbershop = null;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'SERVIÇO',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.textHint,
                          fontSize: 11,
                          letterSpacing: 3,
                        ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero icon ───────────────────────────────────
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: AppTheme.gold.withOpacity(0.25)),
                        ),
                        child: Icon(
                          ServiceCard.iconFor(service.iconName),
                          color: AppTheme.gold,
                          size: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Barbershop badge ──────────────────────────────
                    if (barbershop != null) ...[
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppTheme.gold.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.storefront_outlined,
                                  size: 13, color: AppTheme.gold),
                              const SizedBox(width: 6),
                              Text(
                                barbershop.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppTheme.gold,
                                      fontSize: 11,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_left_rounded,
                                  size: 13, color: AppTheme.gold),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Service name ──────────────────────────────────
                    Text(service.name,
                        style: Theme.of(context).textTheme.displayMedium),
                    const SizedBox(height: 8),
                    const GoldAccent(),
                    const SizedBox(height: 20),

                    // ── Pills ─────────────────────────────────────────
                    Row(
                      children: [
                        _InfoPill(
                            icon: Icons.attach_money_rounded,
                            label: service.formattedPrice),
                        const SizedBox(width: 12),
                        _InfoPill(
                            icon: Icons.schedule_outlined,
                            label: service.formattedDuration),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Description ───────────────────────────────────
                    const SectionHeader(title: 'Sobre o serviço'),
                    const SizedBox(height: 16),
                    Text(
                      service.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.7,
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: 32),

                    // ── Includes ──────────────────────────────────────
                    const SectionHeader(title: 'Inclui'),
                    const SizedBox(height: 16),
                    ..._includedItems(service).map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.gold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── CTA ───────────────────────────────────────────
                    PrimaryButton(
                      label: 'Agendar agora',
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.booking,
                        arguments: {
                          'service': service,
                          'barbershop': barbershop,
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _includedItems(ServiceModel service) {
    switch (service.iconName) {
      case 'face':
        return [
          'Toalha quente',
          'Navalha profissional',
          'Balm hidratante pós-barba',
          'Modelagem personalizada',
        ];
      case 'combo':
        return [
          'Lavagem com shampoo premium',
          'Corte personalizado',
          'Toalha quente + navalha',
          'Finalização completa',
        ];
      case 'color':
        return [
          'Consulta de cor',
          'Produtos profissionais',
          'Proteção capilar',
          'Finalização e hidratação',
        ];
      case 'spa':
        return [
          'Máscara nutritiva',
          'Vitaminas e óleos essenciais',
          'Massagem capilar',
          'Finalização com protetor térmico',
        ];
      case 'brow':
        return [
          'Design com linha e pinça',
          'Alinhamento preciso',
          'Hidratação pós-design',
        ];
      default:
        return [
          'Lavagem com shampoo premium',
          'Corte personalizado',
          'Finalização com produtos profissionais',
          'Secagem',
        ];
    }
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTheme.gold),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 14, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
