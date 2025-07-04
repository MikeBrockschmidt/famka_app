import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/onboarding_process3.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/color_row.dart';
import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/onboarding/presentation/onboarding4.dart';
import 'package:famka_app/src/data/user_role.dart';

class Onboarding3Screen extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final AppUser user;

  const Onboarding3Screen(
      {super.key, required this.db, required this.auth, required this.user});

  @override
  State<Onboarding3Screen> createState() => _Onboarding3ScreenState();
}

class _Onboarding3ScreenState extends State<Onboarding3Screen> {
  final TextEditingController _groupNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String _groupAvatarUrl;

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

  void _handleGroupAvatarSelected(String newUrl) {
    setState(() {
      _groupAvatarUrl = newUrl;
    });
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
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
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

  void _createGroupAndNavigate() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newGroupId = widget.db.generateNewGroupId();
      final newGroupName = _groupNameController.text.trim();

      final newGroup = Group(
        groupId: newGroupId,
        groupName: newGroupName,
        groupLocation: '',
        groupDescription: '',
        groupAvatarUrl: _groupAvatarUrl,
        creatorId: widget.user.profilId,
        groupMembers: [widget.user],
        userRoles: {
          widget.user.profilId: UserRole.admin,
        },
      );

      await widget.db.addGroup(newGroup);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Onboarding4(
              db: widget.db,
              auth: widget.auth,
              user: widget.user,
              group: newGroup,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Bitte geben Sie einen Gruppennamen ein."),
          backgroundColor: AppColors.famkaCyan,
        ),
      );
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double bottomReservedSpace = 150.0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ColorRow(),
          ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: OnboardingProgress3(widget.db, widget.auth),
          ),
          Positioned.fill(
            bottom: bottomReservedSpace,
            child: SafeArea(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeadlineK(screenHead: 'Gruppe'),
                    const SizedBox(height: 10),
                    Center(
                      child: Transform.translate(
                        offset: const Offset(0, -16),
                        child: GestureDetector(
                          onTap: _showGroupImageSelectionDialog,
                          child: SizedBox(
                            width: 236,
                            height: 236,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 150,
                                  height: 108,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(12),
                                    image: _groupAvatarUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: AssetImage(_groupAvatarUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _groupAvatarUrl.isEmpty
                                      ? const Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 44,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                                Image.asset(
                                  'assets/grafiken/rahmen.png',
                                  width: 236,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gruppenname',
                                style: Theme.of(context).textTheme.labelSmall),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _groupNameController,
                              decoration: const InputDecoration(
                                hintText:
                                    'Name der Gruppe (z.B. "Meine Familie")',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Bitte geben Sie einen Gruppennamen ein.';
                                }
                                return null;
                              },
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 30.0),
                        child: InkWell(
                          onTap: _createGroupAndNavigate,
                          child: const SizedBox(
                            width: 150,
                            height: 50,
                            child:
                                ButtonLinearGradient(buttonText: 'Fortfahren'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
