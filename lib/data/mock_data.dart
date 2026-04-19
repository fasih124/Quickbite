// lib/data/mock_data.dart
// ─────────────────────────────────────────────────────────────────────────────
// MOCK DATA — single source of truth for the entire app.
// No backend. Every screen reads from here (via providers that expose this).
// ─────────────────────────────────────────────────────────────────────────────

// ──────────────────── ADD-ON ─────────────────────────────────────────────────

class AddOn {
  final String id;
  final String name;
  final double price; // PKR

  const AddOn({
    required this.id,
    required this.name,
    required this.price,
  });
}

// ──────────────────── MENU ITEM ──────────────────────────────────────────────

class MenuItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;   // e.g. "Burgers", "Drinks", "Sides"
  final double price;      // PKR
  final bool isPopular;
  final bool isVeg;
  final List<AddOn> addOns;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.price,
    this.isPopular = false,
    this.isVeg = false,
    required this.addOns,
  });
}

// ──────────────────── RESTAURANT ─────────────────────────────────────────────

class Restaurant {
  final String id;
  final String name;
  final String imageUrl;   // banner / hero image
  final String logoUrl;
  final String category;   // e.g. "Fast Food", "Desi", "Pizza"
  final String cuisine;    // comma-separated e.g. "Pakistani, BBQ"
  final String address;
  final double rating;
  final int totalReviews;
  final int deliveryTimeMin; // minutes
  final int deliveryTimeMax;
  final double deliveryFee;  // PKR
  final int minimumOrder;    // PKR
  final bool isOpen;
  final bool isFeatured;
  final List<String> tags;   // e.g. ["Trending", "Bestseller"]
  final List<MenuItem> menu;

  const Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.logoUrl,
    required this.category,
    required this.cuisine,
    required this.address,
    required this.rating,
    required this.totalReviews,
    required this.deliveryTimeMin,
    required this.deliveryTimeMax,
    required this.deliveryFee,
    required this.minimumOrder,
    this.isOpen = true,
    this.isFeatured = false,
    this.tags = const [],
    required this.menu,
  });
}

// ──────────────────── ADDRESS ────────────────────────────────────────────────

class UserAddress {
  final String id;
  final String label;        // "Home", "Office", "Other"
  final String fullAddress;
  final String city;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const UserAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });
}

// ──────────────────── USER ───────────────────────────────────────────────────

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final List<UserAddress> addresses;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.addresses,
  });
}

// ──────────────────── ORDER STATUS ───────────────────────────────────────────

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  onTheWay,
  delivered,
  cancelled,
}

// ──────────────────── ORDER ITEM ─────────────────────────────────────────────

class OrderItem {
  final MenuItem menuItem;
  final int quantity;
  final List<AddOn> selectedAddOns;

  const OrderItem({
    required this.menuItem,
    required this.quantity,
    this.selectedAddOns = const [],
  });

  double get subtotal =>
      (menuItem.price +
          selectedAddOns.fold(0.0, (sum, a) => sum + a.price)) *
          quantity;
}

// ──────────────────── ORDER ──────────────────────────────────────────────────

class Order {
  final String id;
  final Restaurant restaurant;
  final List<OrderItem> items;
  final OrderStatus status;
  final double deliveryFee;
  final double discount;
  final DateTime placedAt;
  final UserAddress deliveryAddress;

  const Order({
    required this.id,
    required this.restaurant,
    required this.items,
    required this.status,
    required this.deliveryFee,
    this.discount = 0,
    required this.placedAt,
    required this.deliveryAddress,
  });

  double get itemsTotal =>
      items.fold(0.0, (sum, i) => sum + i.subtotal);

  double get grandTotal => itemsTotal + deliveryFee - discount;
}

// ──────────────────── PROMO CODE ─────────────────────────────────────────────

class PromoCode {
  final String code;
  final String description;
  final double discountPercent; // 0–100
  final double maxDiscount;     // PKR cap
  final double minOrderValue;   // PKR

