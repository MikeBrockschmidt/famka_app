import 'package:flutter/material.dart';

class HeadlineK extends StatelessWidget {
  final String screenHead;

  const HeadlineK({
    super.key,
    required this.screenHead,
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
              child: Text(
                screenHead,
                style: Theme.of(context).textTheme.headlineLarge,
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
