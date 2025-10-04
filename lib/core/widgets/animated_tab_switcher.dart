import 'package:flutter/material.dart';

/// Widget que combina animações de slide e fade para transições entre telas
class SlideAndFadeTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final Offset? slideDirection;

  const SlideAndFadeTransition({
    Key? key,
    required this.child,
    required this.animation,
    this.slideDirection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: slideDirection ?? const Offset(1.0, 0.0), // Slide da direita
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
        )),
        child: child,
      ),
    );
  }
}

/// Widget personalizado para animação entre abas do menu inferior
/// Mantém o estado dos widgets usando IndexedStack com animações sobrepostas
class AnimatedTabSwitcher extends StatefulWidget {
  final int selectedIndex;
  final List<Widget> children;
  final Duration duration;

  const AnimatedTabSwitcher({
    Key? key,
    required this.selectedIndex,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<AnimatedTabSwitcher> createState() => _AnimatedTabSwitcherState();
}

class _AnimatedTabSwitcherState extends State<AnimatedTabSwitcher>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _previousIndex = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _previousIndex = widget.selectedIndex;
    
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );
  }

  @override
  void didUpdateWidget(AnimatedTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = _currentIndex;
      _currentIndex = widget.selectedIndex;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // IndexedStack mantém o estado de todos os widgets
        IndexedStack(
          index: _currentIndex,
          children: widget.children,
        ),
        // Overlay de animação apenas durante a transição
        if (_animationController.isAnimating)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final slideDirection = _currentIndex > _previousIndex
                  ? const Offset(1.0, 0.0)  // Da direita para esquerda
                  : const Offset(-1.0, 0.0); // Da esquerda para direita
              
              return SlideTransition(
                position: Tween<Offset>(
                  begin: slideDirection,
                  end: Offset.zero,
                ).animate(_animation),
                child: FadeTransition(
                  opacity: _animation,
                  child: IndexedStack(
                    index: _currentIndex,
                    children: widget.children,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}