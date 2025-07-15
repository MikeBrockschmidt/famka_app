import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/image_utils.dart';

class ProfilAvatar extends StatelessWidget {
  final AppUser user;

  const ProfilAvatar({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final ImageProvider<Object>? userImageProvider =
        getDynamicImageProvider(user.avatarUrl);

    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 39, 60, 69),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: userImageProvider ??
                    const AssetImage('assets/fotos/default.jpg'),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  debugPrint(
                      'Fehler beim Laden des Profilbildes für ${user.profilId}: $exception');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
