import 'package:flutter/material.dart';

class ServiceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const ServiceAppBar({
    super.key,
    this.title = ' ',
    this.backgroundColor,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.elevation = 0,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      actions: actions ??
          [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {},
            ),
          ],
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

