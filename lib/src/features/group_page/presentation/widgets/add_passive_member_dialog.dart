import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/onboarding/presentation/widgets/profil_image.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:famka_app/src/common/image_selection_context.dart';

class AddPassiveMemberDialog extends StatefulWidget {
  final DatabaseRepository db;
  final Group group;
  final Function() onMemberAdded;

  const AddPassiveMemberDialog({
    super.key,
    required this.db,
    required this.group,
    required this.onMemberAdded,
  });

  @override
  State<AddPassiveMemberDialog> createState() => _AddPassiveMemberDialogState();
}

class _AddPassiveMemberDialogState extends State<AddPassiveMemberDialog> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _avatarUrl;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _addPassiveMember() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String profilId = const Uuid().v4();
      final AppUser newPassiveMember = AppUser(
        profilId: profilId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: '',
        phoneNumber: '',
        avatarUrl: _avatarUrl ?? 'assets/grafiken/famka-kreis.png',
        password: '',
        miscellaneous: null,
      );

      await widget.db.addUserToGroup(
          newPassiveMember, widget.group.groupId, UserRole.passiveMember);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaCyan,
            content: Text(
              AppLocalizations.of(context)!
                  .addPassiveMemberSuccess(_firstNameController.text.trim()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
        widget.onMemberAdded();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaRed,
            content: Text(
              AppLocalizations.of(context)!.addPassiveMemberError(e.toString()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(String labelText, TextTheme theme) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: theme.bodyMedium,
      border: const OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.famkaCyan, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: AppColors.famkaWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  AppLocalizations.of(context)!
                      .addPassiveMemberTitle
                      .split(' ')
                      .take(2)
                      .join(' '),
                  textAlign: TextAlign.center,
                  style: theme.labelMedium?.copyWith(
                    color: AppColors.famkaBlack,
                    height: 1.1,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!
                      .addPassiveMemberTitle
                      .split(' ')
                      .skip(2)
                      .join(' '),
                  textAlign: TextAlign.center,
                  style: theme.labelMedium?.copyWith(
                    color: AppColors.famkaBlack,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              ProfilImage(
                widget.db,
                currentAvatarUrl: _avatarUrl,
                onAvatarSelected: (url) {
                  setState(() {
                    _avatarUrl = url;
                  });
                },
                contextType: ImageSelectionContext.passiveMember,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _firstNameController,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                decoration: _inputDecoration(
                    AppLocalizations.of(context)!
                        .addPassiveMemberFirstNameLabel,
                    theme),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!
                        .addPassiveMemberFirstNameError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                decoration: _inputDecoration(
                    AppLocalizations.of(context)!.addPassiveMemberLastNameLabel,
                    theme),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!
                        .addPassiveMemberLastNameError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.famkaCyan)
                  : InkWell(
                      onTap: _addPassiveMember,
                      child: ButtonLinearGradient(
                        buttonText: AppLocalizations.of(context)!
                            .addPassiveMemberAddButton,
                      ),
                    ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)!.addPassiveMemberCancelButton,
                  style:
                      theme.titleMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
