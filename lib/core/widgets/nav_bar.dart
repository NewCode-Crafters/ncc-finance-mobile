import 'dart:io';

import 'package:bytebank/core/utils/color_helper.dart';
import 'package:bytebank/theme/theme.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int pageIndex;
  final Function(int) onTap;

  const NavBar({super.key, required this.pageIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0.0,
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: Platform.isAndroid ? 10 : 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.cardSaldoGradient,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                navItem(
                  Icons.home_outlined,
                  pageIndex == 0,
                  onTap: () => onTap(0),
                ),
                navItem(
                  Icons.receipt_long,
                  pageIndex == 1,
                  onTap: () => onTap(1),
                ),
                navItem(
                  Icons.insert_chart_outlined_rounded,
                  pageIndex == 2,
                  onTap: () => onTap(2),
                ),
                navItem(
                  Icons.person_outline,
                  pageIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget navItem(IconData icon, bool selected, {Function()? onTap}) {
    return Expanded(
      child: InkWell(
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        onTap: onTap,
        child: Icon(
          icon,
          color: selected ? Colors.white : Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }
}
