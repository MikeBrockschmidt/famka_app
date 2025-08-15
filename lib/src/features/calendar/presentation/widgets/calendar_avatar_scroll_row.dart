import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/profil_avatar.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';

class CalendarAvatarScrollRow extends StatelessWidget {
  final DatabaseRepository db;
  final ScrollController horizontalScrollControllerTop;
  final List<AppUser> groupMembers;
  final Group? currentGroup;
  final double personColumnWidth;
  final ScrollPhysics? scrollPhysics;

  const CalendarAvatarScrollRow(
    this.db, {
    super.key,
    required this.horizontalScrollControllerTop,
    required this.groupMembers,
    this.currentGroup,
    required this.personColumnWidth,
    this.scrollPhysics,
  });

  List<AppUser> get _sortedGroupMembers {
    if (currentGroup == null) {
      return groupMembers;
    }

    // Hole die korrekte Reihenfolge aus der Gruppe
    final memberOrder =
        currentGroup!.toMap()['groupMemberIds'] as List<dynamic>?;
    if (memberOrder == null || memberOrder.isEmpty) {
      return groupMembers;
    }

    // Sortiere die Mitglieder entsprechend der gespeicherten Reihenfolge
    final sortedMembers = <AppUser>[];
    final memberMap = {
      for (var member in groupMembers) member.profilId: member
    };

    // Füge Mitglieder in der korrekten Reihenfolge hinzu
    for (final memberId in memberOrder) {
      final member = memberMap[memberId];
      if (member != null) {
        sortedMembers.add(member);
      }
    }

    // Füge alle übrigen Mitglieder hinzu, die nicht in der Reihenfolge-Liste sind
    for (final member in groupMembers) {
      if (!sortedMembers.any((m) => m.profilId == member.profilId)) {
        sortedMembers.add(member);
      }
    }

    return sortedMembers;
  }

  @override
  Widget build(BuildContext context) {
    final sortedMembers = _sortedGroupMembers;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: horizontalScrollControllerTop,
      physics: scrollPhysics ?? const BouncingScrollPhysics(),
      child: Row(
        children: sortedMembers.map((user) {
          return SizedBox(
            width: personColumnWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfilAvatar(user: user),
                const SizedBox(height: 0),
                Text(
                  user.firstName.isNotEmpty ? user.firstName : 'Unbekannt',
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
