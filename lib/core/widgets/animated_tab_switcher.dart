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

/// Widget personalizado para transição entre abas do menu inferior
/// Mantém estado com IndexedStack e adiciona slide sutil sem piscar
class AnimatedTabSwitcher extends StatefulWidget {
  final int selectedIndex;
  final List<Widget> children;
  final Duration duration;

  const AnimatedTabSwitcher({
    Key? key,
    required this.selectedIndex,
    required this.children,
    this.duration = const Duration(milliseconds: 250),
  }) : super(key: key);

  @override
  State<AnimatedTabSwitcher> createState() => _AnimatedTabSwitcherState();
}

class _AnimatedTabSwitcherState extends State<AnimatedTabSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(AnimatedTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      final isMovingRight = widget.selectedIndex > _previousIndex;
      
      _slideAnimation = Tween<Offset>(
        begin: isMovingRight ? const Offset(0.15, 0) : const Offset(-0.15, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      
      _fadeAnimation = Tween<double>(
        begin: 0.4, // Começa com opacidade mais baixa para fade mais forte
        end: 1.0,   // Termina totalmente opaco
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      
      _previousIndex = widget.selectedIndex;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: widget.selectedIndex,
          children: widget.children,
        ),
      ),
    );
  }
}