import 'package:flutter/material.dart';
import 'package:bytebank/core/utils/color_helper.dart';

class EditableAvatar extends StatelessWidget {
  final double radius;
  final String? photoUrl;
  final VoidCallback? onEditPressed;
  final String? userId;

  const EditableAvatar({
    super.key,
    required this.radius,
    this.photoUrl,
    this.onEditPressed,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
          backgroundColor: photoUrl == null
              ? ColorHelper.getColorFromString(userId ?? "")
              : null,
          child: photoUrl == null
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: radius * 0.3, // Make the edit icon proportional
            backgroundColor: Colors.grey.shade300,
            child: IconButton(
              icon: Icon(Icons.edit, size: radius * 0.3),
              onPressed: onEditPressed,
            ),
          ),
        ),
      ],
    );
  }
}
