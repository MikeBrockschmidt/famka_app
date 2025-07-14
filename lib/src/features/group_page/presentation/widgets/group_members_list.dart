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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Row(
          children: members.map((member) {
            ImageProvider<Object> memberImageProvider;

            if (member.avatarUrl != null) {
              if (member.avatarUrl!.startsWith('http://') ||
                  member.avatarUrl!.startsWith('https://')) {
                memberImageProvider = NetworkImage(member.avatarUrl!);
              } else if (member.avatarUrl!.startsWith('assets/')) {
                memberImageProvider = AssetImage(member.avatarUrl!);
              } else {
                final file = File(member.avatarUrl!);
                if (file.existsSync()) {
                  memberImageProvider = FileImage(file);
                } else {
                  debugPrint(
                      'Warnung: Lokales Bild konnte nicht geladen werden: ${member.avatarUrl}. Verwende Default.jpg');
                  memberImageProvider =
                      const AssetImage('assets/fotos/default.jpg');
                }
              }
            } else {
              memberImageProvider =
                  const AssetImage('assets/fotos/default.jpg');
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(40),
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
                        const SizedBox(
                          width: 70,
                          height: 70,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.famkaBlack,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 58,
                          height: 58,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.famkaWhite,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: memberImageProvider,
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  debugPrint(
                                      'Error loading member avatar: $exception');
                                },
                              ),
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