  const PromoCode({
    required this.code,
    required this.description,
    required this.discountPercent,
    required this.maxDiscount,
    required this.minOrderValue,
  });
}

// ──────────────────── CATEGORY ───────────────────────────────────────────────

class FoodCategory {
  final String id;
  final String name;
  final String emoji;
  final String imageUrl;

  const FoodCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.imageUrl,
  });
}

// =============================================================================
// ████████████████████████  DATA INSTANCES  ███████████████████████████████████
// =============================================================================

// ──────────────────── CATEGORIES ─────────────────────────────────────────────

final List<FoodCategory> mockCategories = const [
  FoodCategory(
    id: 'cat_1',
    name: 'Burgers',
    emoji: '🍔',
    imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200&q=80',
  ),
  FoodCategory(
    id: 'cat_2',
    name: 'Pizza',
    emoji: '🍕',
    imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200&q=80',
  ),
  FoodCategory(
    id: 'cat_3',
    name: 'Desi',
    emoji: '🍛',
    imageUrl: 'https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a?w=200&q=80',
  ),
  FoodCategory(
    id: 'cat_4',
    name: 'BBQ',
    emoji: '🔥',
    imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=200&q=80',
  ),
  FoodCategory(
    id: 'cat_5',
    name: 'Rolls',
    emoji: '🌯',
    imageUrl: 'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=200&q=80',
  ),
  FoodCategory(
    id: 'cat_6',
    name: 'Desserts',
    emoji: '🍰',
    imageUrl: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=200&q=80',
  ),
  FoodCategory(
    id: 'cat_7',
    name: 'Drinks',
    emoji: '🥤',
    imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=200&q=80',
  ),
  FoodCategory(
    id: 'cat_8',
    name: 'Chinese',
    emoji: '🍜',
    imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200&q=80',
  ),
];

// ──────────────────── RESTAURANTS ────────────────────────────────────────────

