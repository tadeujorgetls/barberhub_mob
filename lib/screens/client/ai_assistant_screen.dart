import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/app_data_provider.dart';
import '../../models/barbershop_model.dart';
import '../../models/product_model.dart';
import '../../models/service_model.dart';
import '../../core/routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  _AssistantIntent _lastIntent = _AssistantIntent.none;

  final List<_ChatMessage> _messages = [
    const _ChatMessage.assistant(
      _AssistantReply(
        text:
            'Oi, eu sou o assistente do Barber Hub. Posso recomendar servicos, barbearias, barbeiros, produtos e te ajudar a iniciar um agendamento.',
      ),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(AppDataProvider data, [String? shortcut]) {
    final text = (shortcut ?? _controller.text).trim();
    if (text.isEmpty) return;

    final reply = _answerFor(text, data);
    setState(() {
      _messages.add(_ChatMessage.user(text));
      _messages.add(_ChatMessage.assistant(reply));
    });
    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  _AssistantReply _answerFor(String rawText, AppDataProvider data) {
    final text = _normalize(rawText);
    final shops = data.barbershops;
    final openShops = shops.where((shop) => shop.isOpen).toList();
    final allServices = shops.expand((shop) => shop.services).toList();
    final allBarbers = shops.expand((shop) => shop.barbers).toList();
    final allProducts = shops.expand((shop) => shop.products).toList();

    if (_hasAny(text, ['oi', 'ola', 'bom dia', 'boa tarde', 'boa noite'])) {
      return _reply(
        _AssistantIntent.none,
        text:
            'Oi! Me diga o que voce procura. Posso ajudar com corte, barba, degrade, produto, barbearia aberta, preco ou assinatura.',
      );
    }

    if (_hasAny(text, ['mais barato', 'barato', 'economizar', 'menor preco'])) {
      final scoped = _servicesForLastIntent(allServices);
      final ranked =
          List<ServiceModel>.from(scoped.isEmpty ? allServices : scoped)
            ..sort((a, b) => a.price.compareTo(b.price));
      return _serviceReply(
        ranked,
        shops,
        _lastIntent,
        intro: _lastIntent == _AssistantIntent.none
            ? 'Separei as opcoes mais baratas nos dados atuais:'
            : 'Dentro do que voce estava procurando, estas sao as opcoes mais baratas:',
        fallback: 'Nao encontrei servicos para comparar preco agora.',
      );
    }

    if (_hasAny(
        text, ['rapido', 'rapida', 'sem demora', 'pouco tempo', 'intervalo'])) {
      final ranked = List<ServiceModel>.from(allServices)
        ..sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
      return _serviceReply(
        ranked,
        shops,
        _AssistantIntent.quick,
        intro: 'Para resolver rapido, eu recomendo servicos de menor duracao:',
        fallback: 'Nao encontrei servicos rapidos cadastrados.',
      );
    }

    if (_hasAny(
        text, ['completo', 'pacote', 'combo', 'caprichado', 'dia de trato'])) {
      final matches = _servicesContaining(
          allServices, ['combo', 'corte + barba', 'barba', 'completo']);
      return _serviceReply(
        matches,
        shops,
        _AssistantIntent.complete,
        intro: 'Para um atendimento mais completo, estas opcoes fazem sentido:',
        fallback:
            'Para um pacote completo, procure Corte + Barba ou servicos combinados.',
      );
    }

    if (_hasAny(text, [
      'entrevista',
      'reuniao',
      'formal',
      'social',
      'arrumado',
      'alinhado'
    ])) {
      final matches =
          _servicesContaining(allServices, ['classico', 'corte', 'barba']);
      return _serviceReply(
        matches,
        shops,
        _AssistantIntent.interview,
        intro:
            'Para entrevista ou situacao formal, eu iria em algo limpo e alinhado:',
        fallback:
            'Para entrevista, eu recomendo um corte classico ou corte + barba para um visual mais alinhado.',
      );
    }

    if (_hasAny(text, ['aberta', 'aberto', 'funcionando', 'atende agora'])) {
      if (openShops.isEmpty) {
        return _reply(
          _AssistantIntent.shop,
          text: 'No momento nao encontrei barbearias abertas nos dados do app.',
        );
      }
      return _reply(
        _AssistantIntent.shop,
        text:
            'Encontrei barbearias abertas agora. Voce pode abrir uma delas para ver servicos e produtos.',
        shops: openShops.take(3).toList(),
      );
    }

    if (_hasAny(text,
        ['melhor', 'avaliada', 'avaliacao', 'top', 'recomenda barbearia'])) {
      final ranked = List<BarbershopModel>.from(shops)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      return _reply(
        _AssistantIntent.shop,
        text: 'Pelas avaliacoes, eu olharia primeiro estas barbearias:',
        shops: ranked.take(3).toList(),
      );
    }

    if (_hasAny(text, ['barba', 'bigode', 'barba alinhada', 'navalha'])) {
      final matches =
          _servicesContaining(allServices, ['barba', 'bigode', 'navalha']);
      return _serviceReply(
        matches,
        shops,
        _AssistantIntent.beard,
        intro: 'Para barba, estas opcoes combinam melhor:',
        fallback:
            'Para barba, procure servicos como Barba Completa, Barba Estilizada ou Corte + Barba.',
      );
    }

    if (_hasAny(text, [
      'degrade',
      'moderno',
      'visual',
      'mudar visual',
      'tapa no visual',
      'dar um trato'
    ])) {
      final matches =
          _servicesContaining(allServices, ['degrade', 'moderno', 'corte']);
      return _serviceReply(
        matches,
        shops,
        _AssistantIntent.style,
        intro: 'Para mudar o visual, eu iria por estas opcoes:',
        fallback:
            'Para mudar o visual, eu recomendo Degrade, Corte Moderno ou Corte + Barba.',
      );
    }

    if (_hasAny(text, ['corte', 'cabelo', 'cortar', 'aparar'])) {
      final matches = _servicesContaining(allServices, ['corte', 'degrade']);
      return _serviceReply(
        matches,
        shops,
        _AssistantIntent.haircut,
        intro: 'Para corte de cabelo, estas opcoes sao bons comecos:',
        fallback:
            'Para corte de cabelo, comece por Corte Classico, Corte Moderno ou Degrade.',
      );
    }

    if (_hasAny(text, ['preco', 'valor', 'quanto custa'])) {
      final scoped = _servicesForLastIntent(allServices);
      final ranked =
          List<ServiceModel>.from(scoped.isEmpty ? allServices : scoped)
            ..sort((a, b) => a.price.compareTo(b.price));
      return _serviceReply(
        ranked,
        shops,
        _lastIntent,
        intro: _lastIntent == _AssistantIntent.none
            ? 'Alguns servicos com menor preco nos dados atuais:'
            : 'Sobre a ultima recomendacao, estes sao os valores mais interessantes:',
        fallback: 'Nao encontrei servicos cadastrados para comparar precos.',
      );
    }

    if (_hasAny(text, ['barbeiro', 'profissional', 'quem atende'])) {
      final ranked = allBarbers.where((barber) => barber.isActive).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
      if (ranked.isEmpty) {
        return _reply(
          _AssistantIntent.barber,
          text: 'Nao encontrei barbeiros ativos nos dados atuais.',
        );
      }
      return _reply(
        _AssistantIntent.barber,
        text:
            'Barbeiros em destaque:\n\n${ranked.take(5).map((b) => '- ${b.name}: ${b.specialty}, nota ${b.rating.toStringAsFixed(1)}').join('\n')}',
      );
    }

    if (_hasAny(text, [
      'produto',
      'pomada',
      'shampoo',
      'comprar',
      'loja',
      'presente',
      'pai'
    ])) {
      final available =
          allProducts.where((product) => product.isAvailable).toList();
      if (available.isEmpty) {
        return _reply(
          _AssistantIntent.product,
          text: 'Nao encontrei produtos disponiveis nos dados atuais.',
        );
      }
      final intro = _hasAny(text, ['presente', 'pai'])
          ? 'Para presente, eu olharia estes produtos primeiro:'
          : 'Produtos que podem combinar com voce:';
      return _reply(
        _AssistantIntent.product,
        text: intro,
        products: available.take(4).toList(),
        productShops: shops,
      );
    }

    if (_hasAny(text, ['assinatura', 'plano', 'mensal', 'vip', 'premium'])) {
      return _reply(
        _AssistantIntent.membership,
        text:
            'O app ja tem uma area de Assinatura. Se voce corta cabelo com frequencia, um plano mensal pode compensar.',
        actionLabel: 'Ver assinatura',
        onAction: (context, data) => Navigator.pop(context),
      );
    }

    if (_hasAny(text, ['agenda', 'agendar', 'marcar', 'horario'])) {
      final suggestion = openShops.isNotEmpty
          ? openShops.first
          : (shops.isNotEmpty ? shops.first : null);
      if (suggestion == null) {
        return _reply(
          _AssistantIntent.booking,
          text:
              'Ainda nao encontrei barbearias cadastradas para iniciar um agendamento.',
        );
      }
      return _reply(
        _AssistantIntent.booking,
        text:
            'Posso te ajudar a escolher. Comece por esta barbearia e toque em Agendar em um servico.',
        shops: [suggestion],
      );
    }

    if (_hasAny(text,
        ['nao sei', 'duvida', 'me ajuda', 'indica algo', 'recomenda algo'])) {
      return _reply(
        _AssistantIntent.none,
        text:
            'Claro. Para eu recomendar melhor, me diga se voce quer algo rapido, barato, completo, para entrevista, para barba ou para mudar o visual.',
      );
    }

    return _reply(
      _AssistantIntent.none,
      text:
          'Ainda estou aprendendo sobre esse pedido. Tente perguntar por corte, barba, degrade, preco, barbearia aberta, barbeiro, produto ou assinatura.',
    );
  }

  _AssistantReply _reply(
    _AssistantIntent intent, {
    required String text,
    List<BarbershopModel> shops = const [],
    List<ServiceModel> services = const [],
    List<BarbershopModel> serviceShops = const [],
    List<ProductModel> products = const [],
    List<BarbershopModel> productShops = const [],
    String? actionLabel,
    _AssistantAction? onAction,
  }) {
    _lastIntent = intent;
    return _AssistantReply(
      text: text,
      shops: shops,
      services: services,
      serviceShops: serviceShops,
      products: products,
      productShops: productShops,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  _AssistantReply _serviceReply(
    List<ServiceModel> services,
    List<BarbershopModel> shops,
    _AssistantIntent intent, {
    String intro = 'Com base nos servicos cadastrados, eu recomendo:',
    required String fallback,
  }) {
    if (services.isEmpty) return _reply(intent, text: fallback);
    return _reply(
      intent,
      text: intro,
      services: services.take(4).toList(),
      serviceShops: shops,
    );
  }

  List<ServiceModel> _servicesForLastIntent(List<ServiceModel> services) {
    switch (_lastIntent) {
      case _AssistantIntent.beard:
        return _servicesContaining(services, ['barba', 'bigode', 'navalha']);
      case _AssistantIntent.haircut:
        return _servicesContaining(services, ['corte', 'degrade']);
      case _AssistantIntent.style:
        return _servicesContaining(services, ['degrade', 'moderno', 'corte']);
      case _AssistantIntent.complete:
        return _servicesContaining(
            services, ['combo', 'corte + barba', 'barba']);
      case _AssistantIntent.interview:
        return _servicesContaining(services, ['classico', 'corte', 'barba']);
      case _AssistantIntent.quick:
        return List<ServiceModel>.from(services)
          ..sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
      default:
        return const [];
    }
  }

  bool _hasAny(String text, List<String> terms) =>
      terms.any((term) => text.contains(_normalize(term)));

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }

  List<ServiceModel> _servicesContaining(
    List<ServiceModel> services,
    List<String> terms,
  ) {
    return services.where((service) {
      final haystack = _normalize('${service.name} ${service.description}');
      return terms.any((term) => haystack.contains(_normalize(term)));
    }).toList()
      ..sort((a, b) => a.price.compareTo(b.price));
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppTheme.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: ScreenHeader(
                      eyebrow: 'ASSISTENTE',
                      title: 'Barber IA',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: [
                  _PromptChip(
                      label: 'Entrevista',
                      onTap: () => _send(data, 'Tenho uma entrevista amanha')),
                  _PromptChip(
                      label: 'Rapido',
                      onTap: () => _send(data, 'Quero algo rapido')),
                  _PromptChip(
                      label: 'Barato',
                      onTap: () => _send(data, 'Me indica algo barato')),
                  _PromptChip(
                      label: 'Completo',
                      onTap: () => _send(data, 'Quero um pacote completo')),
                  _PromptChip(
                      label: 'Produtos',
                      onTap: () => _send(data, 'Me recomenda produtos')),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _Bubble(
                  message: _messages[index],
                  data: data,
                ),
              ),
            ),
            _InputBar(
              controller: _controller,
              onSend: () => _send(data),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AssistantIntent {
  none,
  shop,
  barber,
  beard,
  haircut,
  style,
  complete,
  interview,
  quick,
  product,
  membership,
  booking,
}

typedef _AssistantAction = void Function(
    BuildContext context, AppDataProvider data);

class _AssistantReply {
  final String text;
  final List<BarbershopModel> shops;
  final List<ServiceModel> services;
  final List<BarbershopModel> serviceShops;
  final List<ProductModel> products;
  final List<BarbershopModel> productShops;
  final String? actionLabel;
  final _AssistantAction? onAction;

  const _AssistantReply({
    required this.text,
    this.shops = const [],
    this.services = const [],
    this.serviceShops = const [],
    this.products = const [],
    this.productShops = const [],
    this.actionLabel,
    this.onAction,
  });
}

class _ChatMessage {
  final bool isUser;
  final String? text;
  final _AssistantReply? reply;

  const _ChatMessage.user(this.text)
      : isUser = true,
        reply = null;

  const _ChatMessage.assistant(this.reply)
      : isUser = false,
        text = null;
}

class _PromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PromptChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: onTap,
        label: Text(label),
        avatar: const Icon(Icons.auto_awesome_rounded, size: 16),
        backgroundColor: AppTheme.surfaceElevated,
        side: const BorderSide(color: AppTheme.inputBorder),
        labelStyle: GoogleFonts.jost(color: AppTheme.textPrimary, fontSize: 12),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _ChatMessage message;
  final AppDataProvider data;

  const _Bubble({required this.message, required this.data});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final reply = message.reply;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.78 : 0.9),
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.gold : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isUser ? AppTheme.gold : AppTheme.inputBorder,
          ),
        ),
        child: isUser
            ? Text(
                message.text ?? '',
                style: GoogleFonts.jost(
                  color: AppTheme.background,
                  fontSize: 14,
                  height: 1.35,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reply?.text ?? '',
                    style: GoogleFonts.jost(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  if (reply != null) ...[
                    if (reply.shops.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...reply.shops.map((shop) => _ShopSuggestion(shop: shop)),
                    ],
                    if (reply.services.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...reply.services.map(
                        (service) => _ServiceSuggestion(
                          service: service,
                          shop: _shopForService(reply.serviceShops, service),
                        ),
                      ),
                    ],
                    if (reply.products.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...reply.products.map(
                        (product) => _ProductSuggestion(
                          product: product,
                          shop: _shopForProduct(reply.productShops, product),
                        ),
                      ),
                    ],
                    if (reply.actionLabel != null &&
                        reply.onAction != null) ...[
                      const SizedBox(height: 12),
                      _AssistantButton(
                        icon: Icons.arrow_forward_rounded,
                        label: reply.actionLabel!,
                        onTap: () => reply.onAction!(context, data),
                      ),
                    ],
                  ],
                ],
              ),
      ),
    );
  }

  BarbershopModel? _shopForService(
    List<BarbershopModel> shops,
    ServiceModel service,
  ) {
    for (final shop in shops) {
      if (shop.services.any((item) => item.id == service.id)) return shop;
    }
    return null;
  }

  BarbershopModel? _shopForProduct(
    List<BarbershopModel> shops,
    ProductModel product,
  ) {
    for (final shop in shops) {
      if (shop.products.any((item) => item.id == product.id)) return shop;
    }
    return null;
  }
}

