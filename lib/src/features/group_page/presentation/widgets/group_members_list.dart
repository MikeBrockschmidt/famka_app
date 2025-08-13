import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/profil_page/presentation/profil_page.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'dart:io';

class GroupMembersList extends StatelessWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final AppUser currentUser;
  final List<AppUser> members;

  const GroupMembersList({
    super.key,
    required this.db,
    required this.auth,
    required this.currentUser,
    required this.members,
  });

  ImageProvider<Object> _getMemberImageProvider(AppUser member) {
    if (member.avatarUrl != null) {
      if (member.avatarUrl!.startsWith('http://') ||
          member.avatarUrl!.startsWith('https://')) {
        return NetworkImage(member.avatarUrl!);
      } else if (member.avatarUrl!.startsWith('assets/')) {
        return AssetImage(member.avatarUrl!);
      } else {
        return FileImage(File(member.avatarUrl!));
      }
    } else {
      return const AssetImage('assets/grafiken/famka-kreis.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Row(
          children: members.map((member) {
            final ImageProvider<Object> memberImageProvider =
                _getMemberImageProvider(member);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final AppUser? updatedUser =
                          await db.getUserAsync(member.profilId);

                      if (updatedUser != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilPage(
                              db: db,
                              currentUser: updatedUser,
                              auth: auth,
                              isOwnProfile:
                                  false, // Es ist nicht das eigene Profil
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.famkaCyan,
                            content: Text(
                              'Benutzerdaten können nicht geladen werden!',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
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
                              image: memberImageProvider,
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                debugPrint(
                                    'Fehler beim Laden des Mitglieder-Avatars: $exception');
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 70,
                    child: Text(
                      member.firstName ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(height: 1.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