final List<Restaurant> mockRestaurants = [

  // ── 1. STUDENT BIRYANI ───────────────────────────────────────────────────
  Restaurant(
    id: 'r_1',
    name: 'Student Biryani',
    imageUrl: 'https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a?w=800&q=80',
    logoUrl: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=200&q=80',
    category: 'Desi',
    cuisine: 'Pakistani, Biryani, Rice',
    address: 'Blue Area, Islamabad',
    rating: 4.7,
    totalReviews: 2340,
    deliveryTimeMin: 25,
    deliveryTimeMax: 40,
    deliveryFee: 49,
    minimumOrder: 300,
    isOpen: true,
    isFeatured: true,
    tags: const ['Trending', '#1 in Biryani'],
    menu: const [
      MenuItem(
        id: 'r1_m1',
        name: 'Chicken Biryani (Full)',
        description:
        'Fragrant long-grain basmati rice layered with tender chicken, whole spices, fried onions, and fresh mint. Served with raita and salad.',
        imageUrl:
        'https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a?w=400&q=80',
        category: 'Biryani',
        price: 480,
        isPopular: true,
        addOns: [
          AddOn(id: 'a1', name: 'Extra Raita', price: 50),
          AddOn(id: 'a2', name: 'Seekh Kabab (2 pcs)', price: 130),
          AddOn(id: 'a3', name: 'Cold Drink 500ml', price: 80),
        ],
      ),
      MenuItem(
        id: 'r1_m2',
        name: 'Mutton Biryani (Half)',
        description:
        'Slow-cooked mutton on the bone with aged basmati, saffron milk, and caramelised onions. Rich, aromatic, and deeply satisfying.',
        imageUrl:
        'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=400&q=80',
        category: 'Biryani',
        price: 550,
        addOns: [
          AddOn(id: 'a1', name: 'Extra Raita', price: 50),
          AddOn(id: 'a4', name: 'Shami Kabab (2 pcs)', price: 100),
        ],
      ),
      MenuItem(
        id: 'r1_m3',
        name: 'Beef Kofta Curry',
        description:
        'Spiced minced beef koftas simmered in a tangy tomato-onion gravy. Best paired with naan or paratha.',
        imageUrl:
        'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=400&q=80',
        category: 'Curry',
        price: 420,
        addOns: [
          AddOn(id: 'a5', name: 'Garlic Naan', price: 60),
          AddOn(id: 'a6', name: 'Plain Paratha', price: 40),
        ],
      ),
      MenuItem(
        id: 'r1_m4',
        name: 'Daal Makhani',
        description:
        'Slow-cooked black lentils and kidney beans in a buttery tomato cream sauce. A vegetarian classic.',
        imageUrl:
        'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400&q=80',
        category: 'Vegetarian',
        price: 280,
        isVeg: true,
        addOns: [
          AddOn(id: 'a5', name: 'Garlic Naan', price: 60),
        ],
      ),
      MenuItem(
        id: 'r1_m5',
        name: 'Gulab Jamun (4 pcs)',
        description:
        'Soft, melt-in-your-mouth milk-solid dumplings soaked in rose-cardamom syrup. Served warm.',
        imageUrl:
        'https://images.unsplash.com/photo-1666189143398-01a47e9d72db?w=400&q=80',
        category: 'Desserts',
        price: 150,
        isVeg: true,
        addOns: [],
      ),
    ],
  ),

  // ── 2. BURGER LAB ────────────────────────────────────────────────────────
  Restaurant(
    id: 'r_2',
    name: 'Burger Lab',
    imageUrl:
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80',
    logoUrl:
    'https://images.unsplash.com/photo-1550547660-d9450f859349?w=200&q=80',
    category: 'Fast Food',
    cuisine: 'Burgers, Fries, Shakes',
    address: 'F-7 Markaz, Islamabad',
    rating: 4.5,
    totalReviews: 1870,
    deliveryTimeMin: 20,
    deliveryTimeMax: 35,
    deliveryFee: 79,
    minimumOrder: 400,
    isOpen: true,
    isFeatured: true,
    tags: const ['Bestseller', 'Must Try'],
    menu: const [
      MenuItem(
        id: 'r2_m1',
        name: 'Smash Double Patty',
        description:
        'Two hand-smashed beef patties, American cheddar, caramelised onions, pickles, and Lab special sauce in a toasted brioche bun.',
        imageUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80',
        category: 'Burgers',
        price: 690,
        isPopular: true,
        addOns: [
          AddOn(id: 'b1', name: 'Upgrade to Large Fries', price: 100),
          AddOn(id: 'b2', name: 'Add Jalapeños', price: 40),
          AddOn(id: 'b3', name: 'Extra Cheese Slice', price: 60),
          AddOn(id: 'b4', name: 'Chocolate Shake 350ml', price: 220),
        ],
      ),
      MenuItem(
        id: 'r2_m2',
        name: 'Crispy Chicken Burger',
        description:
        'Southern-style fried chicken breast, coleslaw, chipotle mayo, and sliced pickles on a sesame bun.',
        imageUrl:
        'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=400&q=80',
        category: 'Burgers',
        price: 590,
        addOns: [
          AddOn(id: 'b1', name: 'Upgrade to Large Fries', price: 100),
          AddOn(id: 'b5', name: 'Add Bacon Strip', price: 90),
        ],
      ),
      MenuItem(
        id: 'r2_m3',
        name: 'Loaded Cheese Fries',
        description:
        'Crispy shoestring fries smothered in nacho cheese sauce, jalapeños, sour cream, and crispy fried onions.',
        imageUrl:
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400&q=80',
        category: 'Sides',
        price: 350,
        isVeg: true,
        addOns: [
          AddOn(id: 'b6', name: 'Add Chicken Chunks', price: 120),
        ],
      ),
      MenuItem(
        id: 'r2_m4',
        name: 'Oreo Thick Shake',
        description:
        'Blended vanilla soft-serve with crushed Oreos and whole milk, topped with whipped cream and an Oreo cookie.',
        imageUrl:
        'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400&q=80',
        category: 'Drinks',
        price: 280,
        isVeg: true,
        addOns: [],
      ),
      MenuItem(
        id: 'r2_m5',
        name: 'BBQ Chicken Wings (6 pcs)',
        description:
        'Slow-marinated chicken wings, grilled and glazed with smoky BBQ sauce. Served with blue-cheese dip.',
        imageUrl:
        'https://images.unsplash.com/photo-1608039755401-742074f0548d?w=400&q=80',
        category: 'Sides',
        price: 520,
        addOns: [
          AddOn(id: 'b7', name: 'Extra Dip', price: 50),
          AddOn(id: 'b8', name: 'Add 3 More Wings', price: 240),
        ],
      ),
    ],
  ),

  // ── 3. PIZZA POINT ───────────────────────────────────────────────────────
  Restaurant(
    id: 'r_3',
    name: 'Pizza Point',
    imageUrl:
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
    logoUrl:
    'https://images.unsplash.com/photo-1548369937-47519962c11a?w=200&q=80',
    category: 'Pizza',
    cuisine: 'Pizza, Pasta, Garlic Bread',
    address: 'Jinnah Super, F-7, Islamabad',
    rating: 4.3,
    totalReviews: 980,
    deliveryTimeMin: 30,
    deliveryTimeMax: 50,
    deliveryFee: 99,
    minimumOrder: 500,
    isOpen: true,
    isFeatured: false,
    tags: const ['Family Deal'],
    menu: const [
      MenuItem(
        id: 'r3_m1',
        name: 'Dynamite Chicken Pizza (Lg)',
        description:
        'Spicy dynamite-glazed chicken chunks, mozzarella, red onions, capsicum, and sriracha drizzle on hand-tossed crust.',
        imageUrl:
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
        category: 'Pizza',
        price: 1100,
        isPopular: true,
        addOns: [
          AddOn(id: 'c1', name: 'Extra Cheese', price: 150),
          AddOn(id: 'c2', name: 'Stuffed Crust', price: 200),
          AddOn(id: 'c3', name: 'Add Jalapeños', price: 60),
        ],
      ),
      MenuItem(
        id: 'r3_m2',
        name: 'BBQ Beef Pizza (Med)',
        description:
        'Smoky BBQ sauce base, minced beef, caramelised onions, cheddar and mozzarella blend, topped with fresh rocket.',
        imageUrl:
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80',
        category: 'Pizza',
        price: 850,
        addOns: [
          AddOn(id: 'c1', name: 'Extra Cheese', price: 150),
          AddOn(id: 'c2', name: 'Stuffed Crust', price: 200),
        ],
      ),
      MenuItem(
        id: 'r3_m3',
        name: 'Veggie Supreme (Med)',
        description:
        'Tomato sauce, mozzarella, bell peppers, mushrooms, black olives, sweet corn, and fresh tomatoes.',
        imageUrl:
        'https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=400&q=80',
        category: 'Pizza',
        price: 750,
        isVeg: true,
        addOns: [
          AddOn(id: 'c1', name: 'Extra Cheese', price: 150),
        ],
      ),
      MenuItem(
        id: 'r3_m4',
        name: 'Penne Arrabiata',
        description:
        'Al-dente penne in a fiery tomato and garlic sauce with fresh basil and shaved Parmesan.',
        imageUrl:
        'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400&q=80',
        category: 'Pasta',
        price: 580,
        isVeg: true,
        addOns: [
          AddOn(id: 'c4', name: 'Add Grilled Chicken', price: 150),
          AddOn(id: 'c5', name: 'Garlic Bread', price: 120),
        ],
      ),
      MenuItem(
        id: 'r3_m5',
        name: 'Cheesy Garlic Bread',
        description:
        'Toasted baguette slices brushed with garlic butter and loaded with mozzarella. Served with marinara dip.',
        imageUrl:
        'https://images.unsplash.com/photo-1573140247632-f8fd74997d5c?w=400&q=80',
        category: 'Sides',
        price: 320,
        isVeg: true,
        addOns: [
          AddOn(id: 'c6', name: 'Extra Marinara Dip', price: 50),
        ],
      ),
    ],
  ),

  // ── 4. SHINWARI TIKKA HOUSE ──────────────────────────────────────────────
  Restaurant(
    id: 'r_4',
    name: 'Shinwari Tikka House',
    imageUrl:
    'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&q=80',
    logoUrl:
    'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=200&q=80',
    category: 'BBQ',
    cuisine: 'BBQ, Tikka, Kabab, NWFP',
    address: 'Melody Food Street, G-6, Islamabad',
    rating: 4.8,
    totalReviews: 3120,
    deliveryTimeMin: 35,
    deliveryTimeMax: 55,
    deliveryFee: 59,
    minimumOrder: 600,
    isOpen: true,
    isFeatured: true,
    tags: const ['Legendary', 'Top Rated'],
    menu: const [
      MenuItem(
        id: 'r4_m1',
        name: 'Shinwari Karahi (Full)',
        description:
        'Classic NWFP-style karahi with bone-in mutton, tomatoes, green chillies, and hand-crushed spices. Cooked in a steel wok over open flame.',
        imageUrl:
        'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&q=80',
        category: 'Karahi',
        price: 1800,
        isPopular: true,
        addOns: [
          AddOn(id: 'd1', name: 'Tandoori Naan (4 pcs)', price: 100),
          AddOn(id: 'd2', name: 'Raita Bowl', price: 80),
          AddOn(id: 'd3', name: 'Mixed Salad', price: 120),
        ],
      ),
      MenuItem(
        id: 'r4_m2',
        name: 'Chicken Tikka Platter (8 pcs)',
        description:
        'Overnight-marinated chicken pieces in a yoghurt-spice marinade, char-grilled on a clay oven. Served with naan, chutney, and salad.',
        imageUrl:
        'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=400&q=80',
        category: 'Tikka',
        price: 950,
        isPopular: true,
        addOns: [
          AddOn(id: 'd1', name: 'Tandoori Naan (4 pcs)', price: 100),
          AddOn(id: 'd4', name: 'Mint Chutney Extra', price: 50),
        ],
      ),
      MenuItem(
        id: 'r4_m3',
        name: 'Seekh Kabab (6 pcs)',
        description:
        'Minced beef mixed with fresh herbs, raw onion, and spices, skewered and grilled over charcoal. Smoky and juicy.',
        imageUrl:
        'https://images.unsplash.com/photo-1529042410759-befb1204b468?w=400&q=80',
        category: 'Kabab',
        price: 680,
        addOns: [
          AddOn(id: 'd5', name: 'Chapli Kabab Add-on (2 pcs)', price: 220),
          AddOn(id: 'd1', name: 'Tandoori Naan (4 pcs)', price: 100),
        ],
      ),
      MenuItem(
        id: 'r4_m4',
        name: 'Lamb Chops (4 pcs)',
        description:
        'Tender lamb chops marinated in raw papaya and Kashmiri chilli, grilled to perfection. A house speciality.',
        imageUrl:
        'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&q=80',
        category: 'Chops',
        price: 1400,
        addOns: [
          AddOn(id: 'd6', name: 'Add 2 More Chops', price: 680),
          AddOn(id: 'd2', name: 'Raita Bowl', price: 80),
        ],
      ),
      MenuItem(
        id: 'r4_m5',
        name: 'Qehwa (Pot — 4 cups)',
        description:
        'Aromatic green tea brewed with cardamom, cinnamon, and saffron. Served in a traditional copper kettle.',
        imageUrl:
        'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400&q=80',
        category: 'Drinks',
        price: 180,
        isVeg: true,
        addOns: [],
      ),
    ],
  ),

  // ── 5. WOK & ROLL (CHINESE) ───────────────────────────────────────────────
  Restaurant(
    id: 'r_5',
    name: 'Wok & Roll',
    imageUrl:
    'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&q=80',
    logoUrl:
    'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=200&q=80',
    category: 'Chinese',
    cuisine: 'Chinese, Thai, Pan-Asian',
    address: 'Super Market, F-6, Islamabad',
    rating: 4.2,
    totalReviews: 760,
    deliveryTimeMin: 30,
    deliveryTimeMax: 45,
    deliveryFee: 89,
    minimumOrder: 500,
    isOpen: true,
    isFeatured: false,
    tags: const ['New'],
    menu: const [
      MenuItem(
        id: 'r5_m1',
        name: 'Kung Pao Chicken',
        description:
        'Diced chicken stir-fried with dried red chillies, peanuts, and spring onions in a tangy Szechuan sauce. Served with steamed rice.',
        imageUrl:
        'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=400&q=80',
        category: 'Mains',
        price: 620,
        isPopular: true,
        addOns: [
          AddOn(id: 'e1', name: 'Fried Rice instead of Steamed', price: 60),
          AddOn(id: 'e2', name: 'Spring Rolls (2 pcs)', price: 150),
        ],
      ),
      MenuItem(
        id: 'r5_m2',
        name: 'Beef Chow Mein',
        description:
        'Wok-tossed egg noodles with tender beef strips, bok choy, carrots, and oyster-soy glaze.',
        imageUrl:
        'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400&q=80',
        category: 'Noodles',
        price: 580,
        addOns: [
          AddOn(id: 'e3', name: 'Extra Beef', price: 100),
          AddOn(id: 'e4', name: 'Chilli Sauce Side', price: 40),
        ],
      ),
      MenuItem(
        id: 'r5_m3',
        name: 'Veg Fried Rice',
        description:
        'Wok-fried jasmine rice with egg, mixed vegetables, soy sauce, and sesame oil. Light and fragrant.',
        imageUrl:
        'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&q=80',
        category: 'Rice',
        price: 380,
        isVeg: true,
        addOns: [
          AddOn(id: 'e5', name: 'Add Fried Egg on top', price: 50),
        ],
      ),
      MenuItem(
        id: 'r5_m4',
        name: 'Chicken Hot & Sour Soup',
        description:
        'Classic Chinese broth with shredded chicken, tofu, mushrooms, bamboo shoots, and a silky egg-drop finish. Serves 2.',
        imageUrl:
        'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=80',
        category: 'Soups',
        price: 320,
        addOns: [
          AddOn(id: 'e6', name: 'Upgrade to Serves 4', price: 280),
        ],
      ),
      MenuItem(
        id: 'r5_m5',
        name: 'Mango Sago Pudding',
        description:
        'Chilled coconut milk pudding with ripe Anwar Ratol mango chunks and tapioca pearls.',
        imageUrl:
        'https://images.unsplash.com/photo-1621303837174-89787a7d4729?w=400&q=80',
        category: 'Desserts',
        price: 270,
        isVeg: true,
        addOns: [],
      ),
    ],
  ),

  // ── 6. ROLL WORLD ─────────────────────────────────────────────────────────
  Restaurant(
    id: 'r_6',
    name: 'Roll World',
    imageUrl:
    'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=800&q=80',
    logoUrl:
    'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=200&q=80',
    category: 'Rolls',
    cuisine: 'Rolls, Shawarma, Wraps',
    address: 'I-8 Markaz, Islamabad',
    rating: 4.4,
    totalReviews: 1450,
    deliveryTimeMin: 15,
    deliveryTimeMax: 30,
    deliveryFee: 39,
    minimumOrder: 250,
    isOpen: true,
    isFeatured: false,
    tags: const ['Fast Delivery', 'Value Pick'],
    menu: const [
      MenuItem(
        id: 'r6_m1',
        name: 'Zinger Roll',
        description:
        'Crispy fried chicken fillet, shredded cabbage, garlic mayo, and pickled cucumber tightly wrapped in a grilled paratha.',
        imageUrl:
        'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=400&q=80',
        category: 'Rolls',
        price: 320,
        isPopular: true,
        addOns: [
          AddOn(id: 'f1', name: 'Make it Double Fillet', price: 160),
          AddOn(id: 'f2', name: 'Add Cheese Slice', price: 50),
          AddOn(id: 'f3', name: 'Fries (Regular)', price: 130),
        ],
      ),
      MenuItem(
        id: 'r6_m2',
        name: 'BBQ Beef Shawarma',
        description:
        'Shaved slow-roasted beef, garlic sauce, pickled turnips, and chilli sauce in a warm Lebanese flatbread.',
        imageUrl:
        'https://images.unsplash.com/photo-1561651823-34feb02250e4?w=400&q=80',
        category: 'Shawarma',
        price: 380,
        addOns: [
          AddOn(id: 'f4', name: 'Extra Garlic Sauce', price: 40),
          AddOn(id: 'f3', name: 'Fries (Regular)', price: 130),
        ],
      ),
      MenuItem(
        id: 'r6_m3',
        name: 'Seekh Kabab Roll',
        description:
        'Two freshly grilled seekh kababs with raw onion rings, fresh coriander, and tamarind chutney in a soft paratha.',
        imageUrl:
        'https://images.unsplash.com/photo-1529042410759-befb1204b468?w=400&q=80',
        category: 'Rolls',
        price: 290,
        addOns: [
          AddOn(id: 'f5', name: 'Add Extra Kabab', price: 110),
          AddOn(id: 'f2', name: 'Add Cheese Slice', price: 50),
        ],
      ),
      MenuItem(
        id: 'r6_m4',
        name: 'Paneer Tikka Roll',
        description:
        'Marinated paneer cubes grilled in a tandoor, with green chutney, sliced onions, and lemon in a whole-wheat paratha.',
        imageUrl:
        'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&q=80',
        category: 'Rolls',
        price: 270,
        isVeg: true,
        addOns: [
          AddOn(id: 'f4', name: 'Extra Chutney', price: 40),
        ],
      ),
      MenuItem(
        id: 'r6_m5',
        name: 'Loaded Fries Box',
        description:
        'Crispy golden fries topped with melted cheese, chopped jalapeños, and Roll World signature ketchup. Comfort in a box.',
        imageUrl:
        'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400&q=80',
        category: 'Sides',
        price: 220,
        isVeg: true,
        addOns: [
          AddOn(id: 'f6', name: 'Add Chicken Topping', price: 90),
        ],
      ),
    ],
  ),
];

