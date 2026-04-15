import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_provider.dart';
import '../../models/product_model.dart';
import '../../models/barbershop_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

/// Recebe via arguments:
///   Map{'product': ProductModel, 'barbershop': BarbershopModel}
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final product = args['product'] as ProductModel;
    final barbershop = args['barbershop'] as BarbershopModel;

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
                    'PRODUTO',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.textHint,
                          fontSize: 11,
                          letterSpacing: 3,
                        ),
                  ),
                  const SizedBox(width: 8),
                  // Ícone de carrinho com badge
                  _CartIconButton(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero ─────────────────────────────────────────
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: AppTheme.gold.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: AppTheme.gold.withOpacity(0.2)),
                            ),
                            child: Center(
                              child: Text(product.imageEmoji,
                                  style: const TextStyle(fontSize: 72)),
                            ),
                          ),
                          if (product.hasDiscount)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: _DiscountBadge(
                                  percent: product.discountPercent),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Chips ─────────────────────────────────────────
                    Wrap(
                      spacing: 8,
                      children: [
                        _CategoryChip(category: product.category),
                        if (product.isFeatured) _FeaturedChip(),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Nome ─────────────────────────────────────────
                    Text(product.name,
                        style: Theme.of(context).textTheme.displayMedium),
                    const SizedBox(height: 5),
                    if (product.brand.isNotEmpty)
                      Text(product.brand,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: AppTheme.textHint, fontSize: 13)),
                    const SizedBox(height: 10),
                    const GoldAccent(),
                    const SizedBox(height: 20),

                    // ── Preço ────────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.formattedPrice,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                  color: AppTheme.gold, fontSize: 34),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              product.formattedOriginalPrice!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textHint,
                                    fontSize: 16,
                                    decoration:
                                        TextDecoration.lineThrough,
                                    decorationColor: AppTheme.textHint,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    _StockIndicator(product: product),
                    const SizedBox(height: 28),

                    // ── Descrição ────────────────────────────────────
                    const SectionHeader(title: 'Sobre o produto'),
                    const SizedBox(height: 14),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.7,
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: 28),

                    // ── Barbearia ────────────────────────────────────
                    const SectionHeader(title: 'Disponível em'),
                    const SizedBox(height: 14),
                    _BarbershopInfo(barbershop: barbershop),
                    const SizedBox(height: 36),

                    // ── CTA ──────────────────────────────────────────
                    if (product.inStock)
                      _AddToCartButton(
                          product: product, barbershop: barbershop)
                    else
                      _OutOfStockBanner(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cart icon button com badge ────────────────────────────────────────────────
class _CartIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.inputBorder),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: AppTheme.textSecondary, size: 18),
          ),
          if (cart.itemCount > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.gold,
                ),
                child: Center(
                  child: Text(
                    '${cart.itemCount > 9 ? '9+' : cart.itemCount}',
                    style: const TextStyle(
                      color: AppTheme.background,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
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

// ── Discount badge ────────────────────────────────────────────────────────────
class _DiscountBadge extends StatelessWidget {
  final int percent;
  const _DiscountBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.error,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '-$percent%',
        style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Add to cart button (stateful: mostra feedback) ────────────────────────────
class _AddToCartButton extends StatefulWidget {
  final ProductModel product;
  final BarbershopModel barbershop;
  const _AddToCartButton(
      {required this.product, required this.barbershop});

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  bool _added = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnim = Tween<double>(begin: 1, end: 0.95).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    final cart = context.read<CartProvider>();
    final alreadyIn = cart.contains(widget.product.id);

    // Animação de press
    await _ctrl.forward();
    await _ctrl.reverse();

    final added =
        cart.addItem(widget.product, widget.barbershop);

    if (!mounted) return;

    if (!added && cart.pendingConflict != null) {
      // Conflito de barbearia → mostra diálogo
      _showConflictDialog(context, cart);
      return;
    }

    // Feedback de sucesso
    setState(() => _added = true);
    if (alreadyIn) {
      // Já estava no carrinho — navega direto
      Navigator.pushNamed(context, AppRoutes.cart);
    } else {
      // Novo item — mostra snackbar e opção de ir ao carrinho
      _showAddedSnack(context);
      // Volta ao estado normal após 2s
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _added = false);
    }
  }

  void _showConflictDialog(BuildContext context, CartProvider cart) {
    final conflict = cart.pendingConflict!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        title: Text('Carrinho de outra barbearia',
            style: Theme.of(context).textTheme.titleLarge),
        content: Text(
          'Você tem itens de "${cart.barbershop?.name}" no carrinho.\n\nDeseja descartá-los e começar um novo carrinho com "${conflict.shop.name}"?',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              cart.cancelConflict();
              Navigator.pop(context);
            },
            child: const Text('Manter atual'),
          ),
          TextButton(
            onPressed: () {
              cart.confirmConflictSwitch();
              Navigator.pop(context);
              if (mounted) {
                setState(() => _added = true);
                _showAddedSnack(context);
                Future.delayed(const Duration(seconds: 2),
                    () { if (mounted) setState(() => _added = false); });
              }
            },
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.error),
            child: const Text('Descartar e trocar'),
          ),
        ],
      ),
    );
  }

  void _showAddedSnack(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: AppTheme.gold, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.product.name} adicionado!',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Ver carrinho',
          textColor: AppTheme.gold,
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.cart),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty = cart.quantityOf(widget.product.id);
    final inCart = qty > 0;

    return Column(
      children: [
        // Contador de quantidade (visível quando já há no carrinho)
        if (inCart) ...[
          _QuantityRow(
            product: widget.product,
            quantity: qty,
            onIncrement: () =>
                cart.incrementItem(widget.product.id),
            onDecrement: () =>
                cart.decrementItem(widget.product.id),
          ),
          const SizedBox(height: 14),
        ],

        // Botão principal
        ScaleTransition(
          scale: _scaleAnim,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _handleAdd,
              icon: Icon(
                inCart
                    ? Icons.shopping_bag_rounded
                    : Icons.add_shopping_cart_rounded,
                size: 18,
              ),
              label: Text(
                inCart
                    ? 'IR AO CARRINHO ($qty)'
                    : 'ADICIONAR AO CARRINHO',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Quantity row ──────────────────────────────────────────────────────────────
class _QuantityRow extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityRow({
    required this.product,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined,
              size: 16, color: AppTheme.gold),
          const SizedBox(width: 10),
          Text(
            'No carrinho',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
          ),
          const Spacer(),
          _QtyButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$quantity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    color: AppTheme.gold,
                  ),
            ),
          ),
          _QtyButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppTheme.gold.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 16, color: AppTheme.gold),
      ),
    );
  }
}

// ── Subwidgets de info ────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final ProductCategory category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(category.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _FeaturedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.gold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 12, color: AppTheme.gold),
          const SizedBox(width: 4),
          Text('Destaque',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StockIndicator extends StatelessWidget {
  final ProductModel product;
  const _StockIndicator({required this.product});

  @override
  Widget build(BuildContext context) {
    final inStock = product.inStock;
    final low = product.stockQty <= 5 && inStock;
    final color = !inStock
        ? AppTheme.error
        : low
            ? const Color(0xFFF5A623)
            : const Color(0xFF4CAF50);
    final label = !inStock
        ? 'Sem estoque'
        : low
            ? 'Últimas ${product.stockQty} unidades'
            : 'Em estoque';
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 13, color: color)),
      ],
    );
  }
}

class _BarbershopInfo extends StatelessWidget {
  final BarbershopModel barbershop;
  const _BarbershopInfo({required this.barbershop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Row(
        children: [
          Text(barbershop.coverEmoji,
              style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(barbershop.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 15)),
                const SizedBox(height: 3),
                Text(barbershop.address,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutOfStockBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined,
              color: AppTheme.error, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Produto temporariamente indisponível. Consulte a barbearia para novas reposições.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    height: 1.5,
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
