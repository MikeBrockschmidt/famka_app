import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddOrJoinGroupScreen extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final AppUser currentUser;

  const AddOrJoinGroupScreen({
    super.key,
    required this.db,
    required this.auth,
    required this.currentUser,
  });

  @override
  State<AddOrJoinGroupScreen> createState() => _AddOrJoinGroupScreenState();
}

class _AddOrJoinGroupScreenState extends State<AddOrJoinGroupScreen> {
  final TextEditingController _newGroupNameController = TextEditingController();
  final TextEditingController _newGroupDescriptionController =
      TextEditingController();
  final TextEditingController _newGroupLocationController =
      TextEditingController();
  final GlobalKey<FormState> _createGroupFormKey = GlobalKey<FormState>();

  final TextEditingController _joinGroupIdController = TextEditingController();
  final GlobalKey<FormState> _joinGroupFormKey = GlobalKey<FormState>();

  final Uuid _uuid = const Uuid();

  late String _groupAvatarUrl;
  bool _isPickingImage = false;

  final List<String> _availableGroupImages = [
    'assets/fotos/Familie.jpg',
    'assets/fotos/Melanie.jpg',
    'assets/fotos/Max.jpg',
    'assets/fotos/Martha.jpg',
    'assets/fotos/boyd.jpg',
    'assets/fotos/default.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _groupAvatarUrl = 'assets/fotos/default.jpg';
  }

  @override
  void dispose() {
    _newGroupNameController.dispose();
    _newGroupDescriptionController.dispose();
    _newGroupLocationController.dispose();
    _joinGroupIdController.dispose();
    super.dispose();
  }

  void _handleGroupAvatarSelected(String newUrl) {
    setState(() {
      _groupAvatarUrl = newUrl;
    });
  }

