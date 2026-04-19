// lib/features/home/providers/home_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock_data.dart';

// Selected category chip index (0 = All)
final selectedCategoryIndexProvider = StateProvider<int>((ref) => 0);

// Filtered restaurants based on selected category
final filteredRestaurantsProvider = Provider<List<Restaurant>>((ref) {
  final selectedIndex = ref.watch(selectedCategoryIndexProvider);
  if (selectedIndex == 0) return mockRestaurants;

  // Category chips on home: index 1 = Pizza, 2 = Burgers, etc.
  const categoryMap = {
    1: 'Pizza',
    2: 'Fast Food',
    3: 'Desi',
    4: 'BBQ',
    5: 'Chinese',
    6: 'Rolls',
  };

  final category = categoryMap[selectedIndex];
  if (category == null) return mockRestaurants;

  return mockRestaurants
      .where((r) =>
  r.category.toLowerCase() == category.toLowerCase() ||
      r.cuisine.toLowerCase().contains(category.toLowerCase()))
      .toList();
});

final featuredRestaurantsProvider = Provider<List<Restaurant>>((ref) {
  return mockRestaurants.where((r) => r.isFeatured).toList();
});

// Simulates a network fetch delay — triggers shimmer on first load
final homeLoadingProvider = FutureProvider<bool>((ref) async {
  await Future.delayed(const Duration(milliseconds: 1200));
  return true;
});