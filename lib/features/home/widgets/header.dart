import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_config.dart';

class Header extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final VoidCallback? onNotificationTap;

  const Header({
    super.key,
    this.onToggleTheme,
    this.onNotificationTap,
  });

  @override
  HeaderState createState() => HeaderState();

  static Widget header({
    Key? key,
    VoidCallback? onToggleTheme,
    VoidCallback? onNotificationTap,
  }) {
    return Header(
      key: key,
      onToggleTheme: onToggleTheme,
      onNotificationTap: onNotificationTap,
    );
  }
}

class HeaderState extends State<Header> {
  int avatarRefreshKey = 0;

  String userName = "User";
  String avatarUrl = "";

  final String defaultAvatar = "assets/icon/logologin.png";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final token = prefs.getString("token");
    final name = prefs.getString("name");
    final image = prefs.getString("image");

    String newName = "Guest";
    String newAvatar = defaultAvatar;

    if (token != null && token.isNotEmpty) {
      newName = (name != null && name.isNotEmpty) ? name : "User";

      if (image != null && image.isNotEmpty) {
        if (image.startsWith("http")) {
          newAvatar = image;
        } else {
          newAvatar = "${ApiConfig.domain}/storage/$image";
        }
      }
    }

    setState(() {
      userName = newName;
      avatarUrl = newAvatar;
      avatarRefreshKey++;
    });
  }

  void refreshFromParent() {
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
          child: ClipOval(
            child: _buildAvatarImage(theme),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Hello, $userName",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Let’s start learning more",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),

        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: widget.onNotificationTap,
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),

        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: widget.onToggleTheme,
        ),
      ],
    );
  }

  Widget _buildAvatarImage(ThemeData theme) {
    if (avatarUrl.startsWith("http")) {
      return Image.network(
        "$avatarUrl?v=$avatarRefreshKey",
        key: ValueKey(avatarRefreshKey),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Icon(
            Icons.person,
            size: 28,
            color: theme.colorScheme.primary,
          );
        },
      );
    }

    return Image.asset(
      avatarUrl,
      key: ValueKey(avatarRefreshKey),
      width: 48,
      height: 48,
      fit: BoxFit.cover,
    );
  }
}