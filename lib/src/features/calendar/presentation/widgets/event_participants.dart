import 'package:flutter/material.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

class EventParticipants extends StatelessWidget {
  final List<AppUser> participants;

  const EventParticipants({
    super.key,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    final names = participants.map((u) => u.firstName).join(', ');
    return Text(
      AppLocalizations.of(context)!.participants(names),
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
