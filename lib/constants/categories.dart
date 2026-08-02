import 'package:flutter/material.dart';

/// A single category — just a name paired with an icon to display it.
///
/// WHY A CLASS AND NOT JUST A LIST OF STRINGS:
/// We need both a label ("Textbooks") AND a picture (an icon) for each
/// category. A plain List<String> can't hold both, so we make a tiny class
/// to bundle them together.
class Category {
  final String name;
  final IconData icon;

  const Category(this.name, this.icon);
}

/// The fixed list of categories students can browse or tag their listing with.
///
/// WHY A CONSTANT LIST HERE (not fetched from a database):
/// Categories rarely change, unlike products which are added by users all the
/// time. Hardcoding them keeps the app simple and fast — no network call
/// needed just to show category icons.
const List<Category> kCategories = [
  Category('Textbooks', Icons.menu_book),
  Category('Laptops', Icons.laptop_mac),
  Category('Phones', Icons.smartphone),
  Category('Calculators', Icons.calculate),
  Category('Furniture', Icons.chair),
  Category('Clothing', Icons.checkroom),
  Category('Shoes', Icons.sports),
  Category('Electronics', Icons.headphones),
  Category('Gaming', Icons.sports_esports),
  Category('Other', Icons.category),
];