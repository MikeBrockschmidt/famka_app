import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/calendar/presentation/calendar_screen.dart';
import 'package:famka_app/src/features/group_page/presentation/group_page.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/common/image_utils.dart';

class MenuSubContainer2LinesCalendar extends StatelessWidget {
  final DatabaseRepository db;
  final Group group;
  final bool isIconWhite;
  final AppUser currentUser;
  final AuthRepository auth;

  const MenuSubContainer2LinesCalendar(
    this.db, {
    super.key,
    required this.group,
    this.isIconWhite = true,
    required this.currentUser,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(
            top: 12.0,
            left: 20.0,
            bottom: 14.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  db.currentGroup = group;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupPage(
                        db: db,
                        group: group,
                        currentUser: currentUser,
                        auth: auth,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      getDynamicImageProvider(group.groupAvatarUrl) ??
                          const AssetImage('assets/fotos/default.jpg'),
                  onBackgroundImageError: (exception, stackTrace) {
                    debugPrint(
                        'Fehler beim Laden des Gruppen-Avatars in MenuSubContainer2LinesCalendar: $exception');
                  },
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.groupName,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            height: 0.9,
                          ),
                    ),
                    Text(
                      group.groupLocation ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      db.currentGroup = group;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarScreen(
                            db,
                            currentGroup: group,
                            currentUser: currentUser,
                            auth: auth,
                          ),
                        ),
                      );
                    },
                    iconSize: 20,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
