import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_hub/core/theme/app_theme.dart';
import 'package:barber_hub/features/auth/presentation/providers/auth_providers.dart';
import 'package:barber_hub/features/barber_shop/domain/entities/product_order_entity.dart';
import 'package:barber_hub/features/barber_shop/presentation/providers/shop_management_providers.dart';
import 'package:barber_hub/features/barber_shop/presentation/widgets/bs_widgets.dart';
import 'package:barber_hub/features/client/data/models/product_model.dart';

class BarberShopProductsScreen extends ConsumerStatefulWidget {
  const BarberShopProductsScreen({super.key});
  @override
  ConsumerState<BarberShopProductsScreen> createState() => _State();
}

class _State extends ConsumerState<BarberShopProductsScreen> {
  ProductCategory? _filter;
  int _view = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopManagementProvider);
    final all = state.products;
    final orders = state.productOrders;
    final products = _filter == null
        ? all
        : all.where((p) => p.category == _filter).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
              child: Column(children: [
            BsScreenHeader(
              eyebrow: 'gestao',
              title: _view == 0 ? 'Produtos' : 'Pedidos',
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text('${all.length} itens',
                      style: GoogleFonts.jost(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _ViewSwitcher(
                selected: _view,
                onChanged: (value) => setState(() => _view = value),
              ),
            ),
            const SizedBox(height: 16),
            if (_view == 0) ...[
              // Filtro por categoria
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _FilterChip(
                        label: 'Todos',
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null)),
                    ...ProductCategory.values.map((c) => _FilterChip(
                          label: c.label,
                          icon: c.iconData,
                          selected: _filter == c,
                          onTap: () =>
                              setState(() => _filter = _filter == c ? null : c),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ])),
          if (_view == 1)
            _OrdersSliver(orders: orders)
          else if (products.isEmpty)
            SliverFillRemaining(
                child: BsEmptyState(
              icon: Icons.inventory_2_outlined,
              message: 'Nenhum produto encontrado.',
              actionLabel: all.isEmpty ? 'Adicionar produto' : null,
              onAction:
                  all.isEmpty ? () => _showProductModal(context, ref) : null,
            ))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProductTile(
                    product: products[i],
                    onEdit: () =>
                        _showProductModal(context, ref, product: products[i]),
                    onDelete: () => _confirmDelete(context, ref, products[i]),
                  ),
                ),
                childCount: products.length,
              )),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]),
      ),
      floatingActionButton: BsGoldFab(
        onPressed: () => _showProductModal(context, ref),
        tooltip: 'Adicionar produto',
      ),
    );
  }

  void _showProductModal(BuildContext context, WidgetRef ref,
      {ProductModel? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _ProductModal(product: product, ref: ref),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, ProductModel p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Remover produto',
            style: Theme.of(context).textTheme.titleLarge),
        content: Text('Tem certeza que deseja remover "${p.name}"?',
            style: GoogleFonts.jost(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                Text('Remover', style: GoogleFonts.jost(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(shopManagementProvider.notifier).deleteProduct(p.id);
    }
  }
}

class _ViewSwitcher extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _ViewSwitcher({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Row(children: [
        _SwitchButton(
          label: 'Produtos',
          icon: Icons.inventory_2_outlined,
          selected: selected == 0,
          onTap: () => onChanged(0),
        ),
        _SwitchButton(
          label: 'Pedidos',
          icon: Icons.receipt_long_outlined,
          selected: selected == 1,
          onTap: () => onChanged(1),
        ),
      ]),
    );
  }
}

class _SwitchButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SwitchButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppTheme.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                size: 14,
                color: selected ? AppTheme.background : AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.jost(
                color: selected ? AppTheme.background : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _OrdersSliver extends ConsumerWidget {
  final List<ProductOrderEntity> orders;

  const _OrdersSliver({required this.orders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return const SliverFillRemaining(
        child: BsEmptyState(
          icon: Icons.receipt_long_outlined,
          message: 'Nenhum pedido de produto encontrado.',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OrderTile(order: orders[i]),
          ),
          childCount: orders.length,
        ),
      ),
    );
  }
}

class _OrderTile extends ConsumerWidget {
  final ProductOrderEntity order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _statusColor(order.status);
    final createdAt = _formatDateTime(order.createdAt);

    return BsCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.receipt_long_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('#${order.orderNumber}',
                  style: GoogleFonts.jost(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(order.clientName,
                  style: GoogleFonts.jost(
                      color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 2),
              Text(createdAt,
                  style:
                      GoogleFonts.jost(color: AppTheme.textHint, fontSize: 11)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _StatusChip(label: order.statusLabel, color: color),
            const SizedBox(height: 8),
            Text(order.formattedTotal,
                style: GoogleFonts.jost(
                    color: AppTheme.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
          ]),
        ]),
        const SizedBox(height: 14),
        Container(height: 1, color: AppTheme.divider),
        const SizedBox(height: 12),
        ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(
                  child: Text('${item.quantity}x ${item.productName}',
                      style: GoogleFonts.jost(
                          color: AppTheme.textPrimary, fontSize: 13)),
                ),
                Text(item.formattedSubtotal,
                    style: GoogleFonts.jost(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ]),
            )),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.payments_outlined,
              color: AppTheme.textHint, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(order.paymentLabel,
                style:
                    GoogleFonts.jost(color: AppTheme.textHint, fontSize: 11)),
          ),
        ]),
        if (order.canMarkReady || order.canComplete || order.canCancel) ...[
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (order.canMarkReady)
              _OrderActionButton(
                label: 'Pronto',
                icon: Icons.done_rounded,
                onTap: () => _updateStatus(context, ref, 'ready'),
              ),
            if (order.canComplete)
              _OrderActionButton(
                label: 'Entregar',
                icon: Icons.shopping_bag_outlined,
                onTap: () => _updateStatus(context, ref, 'completed'),
              ),
            if (order.canCancel)
              _OrderActionButton(
                label: 'Cancelar',
                icon: Icons.close_rounded,
                danger: true,
                onTap: () => _updateStatus(context, ref, 'cancelled'),
              ),
          ]),
        ],
      ]),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String status,
  ) async {
    try {
      await ref
          .read(shopManagementProvider.notifier)
          .updateProductOrderStatus(order.id, status);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido atualizado.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.error,
          content: Text('Nao foi possivel atualizar o pedido.'),
        ),
      );
    }
  }

  Color _statusColor(String status) => switch (status) {
        'ready' => Colors.blueAccent,
        'completed' => const Color(0xFF2ECC71),
        'cancelled' => AppTheme.error,
        _ => Colors.orangeAccent,
      };

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} as ${two(local.hour)}:${two(local.minute)}';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label,
          style: GoogleFonts.jost(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _OrderActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool danger;
  final VoidCallback onTap;

  const _OrderActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppTheme.error : AppTheme.gold;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.jost(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

// Filter Chip
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.gold.withValues(alpha: 0.12)
                : AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? AppTheme.gold : AppTheme.inputBorder,
                width: selected ? 1.5 : 1),
          ),
          child: Text(label,
              style: GoogleFonts.jost(
                  color: selected ? AppTheme.gold : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
        ),
      );
}

