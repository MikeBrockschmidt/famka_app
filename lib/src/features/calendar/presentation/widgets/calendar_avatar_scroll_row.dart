import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/profil_avatar.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';

class CalendarAvatarScrollRow extends StatelessWidget {
  final DatabaseRepository db;
  final ScrollController horizontalScrollControllerTop;
  final List<AppUser> groupMembers;
  final double personColumnWidth;
  final ScrollPhysics? scrollPhysics;

  const CalendarAvatarScrollRow(
    this.db, {
    super.key,
    required this.horizontalScrollControllerTop,
    required this.groupMembers,
    required this.personColumnWidth,
    this.scrollPhysics,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: horizontalScrollControllerTop,
      physics: scrollPhysics ?? const BouncingScrollPhysics(),
      child: Row(
        children: groupMembers.map((user) {
          return SizedBox(
            width: personColumnWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfilAvatar(user: user),
                const SizedBox(height: 0),
                Text(
                  user.firstName,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
