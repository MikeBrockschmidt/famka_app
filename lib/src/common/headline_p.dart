import 'package:flutter/material.dart';

class HeadlineP extends StatelessWidget {
  final String screenHead;
  final List<Widget>? rightActionWidgets;

  const HeadlineP({
    super.key,
    required this.screenHead,
    this.rightActionWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 0, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      screenHead,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  if (rightActionWidgets != null &&
                      rightActionWidgets!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Row(
                        children: rightActionWidgets!,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Divider(
            height: 0.5,
            thickness: 0.5,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
