import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';

class DebugTool extends StatefulWidget {
  final String groupId;

  const DebugTool({super.key, required this.groupId});

  @override
  State<DebugTool> createState() => _DebugToolState();
}

class _DebugToolState extends State<DebugTool> {
  final TextEditingController _memberIdController = TextEditingController();
  String _statusMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _memberIdController.dispose();
    super.dispose();
  }

  Future<void> _forceRemoveMember() async {
    final memberId = _memberIdController.text.trim();

    if (memberId.isEmpty) {
      setState(() {
        _statusMessage = 'Bitte geben Sie eine Mitglieds-ID ein';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Lösche Mitglied mit ID: $memberId...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final groupRef = firestore.collection('groups').doc(widget.groupId);

      // Direkte Transaktion zum Löschen des Mitglieds
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(groupRef);

        if (!snapshot.exists) {
          throw Exception('Gruppe nicht gefunden');
        }

        final data = snapshot.data()!;

        // Alle relevanten Felder abrufen
        final List<String> memberIds =
            List<String>.from(data['groupMemberIds'] ?? []);
        final Map<String, dynamic> userRoles =
            Map<String, dynamic>.from(data['userRoles'] ?? {});
        final Map<String, dynamic> passiveData =
            Map<String, dynamic>.from(data['passiveMembersData'] ?? {});

        // Vor dem Löschen Status überprüfen
        final bool wasInMemberIds = memberIds.contains(memberId);
        final bool wasInUserRoles = userRoles.containsKey(memberId);
        final bool wasInPassiveData = passiveData.containsKey(memberId);

        // Aus allen Listen entfernen
        memberIds.remove(memberId);
        userRoles.remove(memberId);
        passiveData.remove(memberId);

        // Gruppe aktualisieren
        transaction.update(groupRef, {
          'groupMemberIds': memberIds,
          'userRoles': userRoles,
          'passiveMembersData': passiveData,
        });

        setState(() {
          _statusMessage = '''
Mitglied direkt gelöscht:
- War in memberIds: $wasInMemberIds
- War in userRoles: $wasInUserRoles
- War in passiveMembersData: $wasInPassiveData

HINWEIS: App neu starten, um UI zu aktualisieren!
          ''';
        });
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Fehler: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Eine Methode, um alle Daten der Gruppe anzuzeigen
  Future<void> _showGroupData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Lade Gruppendaten...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final groupRef = firestore.collection('groups').doc(widget.groupId);
      final snapshot = await groupRef.get();

      if (!snapshot.exists) {
        throw Exception('Gruppe nicht gefunden');
      }

      final data = snapshot.data()!;

      // Relevante Felder extrahieren
      final List<String> memberIds =
          List<String>.from(data['groupMemberIds'] ?? []);
      final Map<String, dynamic> passiveData =
          Map<String, dynamic>.from(data['passiveMembersData'] ?? {});

      setState(() {
        _statusMessage = '''
GRUPPENDATEN:

Mitglieder-IDs (${memberIds.length}):
${memberIds.join('\n')}

Passive Mitglieder (${passiveData.length}):
${passiveData.keys.join('\n')}
        ''';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Fehler: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Eine Methode, um die App zu aktualisieren
  void _forceReloadApp() {
    setState(() {
      _statusMessage = 'App-Reload ausgelöst. Bitte starten Sie die App neu.';
    });

    // Löschen des Caches
    FirebaseFirestore.instance.clearPersistence();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Debug-Werkzeug'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _memberIdController,
              decoration: const InputDecoration(
                labelText: 'Mitglieds-ID',
                hintText: 'ID des zu löschenden Mitglieds',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _forceRemoveMember,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.famkaRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mitglied direkt entfernen'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showGroupData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.famkaBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Gruppendaten anzeigen'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _forceReloadApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.famkaGrey,
                foregroundColor: Colors.white,
              ),
              child: const Text('App-Cache leeren'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.famkaBlue),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_statusMessage),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Schließen'),
        ),
      ],
    );
  }
}