// ──────────────────── MOCK USER ───────────────────────────────────────────────

final AppUser mockUser = AppUser(
  id: 'u_1',
  name: 'Ali Hassan',
  email: 'ali.hassan@gmail.com',
  phone: '+92 300 1234567',
  avatarUrl:
  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
  addresses: const [
    UserAddress(
      id: 'addr_1',
      label: 'Home',
      fullAddress: 'House 12, Street 5, F-7/2, Islamabad',
      city: 'Islamabad',
      latitude: 33.7215,
      longitude: 73.0433,
      isDefault: true,
    ),
    UserAddress(
      id: 'addr_2',
      label: 'Office',
      fullAddress: 'Blue Area, Jinnah Avenue, G-7/1, Islamabad',
      city: 'Islamabad',
      latitude: 33.7280,
      longitude: 73.0940,
    ),
  ],
);

// ──────────────────── PROMO CODES ─────────────────────────────────────────────

final List<PromoCode> mockPromoCodes = const [
  PromoCode(
    code: 'WELCOME50',
    description: '50% off your first order',
    discountPercent: 50,
    maxDiscount: 300,
    minOrderValue: 400,
  ),
  PromoCode(
    code: 'FLAT100',
    description: 'Rs. 100 off on orders above Rs. 800',
    discountPercent: 0,
    maxDiscount: 100,
    minOrderValue: 800,
  ),
  PromoCode(
    code: 'WEEKEND20',
    description: '20% off every weekend',
    discountPercent: 20,
    maxDiscount: 250,
    minOrderValue: 500,
  ),
];

