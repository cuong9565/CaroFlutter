import 'package:flutter/material.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.size,
  });

  final String name;
  final String? avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey[300],
      child: hasAvatar
          ? ClipOval(
              child: Image.network(
                avatarUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    letter,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            )
          : Text(
              letter,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
