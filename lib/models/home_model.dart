import 'package:flutter/widgets.dart';

class HomeModel with ChangeNotifier {
  get ifVisible => _isVisible;
  bool _isVisible = false;
  set isVisible(val) {
    _isVisible = val;
    notifyListeners();
  }

  get isValid => _isValid;
  bool _isValid = false;
  void isEmailValid(String input) {
    if (input.trim() == "aaa")
      _isValid = true;
    else
      _isValid = false;
    notifyListeners();
  }
}
