import 'package:flutter/material.dart';
import 'package:bytebank/core/utils/color_helper.dart';
import 'package:bytebank/features/profile/notifiers/profile_notifier.dart';
import 'package:bytebank/features/profile/screens/my_profile_screen.dart';
import 'package:provider/provider.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const MainAppBar({super.key, this.title = 'Bytebank'});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<ProfileNotifier>().state.userProfile;

    return AppBar(
      title: Text(title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(MyProfileScreen.routeName);
            },
            child: CircleAvatar(
              backgroundImage: userProfile?.photoUrl != null
                  ? NetworkImage(userProfile!.photoUrl!)
                  : null,
              backgroundColor:
                  userProfile != null && userProfile.photoUrl == null
                  ? ColorHelper.getColorFromString(userProfile.uid)
                  : Colors.grey.shade400,
              child: userProfile?.photoUrl == null
                  ? Text(
                      userProfile?.name.isNotEmpty == true
                          ? userProfile!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
