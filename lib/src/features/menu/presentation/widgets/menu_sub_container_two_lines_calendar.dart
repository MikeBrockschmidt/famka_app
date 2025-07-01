import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/calendar/presentation/calendar_screen.dart';
import 'package:famka_app/src/features/group_page/presentation/group_page.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/data/app_user.dart';

class MenuSubContainer2LinesCalendar extends StatelessWidget {
  final DatabaseRepository db;
  final Group group;
  final bool isIconWhite;
  final AppUser currentUser;

  const MenuSubContainer2LinesCalendar(
    this.db, {
    super.key,
    required this.group,
    this.isIconWhite = true,
    required this.currentUser,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupPage(
                        db: db,
                        group: group,
                        currentUser: currentUser,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(group.groupAvatarUrl),
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
                      group.groupLocation,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarScreen(
                            db,
                            currentGroup: group,
                            currentUser: currentUser,
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
