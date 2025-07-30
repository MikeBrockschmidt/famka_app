import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image3.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image.dart';
import 'package:famka_app/src/common/image_selection_context.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';

class GroupAvatar extends StatelessWidget {
  final DatabaseRepository db;
  final String groupAvatarUrl; // Dies ist jetzt String (nicht nullable)
  final Function(String newAvatarUrl) onAvatarChanged;
  final bool isUserAdmin;
  final Group currentGroup;

  const GroupAvatar({
    super.key,
    required this.db,
    required this.groupAvatarUrl, // Und hier auch String
    required this.onAvatarChanged,
    required this.isUserAdmin,
    required this.currentGroup,
  });

  Future<void> _changeGroupAvatar(BuildContext context) async {
    if (!isUserAdmin) return;

    final String? newAvatarUrl = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: ProfilImage(
            db,
            currentAvatarUrl:
                groupAvatarUrl, // Sollte hier passen, da groupAvatarUrl jetzt String ist
            contextType: ImageSelectionContext.group,
            onAvatarSelected: (url) {
              Navigator.pop(context, url);
            },
          ),
        );
      },
    );

    if (newAvatarUrl != null && newAvatarUrl != groupAvatarUrl) {
      onAvatarChanged(
          newAvatarUrl); // Ruft die Callback-Funktion in GroupPage auf
      // Die Speicherung in der DB und SnackBar-Nachrichten werden jetzt über den Callback in GroupPage gehandhabt
      // da der 'onAvatarChanged' in GroupPage bereits die Speicherung übernimmt.
      // Der nachfolgende Try-Catch-Block ist hier nicht mehr nötig, da _onGroupAvatarChanged in GroupPage das übernimmt.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: isUserAdmin ? () => _changeGroupAvatar(context) : null,
        behavior: HitTestBehavior.opaque,
        child: ProfilImage3(
          db: db,
          avatarUrl:
              groupAvatarUrl, // Sollte hier passen, da groupAvatarUrl jetzt String ist
          onAvatarChanged: onAvatarChanged, // Weitergabe des Callbacks
        ),
      ),
    );
  }
}
