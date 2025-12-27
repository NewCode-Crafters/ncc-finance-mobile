import 'package:equatable/equatable.dart';

class OnboardingItem extends Equatable {
  final String title;
  final String subtitle;
  final String illustrationAsset;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.illustrationAsset,
  });

  OnboardingItem copyWith({
    String? title,
    String? subtitle,
    String? illustrationAsset,
  }) {
    return OnboardingItem(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      illustrationAsset: illustrationAsset ?? this.illustrationAsset,
    );
  }

  @override
  List<Object?> get props => [title, subtitle, illustrationAsset];
}