  Future<void> _pickImageLocally(ImageSource source) async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 200,
        maxHeight: 200,
      );

      if (pickedFile != null) {
        final String localPath = pickedFile.path;
        _handleGroupAvatarSelected(localPath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Gruppenbild ausgewählt und lokal angezeigt.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kein Bild ausgewählt.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler bei der Bildauswahl: $e'),
            backgroundColor: AppColors.famkaRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  void _showGroupImageSelectionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Wähle ein Gruppenbild aus',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Aus Galerie wählen'),
                onTap: () => _pickImageLocally(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Foto aufnehmen'),
                onTap: () => _pickImageLocally(ImageSource.camera),
              ),
              const Divider(),
              Text(
                'Oder wähle ein Standardbild:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _availableGroupImages.length,
                  itemBuilder: (context, index) {
                    final imageUrl = _availableGroupImages[index];
                    return GestureDetector(
                      onTap: () {
                        _handleGroupAvatarSelected(imageUrl);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _groupAvatarUrl == imageUrl
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                          image: DecorationImage(
                            image: AssetImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createGroup() async {
    if (!(_createGroupFormKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text("Bitte füllen Sie alle erforderlichen Felder aus."),
          backgroundColor: AppColors.famkaRed,
        ),
      );
      return;
    }

    final String groupId = _uuid.v4();
    final String groupName = _newGroupNameController.text.trim();
    final String groupDescription = _newGroupDescriptionController.text.trim();
    final String groupLocation = _newGroupLocationController.text.trim();

    final String finalGroupAvatarUrl = _groupAvatarUrl;

    final Map<String, UserRole> userRoles = {
      widget.currentUser.profilId: UserRole.admin,
    };

    final List<AppUser> groupMembers = [
      widget.currentUser,
    ];

    final Group newGroup = Group(
      groupId: groupId,
      groupName: groupName,
      groupLocation: groupLocation,
      groupDescription: groupDescription,
      groupAvatarUrl: finalGroupAvatarUrl,
      creatorId: widget.currentUser.profilId,
      groupMembers: groupMembers,
      userRoles: userRoles,
    );

    try {
      await widget.db.addGroup(newGroup);
      widget.db.currentGroup = newGroup;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gruppe '$groupName' erfolgreich erstellt!"),
            backgroundColor: AppColors.famkaCyan,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Fehler beim Erstellen der Gruppe: $e"),
            backgroundColor: AppColors.famkaRed,
          ),
        );
      }
    }
  }

  Future<void> _joinGroup() async {
    if (!(_joinGroupFormKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Bitte geben Sie eine Gruppen-ID ein."),
          backgroundColor: AppColors.famkaRed,
        ),
      );
      return;
    }

    final String groupIdToJoin = _joinGroupIdController.text.trim();

    try {
      final Group? existingGroup = await widget.db.getGroupAsync(groupIdToJoin);

      if (existingGroup == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gruppe mit dieser ID nicht gefunden."),
              backgroundColor: AppColors.famkaRed,
            ),
          );
        }
        return;
      }

      if (existingGroup.groupMembers
          .any((member) => member.profilId == widget.currentUser.profilId)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sie sind bereits Mitglied dieser Gruppe."),
              backgroundColor: AppColors.famkaCyan,
            ),
          );
          widget.db.currentGroup = existingGroup;
          Navigator.pop(context);
        }
        return;
      }

      await widget.db.addUserToGroup(widget.currentUser, groupIdToJoin);

      final Map<String, UserRole> updatedUserRoles =
          Map.from(existingGroup.userRoles);
      updatedUserRoles[widget.currentUser.profilId] = UserRole.member;

      final Group updatedGroup = existingGroup.copyWith(
        userRoles: updatedUserRoles,
      );
      await widget.db.updateGroup(updatedGroup);

      widget.db.currentGroup = updatedGroup;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Sie sind der Gruppe '${existingGroup.groupName}' beigetreten!"),
            backgroundColor: AppColors.famkaCyan,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Fehler beim Beitreten der Gruppe: $e"),
            backgroundColor: AppColors.famkaRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider groupImageProvider;
    if (_groupAvatarUrl.startsWith('http')) {
      groupImageProvider = NetworkImage(_groupAvatarUrl);
    } else if (_groupAvatarUrl.startsWith('assets/')) {
      groupImageProvider = AssetImage(_groupAvatarUrl);
    } else {
      try {
        final file = File(_groupAvatarUrl);
        if (file.existsSync()) {
          groupImageProvider = FileImage(file);
        } else {
          print(
              'Warnung: Lokales Bild konnte nicht geladen werden: ${_groupAvatarUrl}. Verwende Default.jpg');
          groupImageProvider = const AssetImage('assets/fotos/default.jpg');
        }
      } catch (e) {
        print('Fehler beim Laden des lokalen Bildes: $e. Verwende Default.jpg');
        groupImageProvider = const AssetImage('assets/fotos/default.jpg');
      }
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gruppe hinzufügen oder beitreten'),
          backgroundColor: AppColors.famkaBlue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Gruppe erstellen'),
              Tab(text: 'Gruppe beitreten'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _createGroupFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _isPickingImage
                            ? null
                            : _showGroupImageSelectionDialog,
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: groupImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: _isPickingImage
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : (_groupAvatarUrl.isEmpty ||
                                            _groupAvatarUrl.startsWith(
                                                'assets/fotos/default.jpg'))
                                        ? const Center(
                                            child: Icon(
                                              Icons.image,
                                              size: 60,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _newGroupNameController,
                      decoration: const InputDecoration(
                        labelText: 'Gruppenname',
                        hintText: 'Zuhause, Freunde, Arbeit...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Gruppenname darf nicht leer sein.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newGroupDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Beschreibung (optional)',
                        hintText: 'Eine kurze Beschreibung der Gruppe',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newGroupLocationController,
                      decoration: const InputDecoration(
                        labelText: 'Standort (optional)',
                        hintText: 'Ort der Gruppe, z.B. Stadt oder Adresse',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    InkWell(
                      onTap: _createGroup,
                      child: const ButtonLinearGradient(
                        buttonText: 'Gruppe erstellen',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _joinGroupFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _joinGroupIdController,
                      decoration: const InputDecoration(
                        labelText: 'Gruppen-ID / Einladungscode',
                        hintText: 'Geben Sie den Code der Gruppe ein',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Gruppen-ID darf nicht leer sein.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    InkWell(
                      onTap: _joinGroup,
                      child: const ButtonLinearGradient(
                        buttonText: 'Gruppe beitreten',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Die Gruppen-ID finden Sie in den Einstellungen der Gruppe, wenn Sie bereits Mitglied sind.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
