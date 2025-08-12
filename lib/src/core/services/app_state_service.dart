import 'package:flutter/foundation.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';

class AppStateService extends ChangeNotifier {
  AppUser? _currentUser;
  Group? _currentGroup;
  List<Group> _userGroups = [];
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  Group? get currentGroup => _currentGroup;
  List<Group> get userGroups => List.unmodifiable(_userGroups);
  bool get isLoading => _isLoading;

  void setCurrentUser(AppUser? user) {
    _currentUser = user;
    notifyListeners();
  }

  void setCurrentGroup(Group? group) {
    _currentGroup = group;
    notifyListeners();
  }

  void setUserGroups(List<Group> groups) {
    _userGroups = List.from(groups);
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearState() {
    _currentUser = null;
    _currentGroup = null;
    _userGroups = [];
    _isLoading = false;
    notifyListeners();
  }
}
