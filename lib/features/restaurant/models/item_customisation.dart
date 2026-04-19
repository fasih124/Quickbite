// lib/features/restaurant/models/item_customisation.dart
// Extended models for the customisation sheet.
// SizeOption is a local concept for the sheet — mock data AddOns map to
// the add-ons section. We simulate size options from the item's add-ons
// by treating the first add-on group as sizes when the item has >= 3 add-ons,
// otherwise showing all as add-ons.

class SizeOption {
  final String id;
  final String label;
  final double extraPrice;

  const SizeOption({
    required this.id,
    required this.label,
    required this.extraPrice,
  });
}

// We'll derive sizes + addons from MenuItem.addOns inside the sheet widget.
// For Burger Lab items (r_2) that have "Upgrade" add-ons, we simulate sizes.