class AppRoutes {
  AppRoutes._();

  static const String login          = '/login';
  static const String register       = '/register';
  static const String forgotPassword = '/forgot-password';

  // ── Cliente ───────────────────────────────────────────────────────────────
  static const String home             = '/home';
  static const String barbershopDetail = '/barbershop-detail';
  static const String serviceDetail    = '/service-detail';
  static const String booking          = '/booking';
  static const String productDetail    = '/product-detail';
  static const String cart             = '/cart';
  static const String review           = '/review';

  // ── Barbearia (proprietário) — CORRIGIDO: ausente após conflito de merge
  static const String barberShopHome   = '/barber-shop-home';

  // ── Legado ────────────────────────────────────────────────────────────────
  static const String barberHome = '/barber-home';
  static const String adminHome  = '/admin-home';
}
