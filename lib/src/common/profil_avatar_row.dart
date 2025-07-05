import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/group_page/presentation/group_page.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart'; // NEU: AuthRepository importieren

class ProfilAvatarRow extends StatelessWidget {
  final DatabaseRepository db;
  final Group? group;
  final AppUser currentUser;
  final AuthRepository auth; // NEU: AuthRepository als Parameter hinzufügen

  const ProfilAvatarRow(
    this.db, {
    super.key,
    this.group,
    required this.currentUser,
    required this.auth, // NEU: Muss jetzt übergeben werden
  });

  @override
  Widget build(BuildContext context) {
    if (group == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: () {
            // Navigieren zur GroupPage und alle benötigten Parameter übergeben
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupPage(
                  db: db,
                  group: group!,
                  currentUser: currentUser,
                  auth: auth, // KORREKTUR: auth-Parameter übergeben
                ),
              ),
            );
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
                    image: AssetImage(group!.groupAvatarUrl),
                    fit: BoxFit.cover,
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
            group!.groupName,
            style:
                Theme.of(context).textTheme.displaySmall?.copyWith(height: 1.0),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
