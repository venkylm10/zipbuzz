import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipbuzz/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) {
  return null;
});

final userControllerProvider = Provider((ref) => UserController(ref: ref));

class UserController {
  final Ref _ref;
  UserController({required Ref ref}) : _ref = ref;
  void updateInterest(String interest) {
    final updatedUser = _ref.read(userProvider)!;
    if (updatedUser.interests.contains(interest)) {
      updatedUser.interests.remove(interest);
      return;
    }
    updatedUser.interests.add(interest);
  }

  
}