// Product Tile
class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit, onDelete;
  const _ProductTile(
      {required this.product, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => BsCard(
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
            ),
            child: Center(
                child: Icon(product.iconData, color: AppTheme.gold, size: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(product.name,
                    style: GoogleFonts.jost(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(product.category.label,
                    style: GoogleFonts.jost(
                        color: AppTheme.textSecondary, fontSize: 11)),
                const SizedBox(height: 6),
                Row(children: [
                  Text('R\$ ${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.jost(
                          color: AppTheme.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: product.stockQty > 0
                          ? AppTheme.surface
                          : AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: product.stockQty > 0
                              ? AppTheme.divider
                              : AppTheme.error.withValues(alpha: 0.4)),
                    ),
                    child: Text('Estoque: ${product.stockQty}',
                        style: GoogleFonts.jost(
                            color: product.stockQty > 0
                                ? AppTheme.textSecondary
                                : AppTheme.error,
                            fontSize: 10)),
                  ),
                ]),
              ])),
          Column(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
                icon: const Icon(Icons.edit_rounded,
                    size: 18, color: AppTheme.textSecondary),
                onPressed: onEdit),
            IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppTheme.error),
                onPressed: onDelete),
          ]),
        ]),
      );
}

// Product Modal
class _ProductModal extends ConsumerStatefulWidget {
  final ProductModel? product;
  final WidgetRef ref;
  const _ProductModal({this.product, required this.ref});

