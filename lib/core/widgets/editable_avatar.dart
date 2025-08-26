import 'package:flutter/material.dart';

class EditableAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onEditPressed;

  const EditableAvatar({super.key, required this.radius, this.onEditPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(radius: radius, child: const Icon(Icons.person, size: 50)),
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
