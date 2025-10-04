import 'package:flutter/material.dart';

/// Widget personalizado para transição entre abas do menu inferior
/// Mantém estado com IndexedStack e adiciona slide sutil sem piscar
class AnimatedTabSwitcher extends StatefulWidget {
  final int selectedIndex;
  final List<Widget> children;
  final Duration duration;
  final VoidCallback? onAnimationComplete;

  const AnimatedTabSwitcher({
    super.key,
    required this.selectedIndex,
    required this.children,
    this.duration = const Duration(milliseconds: 375), // Aumentado de 250ms para 375ms
    this.onAnimationComplete,
  });

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

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
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