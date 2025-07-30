import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/profil_page/presentation/profil_page.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'dart:io';
// HINWEIS: Du benötigst möglicherweise auch den Import für ImageUtils,
// wenn getDynamicImageProvider nicht bereits in dieser Datei verfügbar ist
// import 'package:famka_app/src/common/image_utils.dart'; // Füge diese Zeile hinzu, falls 'getDynamicImageProvider' benötigt wird

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

  // HINWEIS: Wenn getDynamicImageProvider eine globale oder statische Funktion ist,
  // musst du sicherstellen, dass sie hier verfügbar ist oder den entsprechenden Import hinzufügen.
  // Falls getDynamicImageProvider Teil von ImageUtils ist, benötigst du den Import oben.
  // Für diesen Code nutze ich deine ursprüngliche Logik für memberImageProvider.
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
            // Der ImageProvider wird jetzt über die Hilfsfunktion (_getMemberImageProvider) ermittelt
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
                    // HIER BEGINNT DAS ÜBERNOMMENE STACK-DESIGN
                    child: Stack(
                      alignment: Alignment.center, // Zentriert die Schichten
                      children: [
                        // Äußerer Kreis (dunkelblau, 70x70)
                        Container(
                          width: 70, // Größerer Kreis für den äußeren Rahmen
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(
                                255, 39, 60, 69), // Dunkelblauer Farbton
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Mittlerer Kreis (weiß, 58x58)
                        Container(
                          width: 58, // Mittlerer Kreis für den weißen Rahmen
                          height: 58,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Innerer Kreis mit dem eigentlichen Avatar-Bild (54x54)
                        Container(
                          width: 54, // Kleinster Kreis für das Bild selbst
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image:
                                  memberImageProvider, // Der zuvor ermittelte ImageProvider
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
                    // HIER ENDET DAS ÜBERNOMMENE STACK-DESIGN
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
