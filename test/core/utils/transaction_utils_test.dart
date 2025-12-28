import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/core/utils/transaction_utils.dart';

void main() {
  test('known category ids map to expected icons', () {
    expect(getIconForCategory('SALARY'), Icons.monetization_on);
    expect(getIconForCategory('FOOD'), Icons.fastfood);
    expect(getIconForCategory('HOUSING'), Icons.house);
    expect(getIconForCategory('TRANSPORT'), Icons.directions_car);
    expect(getIconForCategory('LEISURE'), Icons.sports_esports);
    expect(getIconForCategory('HEALTH'), Icons.healing);
    expect(getIconForCategory('EDUCATION'), Icons.school);
    expect(getIconForCategory('SHOPPING'), Icons.shopping_cart);
    expect(getIconForCategory('INVESTMENT'), Icons.bar_chart);
    expect(getIconForCategory('INVESTMENT_REDEMPTION'), Icons.account_balance_wallet);
  });

  test('unknown category returns default icon', () {
    expect(getIconForCategory('UNKNOWN_CATEGORY'), Icons.category);
  });
}
