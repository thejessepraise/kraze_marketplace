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
  final DateTime postedAt;
  final bool isFavorite;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.sellerName,
    required this.postedAt,
    required this.imageUrl,
    this.isFavorite = false,
  });
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
    imageUrl: 'assets/images/calculus.jpg'
  ),
  Product(
    id: '2',
    title: 'HP Pavilion 15" Laptop, 8GB RAM',
    price: 850.00,
    category: 'Laptops',
    sellerName: 'Kwabs Laptops',
    postedAt: DateTime.now().subtract(const Duration(hours: 6)),
    imageUrl: 'assets/images/laptop.jpg'
  ),
  Product(
    id: '3',
    title: 'Casio FX-991 Scientific Calculator',
    price: 18.00,
    category: 'Calculators',
    sellerName: 'Efua B.',
    postedAt: DateTime.now().subtract(const Duration(days: 1)),
    imageUrl: 'assets/images/calculus.jpg'
  ),
  Product(
    id: '4',
    title: 'Hostel Bed Side Table',
    price: 30.00,
    category: 'Furniture',
    sellerName: 'Yaw M.',
    postedAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    imageUrl: 'assets/images/hostelbed.jpg'
  ),
  Product(
    id: '5',
    title: 'PS4 Controller (Wireless)',
    price: 40.00,
    category: 'Gaming',
    sellerName: 'Nana A.',
    postedAt: DateTime.now().subtract(const Duration(days: 2)),
    imageUrl: 'assets/images/Joystick-ps4-greenurba.jpg'
  ),
  Product(
    id: '6',
    title: 'iPhone 11, 64GB, Good Condition',
    price: 400.00,
    category: 'Phones',
    sellerName: 'Abena S.',
    postedAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    imageUrl: 'assets/images/iphone11-white.jpg'
  ),
];