// ──────────────────── PAST ORDERS (for Order History screen) ──────────────────

final List<Order> mockOrders = [
  Order(
    id: 'ord_001',
    restaurant: mockRestaurants[0], // Student Biryani
    items: [
      OrderItem(
        menuItem: mockRestaurants[0].menu[0], // Chicken Biryani
        quantity: 2,
        selectedAddOns: [mockRestaurants[0].menu[0].addOns[0]], // Extra Raita
      ),
      OrderItem(
        menuItem: mockRestaurants[0].menu[4], // Gulab Jamun
        quantity: 1,
      ),
    ],
    status: OrderStatus.delivered,
    deliveryFee: 49,
    discount: 0,
    placedAt: DateTime(2025, 6, 10, 13, 25),
    deliveryAddress: mockUser.addresses[0],
  ),
  Order(
    id: 'ord_002',
    restaurant: mockRestaurants[1], // Burger Lab
    items: [
      OrderItem(
        menuItem: mockRestaurants[1].menu[0], // Smash Double Patty
        quantity: 1,
        selectedAddOns: [
          mockRestaurants[1].menu[0].addOns[0], // Large Fries
          mockRestaurants[1].menu[0].addOns[2], // Extra Cheese
        ],
      ),
      OrderItem(
        menuItem: mockRestaurants[1].menu[3], // Oreo Shake
        quantity: 1,
      ),
    ],
    status: OrderStatus.delivered,
    deliveryFee: 79,
    discount: 100,
    placedAt: DateTime(2025, 6, 8, 20, 10),
    deliveryAddress: mockUser.addresses[0],
  ),
  Order(
    id: 'ord_003',
    restaurant: mockRestaurants[3], // Shinwari
    items: [
      OrderItem(
        menuItem: mockRestaurants[3].menu[1], // Chicken Tikka Platter
        quantity: 1,
      ),
      OrderItem(
        menuItem: mockRestaurants[3].menu[2], // Seekh Kabab
        quantity: 1,
      ),
    ],
    status: OrderStatus.onTheWay,
    deliveryFee: 59,
    discount: 0,
    placedAt: DateTime(2025, 6, 12, 19, 45),
    deliveryAddress: mockUser.addresses[1],
  ),
];

// ──────────────────── BANNERS (Home screen carousel) ─────────────────────────

class PromoBanner {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String? promoCode;

  const PromoBanner({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.promoCode,
  });
}

final List<PromoBanner> mockBanners = const [
  PromoBanner(
    id: 'b_1',
    imageUrl:
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80',
    title: '50% Off Your First Order',
    subtitle: 'Use code WELCOME50 at checkout',
    promoCode: 'WELCOME50',
  ),
  PromoBanner(
    id: 'b_2',
    imageUrl:
    'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&q=80',
    title: 'Shinwari Tikka Night',
    subtitle: 'Free delivery every Friday after 7 PM',
    promoCode: null,
  ),
  PromoBanner(
    id: 'b_3',
    imageUrl:
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
    title: 'Pizza Party Bundle',
    subtitle: 'Buy 2 Large Pizzas, get Garlic Bread free',
    promoCode: null,
  ),
];