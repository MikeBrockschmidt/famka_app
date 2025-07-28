// lib/src/features/calendar/presentation/widgets/menu_sub_container_two_lines_group_c.dart
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/group_page/presentation/group_page.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/common/image_utils.dart';

class MenuSubContainerTwoLinesGroupC extends StatelessWidget {
  final DatabaseRepository db;
  final Group currentGroup;
  final ValueChanged<Group> onGroupUpdated;
  final AppUser currentUser;
  final AuthRepository auth;

  const MenuSubContainerTwoLinesGroupC(
    this.db, {
    super.key,
    required this.currentGroup,
    required this.onGroupUpdated,
    required this.currentUser,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(
          thickness: 1,
          height: 1,
          color: Colors.grey,
        ),
        InkWell(
          onTap: () {
            onGroupUpdated(currentGroup);
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
              top: 12.0,
              left: 20.0,
              bottom: 14.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage:
                      getDynamicImageProvider(currentGroup.groupAvatarUrl),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentGroup.groupName,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  height: 0.9,
                                ),
                          ),
                          const SizedBox(height: 2),
                          // KORREKTUR: Null-Safety für groupLocation
                          Text(
                            currentGroup.groupLocation ??
                                '', // Hinzufügen von ?? ''
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall, // Original-Stil beibehalten
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final Group? updatedGroup = await Navigator.push<Group>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupPage(
                          db: db,
                          group:
                              currentGroup, // currentGroup: currentGroup hier beibehalten, da es im Original war
                          currentUser: currentUser,
                          auth: auth,
                        ),
                      ),
                    );
                    if (updatedGroup != null) {
                      onGroupUpdated(updatedGroup);
                    }
                  },
                  iconSize: 16,
                  color: Colors.black,
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
