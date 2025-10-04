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
/// Mantém o estado dos widgets usando IndexedStack com animações controladas
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
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _fadeInAnimation;
  
  int _previousIndex = 0;
  int _currentIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _previousIndex = widget.selectedIndex;
    
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    
    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
    
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = _currentIndex;
      _currentIndex = widget.selectedIndex;
      setState(() {
        _isAnimating = true;
      });
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
    if (!_isAnimating) {
      // Quando não está animando, mostra apenas o widget atual
      return IndexedStack(
        index: _currentIndex,
        children: widget.children,
      );
    }

    // Durante a animação, controla as transições
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final slideDirection = _currentIndex > _previousIndex
            ? const Offset(1.0, 0.0)  // Da direita para esquerda
            : const Offset(-1.0, 0.0); // Da esquerda para direita

        return Stack(
          children: [
            // Widget anterior saindo (fade out)
            FadeTransition(
              opacity: _fadeOutAnimation,
              child: IndexedStack(
                index: _previousIndex,
                children: widget.children,
              ),
            ),
            // Widget atual entrando (slide + fade in)
            SlideTransition(
              position: Tween<Offset>(
                begin: slideDirection,
                end: Offset.zero,
              ).animate(_slideAnimation),
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: IndexedStack(
                  index: _currentIndex,
                  children: widget.children,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}