class _ShopSuggestion extends StatelessWidget {
  final BarbershopModel shop;

  const _ShopSuggestion({required this.shop});

  @override
  Widget build(BuildContext context) {
    return _SuggestionCard(
      icon: Icons.storefront_rounded,
      title: shop.name,
      subtitle:
          '${shop.address}\nNota ${shop.rating.toStringAsFixed(1)} (${shop.reviewCount} avaliacoes)',
      actions: [
        _AssistantButton(
          icon: Icons.visibility_outlined,
          label: 'Ver barbearia',
          onTap: () {
            context.read<AppDataProvider>().selectBarbershop(shop);
            Navigator.pushNamed(
              context,
              AppRoutes.barbershopDetail,
              arguments: shop,
            );
          },
        ),
      ],
    );
  }
}

class _ServiceSuggestion extends StatelessWidget {
  final ServiceModel service;
  final BarbershopModel? shop;

  const _ServiceSuggestion({required this.service, required this.shop});

  @override
  Widget build(BuildContext context) {
    return _SuggestionCard(
      icon: Icons.content_cut_rounded,
      title: service.name,
      subtitle:
          '${service.formattedPrice} - ${service.formattedDuration}${shop == null ? '' : '\n${shop!.name}'}',
      actions: [
        if (shop != null)
          _AssistantButton(
            icon: Icons.calendar_month_outlined,
            label: 'Agendar',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.booking,
              arguments: {'service': service, 'barbershop': shop},
            ),
          ),
        if (shop != null)
          _AssistantButton(
            icon: Icons.storefront_outlined,
            label: 'Ver loja',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.barbershopDetail,
              arguments: shop,
            ),
          ),
      ],
    );
  }
}

class _ProductSuggestion extends StatelessWidget {
  final ProductModel product;
  final BarbershopModel? shop;

  const _ProductSuggestion({required this.product, required this.shop});

  @override
  Widget build(BuildContext context) {
    return _SuggestionCard(
      icon: product.category.iconData,
      title: product.name,
      subtitle:
          '${product.formattedPrice} - ${product.category.label}${shop == null ? '' : '\n${shop!.name}'}',
      actions: [
        if (shop != null)
          _AssistantButton(
            icon: Icons.shopping_bag_outlined,
            label: 'Ver produto',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.productDetail,
              arguments: {'product': product, 'barbershop': shop},
            ),
          ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const _SuggestionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.gold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.jost(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.jost(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      ),
    );
  }
}

class _AssistantButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AssistantButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.gold,
        side: const BorderSide(color: AppTheme.gold),
        visualDensity: VisualDensity.compact,
        textStyle: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: GoogleFonts.jost(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Pergunte sobre servicos, horarios, produtos...',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 46,
            height: 46,
            child: ElevatedButton(
              onPressed: onSend,
              style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
              child: const Icon(Icons.send_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
