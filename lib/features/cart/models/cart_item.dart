// lib/features/cart/models/cart_item.dart
import '../../../data/mock_data.dart';

class CartItem {
  final String restaurantId;
  final MenuItem menuItem;
  final List<AddOn> selectedAddOns;
  int quantity;

  CartItem({
    required this.restaurantId,
    required this.menuItem,
    required this.selectedAddOns,
    this.quantity = 1,
  });

  double get unitPrice =>
      menuItem.price + selectedAddOns.fold(0.0, (s, a) => s + a.price);

  double get subtotal => unitPrice * quantity;

  String get uniqueKey =>
      '${menuItem.id}_${selectedAddOns.map((a) => a.id).join('_')}';
}