  @override
  ConsumerState<_ProductModal> createState() => _ProductModalState();
}

class _ProductModalState extends ConsumerState<_ProductModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  ProductCategory _category = ProductCategory.pomade;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description;
      _priceCtrl.text = p.price.toStringAsFixed(2);
      _stockCtrl.text = p.stockQty.toString();
      _brandCtrl.text = p.brand;
      _category = p.category;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _descCtrl,
      _priceCtrl,
      _stockCtrl,
      _brandCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final notifier = ref.read(shopManagementProvider.notifier);
    final authState = ref.read(authNotifierProvider);
    final shopId =
        authState is AuthAuthenticated ? authState.user.linkedId ?? '' : '';

    final price = double.tryParse(_priceCtrl.text.replaceAll(',', '.')) ?? 0;
    final stock = int.tryParse(_stockCtrl.text) ?? 0;

    try {
      if (_isEditing) {
        await notifier.updateProduct(ProductModel(
          id: widget.product!.id,
          barbershopId: shopId,
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          price: price,
          category: _category,
          imageEmoji: _category.iconKey,
          brand: _brandCtrl.text.trim(),
          stockQty: stock,
          isFeatured: widget.product!.isFeatured,
        ));
      } else {
        await notifier.addProduct(ProductModel(
          id: _uuidV4(),
          barbershopId: shopId,
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          price: price,
          category: _category,
          imageEmoji: _category.iconKey,
          brand: _brandCtrl.text.trim(),
          stockQty: stock,
        ));
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isSubmitting = false;
      });
    }
  }

  String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hex(int value) => value.toRadixString(16).padLeft(2, '0');
    final buffer = StringBuffer();
    for (var i = 0; i < bytes.length; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) buffer.write('-');
      buffer.write(hex(bytes[i]));
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BsModalSheet(
      title: _isEditing ? 'Editar produto' : 'Novo produto',
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          BsTextField(
              label: 'Nome do produto',
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Obrigatorio' : null),
          const SizedBox(height: 14),
          BsTextField(
              label: 'Descrição',
              controller: _descCtrl,
              maxLines: 2,
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Obrigatorio' : null),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: BsTextField(
              label: 'Preço (R\$)',
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              validator: (v) {
                final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                return (n == null || n <= 0) ? 'Invalido' : null;
              },
            )),
            const SizedBox(width: 12),
            Expanded(
                child: BsTextField(
              label: 'Estoque',
              controller: _stockCtrl,
              keyboardType: TextInputType.number,
              validator: (v) =>
                  int.tryParse(v ?? '') == null ? 'Invalido' : null,
            )),
          ]),
          const SizedBox(height: 14),
          BsTextField(
              label: 'Marca',
              controller: _brandCtrl,
              textInputAction: TextInputAction.done),
          const SizedBox(height: 14),
          // Categoria
          DropdownButtonFormField<ProductCategory>(
            initialValue: _category,
            dropdownColor: AppTheme.surfaceElevated,
            decoration: InputDecoration(
              labelText: 'Categoria',
              labelStyle:
                  GoogleFonts.jost(color: AppTheme.textSecondary, fontSize: 13),
              floatingLabelStyle:
                  GoogleFonts.jost(color: AppTheme.gold, fontSize: 12),
              filled: true,
              fillColor: AppTheme.surfaceElevated,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.inputBorder)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.inputBorder)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppTheme.gold, width: 1.5)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: ProductCategory.values
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(c.iconData,
                            size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text(c.label,
                            style: GoogleFonts.jost(
                                color: AppTheme.textPrimary, fontSize: 14)),
                      ]),
                    ))
                .toList(),
            onChanged: (c) => setState(() => _category = c!),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.error.withOpacity(0.35)),
              ),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.jost(
                  color: AppTheme.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          BsSaveButton(
              label: _isEditing ? 'Salvar alteracoes' : 'Adicionar produto',
              onPressed: _save,
              isLoading: _isSubmitting),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
