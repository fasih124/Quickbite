// lib/features/cart/providers/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../../../data/mock_data.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  String? _currentRestaurantId;

  String? get currentRestaurantId => _currentRestaurantId;

  bool get isEmpty => state.isEmpty;

  int get totalQuantity =>
      state.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      state.fold(0.0, (sum, item) => sum + item.subtotal);

  void addItem({
    required String restaurantId,
    required MenuItem menuItem,
    required List<AddOn> selectedAddOns,
  }) {
    // If adding from a different restaurant, clear cart first
    if (_currentRestaurantId != null &&
        _currentRestaurantId != restaurantId) {
      state = [];
    }
    _currentRestaurantId = restaurantId;

    final newItem = CartItem(
      restaurantId: restaurantId,
      menuItem: menuItem,
      selectedAddOns: selectedAddOns,
    );

    final existingIndex =
    state.indexWhere((i) => i.uniqueKey == newItem.uniqueKey);

    if (existingIndex >= 0) {
      final updated = [...state];
      updated[existingIndex].quantity++;
      state = updated;
    } else {
      state = [...state, newItem];
    }
  }

  void removeItem(String uniqueKey) {
    state = state.where((i) => i.uniqueKey != uniqueKey).toList();
    if (state.isEmpty) _currentRestaurantId = null;
  }

  void decrementItem(String uniqueKey) {
    final index = state.indexWhere((i) => i.uniqueKey == uniqueKey);
    if (index < 0) return;
    if (state[index].quantity <= 1) {
      removeItem(uniqueKey);
    } else {
      final updated = [...state];
      updated[index].quantity--;
      state = updated;
    }
  }

  void clearCart() {
    state = [];
    _currentRestaurantId = null;
  }
}

final cartProvider =
StateNotifierProvider<CartNotifier, List<CartItem>>(
      (ref) => CartNotifier(),
);

final cartTotalQuantityProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.subtotal);
});