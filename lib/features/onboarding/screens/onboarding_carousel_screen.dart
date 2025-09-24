import 'package:bytebank/features/onboarding/models/onboarding_item.dart';
import 'package:bytebank/theme/theme.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:bytebank/features/authentication/screens/login_screen.dart';
import 'package:flutter/material.dart';

class OnboardingCarouselScreen extends StatefulWidget {
  static const routeName = '/onboarding';
  const OnboardingCarouselScreen({super.key});

  @override
  State<OnboardingCarouselScreen> createState() =>
      _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState extends State<OnboardingCarouselScreen> {
  int _current = 0;

  final _items = const [
    OnboardingItem(
      title: 'Acesse seus dados a qualquer lugar',
      subtitle:
          'Seus dados no ByteBank estão disponíveis a qualquer hora e em qualquer lugar.',
      illustrationAsset: 'assets/images/onboarding/illustration-1.png',
    ),
    OnboardingItem(
      title: 'Relatórios financeiros completos',
      subtitle:
          'Relatórios detalhados de despesas e receitas para você entender melhor suas finanças.',
      illustrationAsset: 'assets/images/onboarding/illustration-2.png',
    ),
    OnboardingItem(
      title: 'Seus dados estão seguros',
      subtitle:
          'Suas informações são protegidas e ficam disponíveis sempre que você precisar.',
      illustrationAsset: 'assets/images/onboarding/illustration-3.png',
    ),
    OnboardingItem(
      title: 'Valorizamos seu feedback',
      subtitle:
          'Ouvimos suas sugestões e trabalhamos continuamente para melhorar a experiência.',
      illustrationAsset: 'assets/images/onboarding/illustration-4.png',
    ),
    OnboardingItem(
      title: 'Bem-vindo ao ByteBank!',
      subtitle:
          'Estamos felizes em tê-lo conosco. Vamos começar a gerenciar suas finanças de forma simples e eficiente.',
      illustrationAsset: 'assets/images/onboarding/illustration-5.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFC6E0AE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Make the carousel flexible so the button remains pinned
              // to the bottom of the screen. Carousel and dots live inside
              // the Expanded area.
              Expanded(
                child: Column(
                  children: [
                    // Carousel fills available space inside Expanded
                    Expanded(
                      child: CarouselSlider.builder(
                        itemCount: _items.length,
                        options: CarouselOptions(
                          // Force a taller carousel so each card has more height
                          // and the background image is less cropped.
                          height: MediaQuery.of(context).size.height * 0.72,
                          viewportFraction: 0.92,
                          enableInfiniteScroll: false,
                          enlargeCenterPage: true,
                          onPageChanged: (index, _) =>
                              setState(() => _current = index),
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration: const Duration(
                            milliseconds: 600,
                          ),
                          autoPlayCurve: Curves.easeOutCubic,
                        ),
                        itemBuilder: (context, index, _) {
                          final item = _items[index];
                          return SizedBox(
                            height: double.infinity,
                            child: _OnboardingCard(item: item),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_items.length, (i) {
                        final isActive = i == _current;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: isActive ? 22 : 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? cs.primary
                                : cs.primary.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Bottom button stays fixed at the bottom of the screen
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(LoginScreen.routeName),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: appTheme.colorScheme.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Começar'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final OnboardingItem item;
  const _OnboardingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.primary.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // inner clip ensures the background image is rounded to match the
      // outer container radius while the outer container still shows the
      // border and shadow.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Full-card background image
            Positioned.fill(
              child: Image.asset(
                item.illustrationAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: cs.surface),
              ),
            ),

            // Subtle overlay to keep image vivid while ensuring
            // the bottom panel remains readable. Avoid heavy dark tints.
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.28),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom content panel: semi-opaque background so texts remain
            // readable while anchored to the bottom of the card.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.86),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.subtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: appTheme.colorScheme.surface,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
