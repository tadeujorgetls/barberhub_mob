library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'barber_shop_notifier.dart';
import 'barber_shop_state.dart';

export 'barber_shop_state.dart';
export 'barber_shop_notifier.dart';

final barberShopNotifierProvider =
    StateNotifierProvider<BarberShopNotifier, BarberShopState>(
  (ref) => BarberShopNotifier(ref),
);
