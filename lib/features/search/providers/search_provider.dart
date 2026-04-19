// lib/features/search/providers/search_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock_data.dart';

// ── Search query ──────────────────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');

// ── Result type ───────────────────────────────────────────────────────────────
enum SearchResultType { restaurant, menuItem }

// ── Unified search result model ───────────────────────────────────────────────
class SearchResult {
  final SearchResultType type;
  final Restaurant? restaurant;
  final MenuItem? menuItem;
  final String? menuItemRestaurantId;
  final String? menuItemRestaurantName;

  const SearchResult.restaurant(this.restaurant)
      : type = SearchResultType.restaurant,
        menuItem = null,
        menuItemRestaurantId = null,
        menuItemRestaurantName = null;

  const SearchResult.item({
    required MenuItem item,
    required String restaurantId,
    required String restaurantName,
  })  : type = SearchResultType.menuItem,
        menuItem = item,
        menuItemRestaurantId = restaurantId,
        menuItemRestaurantName = restaurantName,
        restaurant = null;
}

// ── Recent searches notifier ──────────────────────────────────────────────────
class RecentSearchesNotifier extends StateNotifier<List<SearchResult>> {
  RecentSearchesNotifier() : super(_mockRecent);

  static final _mockRecent = [
    SearchResult.restaurant(mockRestaurants[3]),
    SearchResult.item(
      item: mockRestaurants[1].menu[0],
      restaurantId: mockRestaurants[1].id,
      restaurantName: mockRestaurants[1].name,
    ),
    SearchResult.restaurant(mockRestaurants[0]),
  ];

  void clear() => state = [];

  void add(SearchResult result) {
    state = [
      result,
      ...state.where((r) {
        if (r.type != result.type) return true;
        if (result.type == SearchResultType.restaurant) {
          return r.restaurant?.id != result.restaurant?.id;
        }
        return r.menuItem?.id != result.menuItem?.id;
      }).take(9).toList(),
    ];
  }
}

final recentSearchesProvider =
StateNotifierProvider<RecentSearchesNotifier, List<SearchResult>>(
      (ref) => RecentSearchesNotifier(),
);

// ── Live search results ───────────────────────────────────────────────────────
final searchResultsProvider = Provider<List<SearchResult>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  if (query.isEmpty) return [];

  final results = <SearchResult>[];

  for (final restaurant in mockRestaurants) {
    final matchesRestaurant =
        restaurant.name.toLowerCase().contains(query) ||
            restaurant.cuisine.toLowerCase().contains(query) ||
            restaurant.category.toLowerCase().contains(query);

    if (matchesRestaurant) {
      results.add(SearchResult.restaurant(restaurant));
    }

    for (final item in restaurant.menu) {
      final matchesItem =
          item.name.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query);

      if (matchesItem) {
        results.add(SearchResult.item(
          item: item,
          restaurantId: restaurant.id,
          restaurantName: restaurant.name,
        ));
      }
    }
  }

  return results;
});