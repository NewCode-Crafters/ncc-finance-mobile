import 'package:flutter/material.dart';

class ChartAnimationNotifier extends ChangeNotifier {
  bool _shouldAnimateCharts = false;
  bool _chartsVisible = false;
  int _currentTabIndex = 0;

  bool get shouldAnimateCharts => _shouldAnimateCharts;
  bool get chartsVisible => _chartsVisible;
  int get currentTabIndex => _currentTabIndex;

  void onTabAnimationComplete(int tabIndex) {
    _currentTabIndex = tabIndex;
    _shouldAnimateCharts = true;
    notifyListeners();
    
    // Após a animação do gráfico, mantém visível
    Future.delayed(const Duration(milliseconds: 1200), () {
      _shouldAnimateCharts = false;
      _chartsVisible = true;
      notifyListeners();
    });
  }

  void resetAnimation() {
    _shouldAnimateCharts = false;
    _chartsVisible = false;
    notifyListeners();
  }
}