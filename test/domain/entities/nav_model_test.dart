import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/entities/nav_model.dart';
import 'package:flutter/widgets.dart';

void main() {
  test('NavModel holds page and navKey', () {
    final key = GlobalKey<NavigatorState>();
    final widget = Container();
    final model = NavModel(page: widget, navKey: key);

    expect(model.page, equals(widget));
    expect(model.navKey, equals(key));
  });
}
