import 'package:famka_app/src/data/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/common/legal_info_page.dart';

class MenuSubContainer1LinesImpressum extends StatelessWidget {
  // Atribute
  final DatabaseRepository db;

  // Konstrukter
  const MenuSubContainer1LinesImpressum(
    this.db, {
    super.key,
    this.isIconWhite = true,
  });

  final bool isIconWhite;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(
          thickness: 1,
          height: 1,
          color: Colors.grey,
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(
            top: 12.0,
            left: 20.0,
            bottom: 14.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.famkaGreen,
                child: const Text(
                  '+',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LegalInfoPage()),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Impressum',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
                iconSize: 20,
                color: isIconWhite ? Colors.white : Colors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
