import 'package:famka_app/src/features/group_page/presentation/widgets/group_image.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image.dart';
import 'package:famka_app/src/common/image_selection_context.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'dart:io';

class GroupAvatar extends StatelessWidget {
  final DatabaseRepository db;
  final String groupAvatarUrl;
  final Function(String newAvatarUrl) onAvatarChanged;
  final bool isUserAdmin;
  final bool isUserMember;
  final Group currentGroup;

  const GroupAvatar({
    super.key,
    required this.db,
    required this.groupAvatarUrl,
    required this.onAvatarChanged,
    required this.isUserAdmin,
    required this.isUserMember,
    required this.currentGroup,
  });

  Future<void> _changeGroupAvatar(BuildContext context) async {
    if (!(isUserAdmin || isUserMember)) {
      debugPrint(
          'DEBUG: Kein Admin oder Mitglied – Avatar-Änderung abgebrochen.');
      return;
    }

    debugPrint('DEBUG: Öffne Avatar-Auswahl als Modal...');

    final String? newAvatarUrl = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: GroupImage(
            db,
            currentAvatarUrl: groupAvatarUrl,
            contextType: ImageSelectionContext.group,
            onAvatarSelected: (url) {
              Navigator.pop(context, url);
            },
          ),
        );
      },
    );

    if (newAvatarUrl != null && newAvatarUrl != groupAvatarUrl) {
      debugPrint('DEBUG: Avatar geändert – Callback wird aufgerufen.');
      onAvatarChanged(newAvatarUrl);
    } else {
      debugPrint('DEBUG: Avatar nicht geändert oder abgebrochen.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String effectiveUrl = (groupAvatarUrl.isEmpty)
        ? 'assets/grafiken/famka-kreis.png'
        : groupAvatarUrl;

    ImageProvider imageProvider;
    if (effectiveUrl.startsWith('http')) {
      imageProvider = NetworkImage(effectiveUrl);
    } else if (effectiveUrl.startsWith('assets/')) {
      imageProvider = AssetImage(effectiveUrl);
    } else if (File(effectiveUrl).existsSync()) {
      imageProvider = FileImage(File(effectiveUrl));
    } else {
      imageProvider = const AssetImage('assets/grafiken/famka-kreis.png');
    }

    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint('DEBUG: Tap auf Avatar erkannt.');
          if (isUserAdmin || isUserMember) {
            _changeGroupAvatar(context);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 100,
              backgroundColor: Colors.grey[300],
              backgroundImage: imageProvider,
            ),
          ],
        ),
      ),
    );
  }
}
