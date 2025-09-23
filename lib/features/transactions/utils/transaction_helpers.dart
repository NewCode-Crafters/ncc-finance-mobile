import 'package:flutter/material.dart';

IconData getIconForCategory(String categoryId) {
  switch (categoryId) {
    case 'SALARY':
      return Icons.monetization_on;
    case 'FOOD':
      return Icons.fastfood;
    case 'HOUSING':
      return Icons.house;
    case 'TRANSPORT':
      return Icons.directions_car;
    case 'LEISURE':
      return Icons.sports_esports;
    case 'HEALTH':
      return Icons.healing;
    case 'EDUCATION':
      return Icons.school;
    case 'SHOPPING':
      return Icons.shopping_cart;
    case 'INVESTMENT':
      return Icons.bar_chart;
    case 'INVESTMENT_REDEMPTION':
      return Icons.trending_up;
    default:
      return Icons.category;
  }
}
