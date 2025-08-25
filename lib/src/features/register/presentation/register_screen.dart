import 'package:famka_app/src/common/headline_k.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/common/color_row.dart';
import 'package:famka_app/src/features/register/presentation/widgets/register_window.dart';

class RegisterScreen extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;

  const RegisterScreen(this.db, this.auth, {super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listen for keyboard close events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.addListener(_handleFocusChange);
    });
  }

  void _handleFocusChange() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null || !focus.hasFocus) {
      // Keyboard dismissed, scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_handleFocusChange);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(color: Colors.white),
            const Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 540,
                child: ColorRow(),
              ),
            ),
            const Align(
              alignment: Alignment.topCenter,
              child: HeadlineK(screenHead: 'famka'),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                toolbarHeight: 1,
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: SingleChildScrollView(
                controller: _scrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80),
                        const Padding(
                          padding: EdgeInsets.only(left: 28, top: 130),
                          child: Text(
                            'Registrieren',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        RegisterWindow(widget.db, widget.auth),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  // bottomNavigationBar entfernt
}

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [],
    );
  }
}
