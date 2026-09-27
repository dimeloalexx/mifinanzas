import 'package:flutter/material.dart';

enum CategoryKind { ingreso, gasto }

class CategoryItem {
  final String name;
  final CategoryKind kind;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.name,
    required this.kind,
    required this.icon,
    required this.color,
  });
}

const List<CategoryItem> defaultCategories = [
  CategoryItem(
      name: 'Salario',
      kind: CategoryKind.ingreso,
      icon: Icons.payments,
      color: Color(0xFF2E7D32)),
  CategoryItem(
      name: 'Ventas',
      kind: CategoryKind.ingreso,
      icon: Icons.storefront,
      color: Color(0xFF388E3C)),
  CategoryItem(
      name: 'Otros ingresos',
      kind: CategoryKind.ingreso,
      icon: Icons.add_circle,
      color: Color(0xFF43A047)),
  CategoryItem(
      name: 'Comida',
      kind: CategoryKind.gasto,
      icon: Icons.restaurant,
      color: Color(0xFFE64A19)),
  CategoryItem(
      name: 'Transporte',
      kind: CategoryKind.gasto,
      icon: Icons.directions_car,
      color: Color(0xFF1565C0)),
  CategoryItem(
      name: 'Hogar',
      kind: CategoryKind.gasto,
      icon: Icons.home,
      color: Color(0xFF6A1B9A)),
  CategoryItem(
      name: 'Servicios',
      kind: CategoryKind.gasto,
      icon: Icons.receipt_long,
      color: Color(0xFF00838F)),
  CategoryItem(
      name: 'Salud',
      kind: CategoryKind.gasto,
      icon: Icons.local_hospital,
      color: Color(0xFFC2185B)),
  CategoryItem(
      name: 'Entretenimiento',
      kind: CategoryKind.gasto,
      icon: Icons.movie,
      color: Color(0xFFF9A825)),
  CategoryItem(
      name: 'Educación',
      kind: CategoryKind.gasto,
      icon: Icons.school,
      color: Color(0xFF283593)),
  CategoryItem(
      name: 'Compras',
      kind: CategoryKind.gasto,
      icon: Icons.shopping_bag,
      color: Color(0xFFAD1457)),
  CategoryItem(
      name: 'Otros gastos',
      kind: CategoryKind.gasto,
      icon: Icons.category,
      color: Color(0xFF616161)),
];

CategoryItem categoryByName(String name) {
  return defaultCategories.firstWhere(
    (c) => c.name == name,
    orElse: () => defaultCategories.last,
  );
}

const Map<String, IconData> customCategoryIcons = {
  'pets': Icons.pets,
  'flight': Icons.flight,
  'card_giftcard': Icons.card_giftcard,
  'phone_iphone': Icons.phone_iphone,
  'fitness_center': Icons.fitness_center,
  'child_care': Icons.child_care,
  'sports_soccer': Icons.sports_esports,
  'local_cafe': Icons.local_cafe,
  'local_bar': Icons.local_bar,
  'checkroom': Icons.checkroom,
  'build': Icons.build,
  'spa': Icons.spa,
  'pool': Icons.pool,
  'directions_bike': Icons.directions_bike,
  'work': Icons.work,
  'attach_money': Icons.attach_money,
  'star': Icons.star,
  'favorite': Icons.favorite,
};

const List<Color> customCategoryColors = [
  Color(0xFF2E7D32),
  Color(0xFF388E3C),
  Color(0xFF00897B),
  Color(0xFF1565C0),
  Color(0xFF5E35B1),
  Color(0xFF8E24AA),
  Color(0xFFAD1457),
  Color(0xFFD84315),
  Color(0xFFEF6C00),
  Color(0xFFF9A825),
  Color(0xFF616161),
  Color(0xFF37474F),
];

class CustomCategory {
  final String id;
  final String name;
  final CategoryKind kind;
  final String iconKey;
  final int colorValue;

  CustomCategory({
    required this.id,
    required this.name,
    required this.kind,
    required this.iconKey,
    required this.colorValue,
  });

  CategoryItem toCategoryItem() {
    return CategoryItem(
      name: name,
      kind: kind,
      icon: customCategoryIcons[iconKey] ?? Icons.category,
      color: Color(colorValue),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'kind': kind.name,
      'iconKey': iconKey,
      'colorValue': colorValue,
    };
  }

  factory CustomCategory.fromMap(Map<String, dynamic> map) {
    return CustomCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      kind: CategoryKind.values.firstWhere((e) => e.name == map['kind']),
      iconKey: map['iconKey'] as String,
      colorValue: map['colorValue'] as int,
    );
  }
}
