import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading; // Add leading parameter

  CustomAppBar({required this.title, this.leading}); // Constructor with leading parameter

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading, // Use the leading parameter here
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
