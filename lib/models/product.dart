import 'package:flutter/material.dart';

@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    this.description,
  });

  final String id;
  final String name;
  final double price;
  final IconData icon;
  final String? description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

const sampleProducts = <Product>[
  Product(
    id: 'travel-mug',
    name: 'Insulated Travel Mug',
    price: 24.99,
    icon: Icons.local_cafe_outlined,
    description: 'A stainless steel mug that keeps drinks hot or cold.',
  ),
  Product(
    id: 'wireless-headphones',
    name: 'Wireless Headphones',
    price: 89.50,
    icon: Icons.headphones_outlined,
    description: 'Comfortable over-ear headphones for everyday listening.',
  ),
  Product(
    id: 'canvas-backpack',
    name: 'Canvas Backpack',
    price: 54.00,
    icon: Icons.backpack_outlined,
    description: 'A durable backpack with room for daily essentials.',
  ),
  Product(
    id: 'desk-lamp',
    name: 'Adjustable Desk Lamp',
    price: 39.95,
    icon: Icons.lightbulb_outline,
    description: 'A compact lamp with an adjustable arm and warm light.',
  ),
  Product(
    id: 'ceramic-planter',
    name: 'Ceramic Planter',
    price: 18.75,
    icon: Icons.yard_outlined,
    description: 'A glazed ceramic planter for small indoor plants.',
  ),
  Product(
    id: 'fitness-bottle',
    name: 'Fitness Water Bottle',
    price: 16.49,
    icon: Icons.water_drop_outlined,
    description: 'A lightweight reusable bottle for workouts and travel.',
  ),
];
