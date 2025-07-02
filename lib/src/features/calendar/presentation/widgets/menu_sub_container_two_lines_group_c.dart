import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/group_page/presentation/group_page.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/data/app_user.dart';

class MenuSubContainer2LinesGroupC extends StatelessWidget {
  final DatabaseRepository db;
  final Group currentGroup;
  final ValueChanged<Group> onGroupUpdated;
  final AppUser currentUser;

  const MenuSubContainer2LinesGroupC(
    this.db, {
    super.key,
    required this.currentGroup,
    required this.onGroupUpdated,
    required this.currentUser,
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
                  backgroundImage: AssetImage(currentGroup.groupAvatarUrl),
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
                          Text(
                            currentGroup.groupLocation,
                            style: Theme.of(context).textTheme.bodySmall,
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
                          group: currentGroup,
                          currentUser: currentUser,
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
