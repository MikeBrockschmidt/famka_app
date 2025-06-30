import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';

class ProfilImage3 extends StatelessWidget {
  final DatabaseRepository db;
  final String avatarUrl;
  final Function(String)? onAvatarChanged;

  const ProfilImage3({
    super.key,
    required this.db,
    required this.avatarUrl,
    this.onAvatarChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onAvatarChanged != null) {
          onAvatarChanged!(avatarUrl);
        }
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade300,
        ),
        child: ClipOval(
          child: Image.asset(
            avatarUrl,
            fit: BoxFit.cover,
            width: 140,
            height: 140,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 140,
                height: 140,
                color: Colors.grey.shade300,
                child: Icon(
                  Icons.group,
                  size: 80,
                  color: Colors.grey.shade600,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
