import 'package:flutter/material.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/single_event_avatar.dart';

class EventParticipantsSelector extends StatefulWidget {
  const EventParticipantsSelector({
    super.key,
    required this.groupMembersFuture,
    required this.initialSelectedMembers,
    required this.onSelectedMembersChanged,
  });

  final Future<List<AppUser>> groupMembersFuture;
  final Set<String> initialSelectedMembers;
  final ValueChanged<Set<String>> onSelectedMembersChanged;

  @override
  State<EventParticipantsSelector> createState() =>
      _EventParticipantsSelectorState();
}

class _EventParticipantsSelectorState extends State<EventParticipantsSelector> {
  late Set<String> _selectedMembers;

  @override
  void initState() {
    super.initState();
    _selectedMembers = Set.from(widget.initialSelectedMembers);
  }

  @override
  void didUpdateWidget(covariant EventParticipantsSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedMembers != oldWidget.initialSelectedMembers) {
      _selectedMembers = Set.from(widget.initialSelectedMembers);
    }
  }

  void _toggleMemberSelection(String memberId) {
    setState(() {
      if (_selectedMembers.contains(memberId)) {
        _selectedMembers.remove(memberId);
      } else {
        _selectedMembers.add(memberId);
      }
      widget.onSelectedMembersChanged(_selectedMembers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.group, color: Colors.black),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Für wen ist der Termin?',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<AppUser>>(
            future: widget.groupMembersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Keine Mitglieder gefunden.'));
              }

              final members = snapshot.data!;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: members.map((member) {
                    final isSelected =
                        _selectedMembers.contains(member.profilId);
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _toggleMemberSelection(member.profilId),
                        child: Column(
                          children: [
                            SingleEventAvatar(
                              isSelected: isSelected,
                              avatarUrl: member.avatarUrl ??
                                  'assets/fotos/default.jpg',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member.firstName ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
