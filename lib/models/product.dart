/// Represents a single listing posted by a student.
///
/// WHY A MODEL CLASS:
/// Right now we'll fill these with sample (fake) data so we can build the UI
/// without a backend yet. Later, when you connect Firebase or another
/// database, each row/document you fetch will be turned INTO a Product
/// object using a constructor like `Product.fromMap(...)`. Building the
/// model first means your UI code never needs to change when the data
/// source changes — only how a Product gets created changes.
class Product {
  final String id;
  final String title;
  final double price;
  final String category;
  final String imageUrl; // network image URL, or empty string for placeholder
  final String sellerName;
  final String sellerPhone; // empty string if the seller has none on file
  final DateTime postedAt;
  final bool isFavorite;
  final String description;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.sellerName,
    this.sellerPhone = '',
    required this.postedAt,
    required this.imageUrl,
    this.isFavorite = false,
    // Default to an empty string rather than making this `required`.
    // A real seller might genuinely leave the description blank when
    // posting an item — the Detail page already knows how to show a
    // fallback message in that case (see product_detail_page.dart).
    this.description = '',
  });

  Product copyWith({bool? isFavorite}) {
    return Product(
      id: id,
      title: title,
      price: price,
      category: category,
      sellerName: sellerName,
      sellerPhone: sellerPhone,
      postedAt: postedAt,
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description,
    );
  }
}

/// Temporary sample data so the Home Page has something to display.
///
/// WHY SAMPLE DATA:
/// As a beginner, it's much easier to get the UI looking right first using
/// data you control, THEN swap this list for real data from a database.
/// Trying to build UI and backend at the same time makes bugs hard to find.
final List<Product> sampleProducts = [
  Product(
    id: '1',
    title: 'Calculus Early Transcendentals (8th Ed)',
    price: 45.00,
    category: 'Textbooks',
    sellerName: 'JessePraise.',
    postedAt: DateTime.now().subtract(const Duration(hours: 3)),
    imageUrl: 'assets/images/calculus.jpg',
    description:
        'Used for one semester in MATH 201. A few highlighted pages but '
        'no torn or missing pages. Great condition otherwise. Selling '
        'because I finished the course.',
  ),
  Product(
    id: '2',
    title: 'HP Pavilion 15" Laptop, 8GB RAM',
    price: 850.00,
    category: 'Laptops',
    sellerName: 'Kwabs Laptops',
    sellerPhone: '+233241234567',
    postedAt: DateTime.now().subtract(const Duration(hours: 6)),
    imageUrl: 'assets/images/laptop.jpg',
    description:
        'HP Pavilion, Core i5, 8GB RAM, 256GB SSD. Battery still holds a '
        'good charge. Comes with the original charger. Upgrading to a new '
        'machine, hence the sale.',
  ),
  Product(
    id: '3',
    title: 'Casio FX-991 Scientific Calculator',
    price: 18.00,
    category: 'Calculators',
    sellerName: 'Efua B.',
    sellerPhone: '+233207654321',
    postedAt: DateTime.now().subtract(const Duration(days: 1)),
    imageUrl: 'assets/images/calculus.jpg',
    description:
        'Brand new, still sealed in box. Bought two by mistake for the '
        'same course. Standard model accepted for all engineering exams.',
  ),
  Product(
    id: '4',
    title: 'Hostel Bed Side Table',
    price: 30.00,
    category: 'Furniture',
    sellerName: 'Yaw M.',
    postedAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    imageUrl: 'assets/images/hostelbed.jpg',
    description:
        'Sturdy wooden bedside table, two drawers. Some minor scuffs on '
        'the legs but fully functional. Must be picked up from Hostel 4.',
  ),
  Product(
    id: '5',
    title: 'PS4 Controller (Wireless)',
    price: 40.00,
    category: 'Gaming',
    sellerName: 'Nana A.',
    sellerPhone: '+233551122334',
    postedAt: DateTime.now().subtract(const Duration(days: 2)),
    imageUrl: 'assets/images/Joystick-ps4-greenurba.jpg',
    // Left blank on purpose, as an example of a listing with no
    // description — this is what triggers the fallback message on the
    // Detail page.
  ),
  Product(
    id: '6',
    title: 'iPhone 11, 64GB, Good Condition',
    price: 400.00,
    category: 'Phones',
    sellerName: 'Abena S.',
    sellerPhone: '+233209988776',
    postedAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    imageUrl: 'assets/images/iphone11-white.jpg',
    description:
        'Battery health at 87%. Small scratch on the back glass, screen '
        'is flawless. Comes with a case and unused screen protector.',
  ),
];
