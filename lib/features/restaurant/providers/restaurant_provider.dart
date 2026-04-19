// lib/features/restaurant/providers/restaurant_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock_data.dart';

// Provides a single restaurant by ID
final restaurantByIdProvider =
Provider.family<Restaurant?, String>((ref, id) {
  try {
    return mockRestaurants.firstWhere((r) => r.id == id);
  } catch (_) {
    return null;
  }
});

// Active menu category tab index per restaurant
final activeMenuCategoryProvider =
StateProvider.family<int, String>((ref, restaurantId) => 0);

// Derived: unique category names for a given restaurant
final menuCategoriesProvider =
Provider.family<List<String>, String>((ref, restaurantId) {
  final restaurant = ref.watch(restaurantByIdProvider(restaurantId));
  if (restaurant == null) return [];
  final seen = <String>{};
  return restaurant.menu
      .map((item) => item.category)
      .where((c) => seen.add(c))
      .toList();
});

// Derived: items filtered by selected category
final filteredMenuItemsProvider =
Provider.family<List<MenuItem>, String>((ref, restaurantId) {
  final restaurant = ref.watch(restaurantByIdProvider(restaurantId));
  if (restaurant == null) return [];
  final categories = ref.watch(menuCategoriesProvider(restaurantId));
  final activeIndex =
  ref.watch(activeMenuCategoryProvider(restaurantId));
  if (categories.isEmpty) return restaurant.menu;
  final selectedCategory = categories[activeIndex];
  return restaurant.menu
      .where((item) => item.category == selectedCategory)
      .toList();
});