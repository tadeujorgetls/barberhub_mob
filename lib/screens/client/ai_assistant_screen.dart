import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/app_data_provider.dart';
import '../../models/barbershop_model.dart';
import '../../models/service_model.dart';
import '../../core/routes/app_routes.dart';
import '../../theme/app_theme.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  _AssistantIntent _lastIntent = _AssistantIntent.none;
  bool _isTyping = false;
  bool _isSendActive = false;

  final List<_ChatMessage> _messages = [
    const _ChatMessage.assistant(
      _AssistantReply(
        text:
            'Olá! Sou o assistente do Barber Hub. Posso recomendar serviços, barbearias, barbeiros e produtos — ou te ajudar a iniciar um agendamento. O que você procura?',
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final active = _controller.text.trim().isNotEmpty;
      if (active != _isSendActive) setState(() => _isSendActive = active);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(AppDataProvider data, [String? shortcut]) async {
    if (_isTyping) return;
    final text = (shortcut ?? _controller.text).trim();
    if (text.isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage.user(text));
      _isTyping = true;
    });
    _scrollToBottom();

    final reply = _answerFor(text, data);
    await Future.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage.assistant(reply));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  _AssistantReply _answerFor(String rawText, AppDataProvider data) {
    final text = _normalize(rawText);
    final shops = data.barbershops;
    final openShops = shops.where((s) => s.isOpen).toList();
    final allServices = shops.expand((s) => s.services).toList();
    final allBarbers = shops.expand((s) => s.barbers).toList();
    final allProducts = shops.expand((s) => s.products).toList();

    if (_hasAny(text, [
      'tchau',
      'ate logo',
      'ate mais',
      'bye',
      'valeu',
      'obrigado',
      'obrigada'
    ])) {
      return _reply(
        _AssistantIntent.none,
        text: _hasAny(text, ['obrigado', 'obrigada', 'valeu'])
            ? 'Fico feliz em ajudar! Se precisar de mais alguma coisa, é só chamar.'
            : 'Até logo! Qualquer dúvida, estou aqui.',
      );
    }

    if (_hasAny(
        text, ['oi', 'ola', 'bom dia', 'boa tarde', 'boa noite', 'hey', 'eai', 'e ai'])) {
      return _reply(
        _AssistantIntent.none,
        text:
            'Olá! Me diga o que você procura. Posso ajudar com corte, barba, degradê, produto, barbearia aberta, preço ou assinatura.',
      );
    }

    if (_hasAny(text, [
      'mais barato',
      'barato',
      'economizar',
      'menor preco',
      'em conta',
      'acessivel',
      'custo baixo',
    ])) {
      final scoped = _servicesForLastIntent(allServices);
      final ranked =
          List<ServiceModel>.from(scoped.isEmpty ? allServices : scoped)
            ..sort((a, b) => a.price.compareTo(b.price));
      return _serviceReply(
        ranked,
        shops,
        _lastIntent,
        intro: _lastIntent == _AssistantIntent.none
            ? 'Separei as opções mais baratas disponíveis:'
            : 'Dentro do que você estava procurando, estas são as mais baratas:',
        fallback: 'Não encontrei serviços para comparar preços agora.',
      );
    }

    if (_hasAny(text, [
      'rapido',
      'rapida',
      'sem demora',
      'pouco tempo',
      'intervalo',
      'correndo',
      'express',
      'urgente',
    ])) {
      final ranked = List<ServiceModel>.from(allServices)
        ..sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
      return _serviceReply(
        ranked,
        shops,
        _AssistantIntent.quick,
        intro: 'Para resolver rápido, os serviços de menor duração:',
        fallback: 'Não encontrei serviços rápidos cadastrados.',
      );
    }

    if (_hasAny(text, [
      'completo',
      'pacote',
      'combo',
      'caprichado',
      'dia de trato',
      'tudo junto',
      'kit',
    ])) {
      final matches = _servicesContaining(
          allServices, ['combo', 'corte + barba', 'barba', 'completo']);
      return _serviceReply(
        matches,
        shops,
        _AssistantIntent.complete,
        intro: 'Para um atendimento completo, estas opções fazem mais sentido:',
        fallback:
            'Para um pacote completo, procure Corte + Barba ou serviços combinados.',
      );
    }

    if (_hasAny(text, [
      'entrevista',
      'reuniao',
      'formal',
      'social',
      'arrumado',
      'alinhado',
      'casamento',
      'formatura',
      'evento',
    ])) {
      final matches =
          _servicesContaining(allServices, ['classico', 'corte', 'barba']);
      return _serviceReply(
        matches,
        shops,
        _AssistantIntent.interview,
        intro: 'Para entrevista ou evento formal, algo limpo e alinhado:',
        fallback:
            'Para ocasiões formais, recomendo um corte clássico ou corte + barba.',
      );
    }

    if (_hasAny(text, [
      'aberta',
      'aberto',
      'funcionando',
      'atende agora',
      'aberta agora',
      'disponivel',
    ])) {
      if (openShops.isEmpty) {
        return _reply(_AssistantIntent.shop,
            text: 'No momento não encontrei barbearias abertas no app.');
      }
      return _reply(
        _AssistantIntent.shop,
        text: 'Barbearias abertas agora:',
        shops: openShops.take(3).toList(),
      );
    }

    if (_hasAny(text, [
      'melhor',
      'avaliada',
      'avaliacao',
      'top',
      'recomenda barbearia',
      'mais bem avaliada',
      'destaque',
    ])) {
      final ranked = List<BarbershopModel>.from(shops)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      return _reply(
        _AssistantIntent.shop,
        text: 'Melhores barbearias pelas avaliações:',
        shops: ranked.take(3).toList(),
      );
    }

    if (_hasAny(text, [
      'barba',
      'bigode',
      'barba alinhada',
      'navalha',
      'apara barba',
      'fazer barba',
    ])) {
      final matches =
          _servicesContaining(allServices, ['barba', 'bigode', 'navalha']);
      return _serviceReply(
        matches,
        shops,
        _AssistantIntent.beard,
        intro: 'Para barba, estas opções combinam melhor:',
        fallback:
            'Para barba, procure Barba Completa, Barba Estilizada ou Corte + Barba.',
      );
    }

    if (_hasAny(text, [
      'degrade',
      'moderno',
      'visual',
      'mudar visual',
      'tapa no visual',
      'dar um trato',
      'novo visual',
      'estilo',
    ])) {
      final matches =
          _servicesContaining(allServices, ['degrade', 'moderno', 'corte']);
      return _serviceReply(
        matches,
        shops,
        _AssistantIntent.style,
        intro: 'Para renovar o visual, estas opções são boas pedidas:',
        fallback:
            'Para mudar o visual, recomendo Degradê, Corte Moderno ou Corte + Barba.',
      );
    }

    if (_hasAny(text, [
      'corte',
      'cabelo',
      'cortar',
      'aparar',
      'cabelo curto',
      'franja',
    ])) {
      final matches = _servicesContaining(allServices, ['corte', 'degrade']);
      return _serviceReply(
        matches,
        shops,
        _AssistantIntent.haircut,
        intro: 'Para corte de cabelo, estes serviços são bons começos:',
        fallback:
            'Para corte de cabelo, comece por Corte Clássico, Corte Moderno ou Degradê.',
      );
    }

    if (_hasAny(
        text, ['preco', 'valor', 'quanto custa', 'quanto e', 'quanto fica', 'tabela'])) {
      final scoped = _servicesForLastIntent(allServices);
      final ranked =
          List<ServiceModel>.from(scoped.isEmpty ? allServices : scoped)
            ..sort((a, b) => a.price.compareTo(b.price));
      return _serviceReply(
        ranked,
        shops,
        _lastIntent,
        intro: _lastIntent == _AssistantIntent.none
            ? 'Serviços disponíveis por preço:'
            : 'Com base na sua busca, estes são os valores:',
        fallback: 'Não encontrei serviços cadastrados para comparar preços.',
      );
    }

    if (_hasAny(
        text, ['barbeiro', 'profissional', 'quem atende', 'especialista', 'equipe'])) {
      final ranked = allBarbers.where((b) => b.isActive).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
      if (ranked.isEmpty) {
        return _reply(_AssistantIntent.barber,
            text: 'Não encontrei barbeiros ativos no momento.');
      }
      return _reply(
        _AssistantIntent.barber,
        text:
            'Barbeiros em destaque:\n\n${ranked.take(5).map((b) => '• ${b.name} — ${b.specialty}, ★ ${b.rating.toStringAsFixed(1)}').join('\n')}',
      );
    }

    if (_hasAny(text, [
      'crianca',
      'filho',
      'infantil',
      'menino',
      'kid',
      'bebe',
    ])) {
      final matches = _servicesContaining(
          allServices, ['infantil', 'crianca', 'junior', 'kids']);
      return _serviceReply(
        matches,
        shops,
        _AssistantIntent.haircut,
        intro: 'Serviços para crianças disponíveis:',
        fallback:
            'Para crianças, verifique nas barbearias se há serviço infantil disponível.',
      );
    }

    if (_hasAny(text, [
      'endereco',
      'onde fica',
      'localizacao',
      'como chegar',
      'perto',
      'proximo',
      'bairro',
    ])) {
      final ranked = List<BarbershopModel>.from(shops)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      return _reply(
        _AssistantIntent.shop,
        text: 'Barbearias com endereço:',
        shops: ranked.take(3).toList(),
      );
    }

    if (_hasAny(text, [
      'horario',
      'que horas',
      'abre',
      'fecha',
      'funciona',
      'expediente',
      'domingo',
      'sabado',
    ])) {
      if (openShops.isNotEmpty) {
        return _reply(
          _AssistantIntent.shop,
          text:
              'Estas barbearias estão abertas agora. Acesse cada uma para ver o horário completo:',
          shops: openShops.take(3).toList(),
        );
      }
      final ranked = List<BarbershopModel>.from(shops)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      return _reply(
        _AssistantIntent.shop,
        text: 'Para ver o horário de funcionamento, selecione uma barbearia:',
        shops: ranked.take(3).toList(),
      );
    }

    if (_hasAny(
        text, ['pagamento', 'pagar', 'pix', 'cartao', 'dinheiro', 'parcel'])) {
      return _reply(
        _AssistantIntent.none,
        text:
            'As formas de pagamento variam por barbearia. Acesse a página de cada barbearia para ver as opções disponíveis.',
      );
    }

    if (_hasAny(text, [
      'produto',
      'pomada',
      'shampoo',
      'comprar',
      'loja',
      'presente',
      'pai',
      'condicionador',
      'cera',
      'gel',
    ])) {
      final available = allProducts.where((p) => p.isAvailable).toList();
      if (available.isEmpty) {
        return _reply(_AssistantIntent.product,
            text: 'Não encontrei produtos disponíveis no momento.');
      }
      final intro = _hasAny(text, ['presente', 'pai'])
          ? 'Para presente, estes produtos são ótimas opções:'
          : 'Produtos que podem combinar com você:';
      return _reply(
        _AssistantIntent.product,
        text: intro,
        products: available.take(4).toList(),
        productShops: shops,
      );
    }

    if (_hasAny(text, [
      'assinatura',
      'plano',
      'mensal',
      'vip',
      'premium',
      'fidelidade',
      'clube',
    ])) {
      return _reply(
        _AssistantIntent.membership,
        text:
            'O app tem uma área de Assinatura. Se você corta cabelo com frequência, um plano mensal pode compensar bastante — acesso prioritário e preços especiais.',
        actionLabel: 'Ver assinatura',
        onAction: (context, data) => Navigator.pop(context),
      );
    }

    if (_hasAny(text, [
      'agenda',
      'agendar',
      'marcar',
      'reservar',
      'quero cortar',
      'quero fazer',
    ])) {
      final suggestion =
          openShops.isNotEmpty ? openShops.first : (shops.isNotEmpty ? shops.first : null);
      if (suggestion == null) {
        return _reply(_AssistantIntent.booking,
            text:
                'Não encontrei barbearias cadastradas para iniciar um agendamento.');
      }
      return _reply(
        _AssistantIntent.booking,
        text:
            'Ótimo! Comece por esta barbearia e toque em "Agendar" no serviço desejado:',
        shops: [suggestion],
      );
    }

    if (_hasAny(text, ['cancelar', 'remarcar', 'desmarcar', 'alterar agendamento'])) {
      return _reply(
        _AssistantIntent.none,
        text:
            'Para cancelar ou remarcar, vá em "Meus Agendamentos" no menu principal e selecione o agendamento desejado.',
      );
    }

    if (_hasAny(
        text, ['nao sei', 'duvida', 'me ajuda', 'indica algo', 'recomenda algo', 'o que voce faz'])) {
      return _reply(
        _AssistantIntent.none,
        text:
            'Claro! Para eu recomendar melhor, me diga se você quer algo:\n\n• Rápido ou mais barato\n• Completo (combo)\n• Para barba ou para mudar o visual\n• Para uma entrevista ou evento\n• Um produto para comprar',
      );
    }

    return _reply(
      _AssistantIntent.none,
      text:
          'Ainda estou aprendendo sobre esse pedido. Tente perguntar sobre: corte, barba, degradê, preço, barbearia aberta, barbeiro, produto, assinatura ou agendamento.',
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
    String intro = 'Com base nos serviços cadastrados, eu recomendo:',
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
      terms.any((t) => text.contains(_normalize(t)));

  String _normalize(String value) => value
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

  List<ServiceModel> _servicesContaining(
    List<ServiceModel> services,
    List<String> terms,
  ) {
    return services.where((s) {
      final hay = _normalize('${s.name} ${s.description}');
      return terms.any((t) => hay.contains(_normalize(t)));
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
            _buildHeader(context),
            _buildChips(data),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return const _TypingIndicator();
                  }
                  return _Bubble(
                    message: _messages[index],
                    data: data,
                  );
                },
              ),
            ),
            _InputBar(
              controller: _controller,
              isSendActive: _isSendActive,
              isTyping: _isTyping,
              onSend: () => _send(data),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppTheme.textPrimary,
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppTheme.gold,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: AppTheme.background, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Barber IA',
                style: GoogleFonts.jost(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Online',
                    style: GoogleFonts.jost(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChips(AppDataProvider data) {
    return SizedBox(
      height: 42,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _PromptChip(
            label: 'Entrevista',
            icon: Icons.work_outline_rounded,
            onTap: () => _send(data, 'Tenho uma entrevista amanhã'),
          ),
          _PromptChip(
            label: 'Rápido',
            icon: Icons.bolt_rounded,
            onTap: () => _send(data, 'Quero algo rápido'),
          ),
          _PromptChip(
            label: 'Barato',
            icon: Icons.savings_outlined,
            onTap: () => _send(data, 'Me indica algo barato'),
          ),
          _PromptChip(
            label: 'Completo',
            icon: Icons.spa_outlined,
            onTap: () => _send(data, 'Quero um pacote completo'),
          ),
          _PromptChip(
            label: 'Produtos',
            icon: Icons.shopping_bag_outlined,
            onTap: () => _send(data, 'Me recomenda produtos'),
          ),
          _PromptChip(
            label: 'Aberta agora',
            icon: Icons.store_outlined,
            onTap: () => _send(data, 'Barbearia aberta agora'),
          ),
          _PromptChip(
            label: 'Melhor nota',
            icon: Icons.star_outline_rounded,
            onTap: () => _send(data, 'Qual a melhor barbearia'),
          ),
        ],
      ),
    );
  }
}

// ─── Enums & Data ────────────────────────────────────────────────────────────

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

// ─── Typing Indicator ─────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _animations = _controllers
        .map((c) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AssistantAvatar(size: 28),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.inputBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => AnimatedBuilder(
                  animation: _animations[i],
                  builder: (_, __) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppTheme.gold
                          .withValues(alpha: 0.35 + _animations[i].value * 0.65),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _Bubble extends StatefulWidget {
  final _ChatMessage message;
  final AppDataProvider data;

  const _Bubble({required this.message, required this.data});

  @override
  State<_Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<_Bubble> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _opacity = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(widget.message.isUser ? 0.12 : -0.12, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isUser = widget.message.isUser;
    final reply = widget.message.reply;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(
            color: AppTheme.gold,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(2),
            ),
          ),
          child: Text(
            widget.message.text ?? '',
            style: GoogleFonts.jost(
              color: AppTheme.background,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AssistantAvatar(size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(color: AppTheme.inputBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reply?.text ?? '',
                    style: GoogleFonts.jost(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  if (reply != null) ...[
                    if (reply.shops.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...reply.shops
                          .map((s) => _ShopSuggestion(shop: s)),
                    ],
                    if (reply.services.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...reply.services.map(
                        (s) => _ServiceSuggestion(
                          service: s,
                          shop: _shopForService(reply.serviceShops, s),
                        ),
                      ),
                    ],
                    if (reply.products.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...reply.products.map(
                        (p) => _ProductSuggestion(
                          product: p,
                          shop: _shopForProduct(reply.productShops, p),
                        ),
                      ),
                    ],
                    if (reply.actionLabel != null && reply.onAction != null) ...[
                      const SizedBox(height: 12),
                      _AssistantButton(
                        icon: Icons.arrow_forward_rounded,
                        label: reply.actionLabel!,
                        onTap: () =>
                            reply.onAction!(context, widget.data),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarbershopModel? _shopForService(
      List<BarbershopModel> shops, ServiceModel service) {
    for (final s in shops) {
      if (s.services.any((i) => i.id == service.id)) return s;
    }
    return null;
  }

  BarbershopModel? _shopForProduct(
      List<BarbershopModel> shops, ProductModel product) {
    for (final s in shops) {
      if (s.products.any((i) => i.id == product.id)) return s;
    }
    return null;
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _AssistantAvatar extends StatelessWidget {
  final double size;
  const _AssistantAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(
        color: AppTheme.gold,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.auto_awesome_rounded,
          color: AppTheme.background, size: size * 0.5),
    );
  }
}

// ─── Prompt Chips ─────────────────────────────────────────────────────────────

class _PromptChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PromptChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: onTap,
        label: Text(label),
        avatar: Icon(icon, size: 15),
        backgroundColor: AppTheme.surfaceElevated,
        side: const BorderSide(color: AppTheme.inputBorder),
        labelStyle:
            GoogleFonts.jost(color: AppTheme.textPrimary, fontSize: 12),
        iconTheme: const IconThemeData(color: AppTheme.gold),
      ),
    );
  }
}

// ─── Suggestion Cards ─────────────────────────────────────────────────────────

class _ShopSuggestion extends StatelessWidget {
  final BarbershopModel shop;
  const _ShopSuggestion({required this.shop});

  @override
  Widget build(BuildContext context) {
    return _SuggestionCard(
      icon: Icons.storefront_rounded,
      title: shop.name,
      subtitle:
          '${shop.address}\n★ ${shop.rating.toStringAsFixed(1)} (${shop.reviewCount} avaliações)',
      trailing: shop.isOpen
          ? const _StatusBadge(label: 'Aberta', color: Color(0xFF4CAF50))
          : const _StatusBadge(label: 'Fechada', color: Colors.redAccent),
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
          '${service.formattedPrice} · ${service.formattedDuration}${shop == null ? '' : '\n${shop!.name}'}',
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
          '${product.formattedPrice} · ${product.category.label}${shop == null ? '' : '\n${shop!.name}'}',
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

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.jost(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget? trailing;

  const _SuggestionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actions,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
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
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.jost(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
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

// ─── Buttons ──────────────────────────────────────────────────────────────────

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
      icon: Icon(icon, size: 14),
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

// ─── Input Bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSendActive;
  final bool isTyping;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isSendActive,
    required this.isTyping,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
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
              enabled: !isTyping,
              style: GoogleFonts.jost(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: isTyping
                    ? 'Aguarde...'
                    : 'Pergunte sobre serviços, horários, produtos...',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedOpacity(
            opacity: isSendActive && !isTyping ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: 46,
              height: 46,
              child: ElevatedButton(
                onPressed: isSendActive && !isTyping ? onSend : null,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                child: const Icon(Icons.send_rounded, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
