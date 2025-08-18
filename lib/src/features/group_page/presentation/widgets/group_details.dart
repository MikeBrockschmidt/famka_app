import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

class GroupDetails extends StatelessWidget {
  final TextEditingController locationController;
  final FocusNode locationFocusNode;
  final TextEditingController descriptionController;
  final FocusNode descriptionFocusNode;

  const GroupDetails({
    super.key,
    required this.locationController,
    required this.locationFocusNode,
    required this.descriptionController,
    required this.descriptionFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Icon(Icons.location_on,
                    size: 20, color: AppColors.famkaBlack),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: locationController,
                  focusNode: locationFocusNode,
                  onTapOutside: (_) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      FocusScope.of(context).unfocus();
                    });
                  },
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    locationFocusNode.unfocus();
                  },
                  style: Theme.of(context).textTheme.labelSmall,
                  decoration: InputDecoration(
                    hintText: l10n.enterLocationHint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Icon(
                  Icons.description,
                  size: 20,
                  color: AppColors.famkaBlack,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: descriptionController,
                  focusNode: descriptionFocusNode,
                  onTapOutside: (_) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      FocusScope.of(context).unfocus();
                    });
                  },
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    descriptionFocusNode.unfocus();
                  },
                  style: Theme.of(context).textTheme.labelSmall,
                  decoration: InputDecoration(
                    hintText: l10n.enterDescriptionHint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
