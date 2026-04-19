// lib/features/checkout/providers/checkout_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock_data.dart';

// Selected delivery address index
final selectedAddressIndexProvider = StateProvider<int>((ref) => 0);

// Mock saved payment methods
class PaymentMethod {
  final String id;
  final String label;
  final String last4;
  final String brand; // 'visa', 'mastercard', 'jazz'

  const PaymentMethod({
    required this.id,
    required this.label,
    required this.last4,
    required this.brand,
  });
}

final mockPaymentMethods = [
  const PaymentMethod(
      id: 'pm_1', label: 'Visa', last4: '4421', brand: 'visa'),
  const PaymentMethod(
      id: 'pm_2', label: 'Mastercard', last4: '8832', brand: 'mastercard'),
  const PaymentMethod(
      id: 'pm_3', label: 'Cash on Delivery', last4: '', brand: 'cash'),
];

final selectedPaymentIndexProvider = StateProvider<int>((ref) => 0);

// Service fee constant
const double kServiceFee = 50;