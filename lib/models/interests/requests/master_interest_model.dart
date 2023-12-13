import 'package:flutter_riverpod/flutter_riverpod.dart';

class MasterInterests {
  final List<String> interests;
  MasterInterests({required this.interests});

  MasterInterests copyWith({
    List<String>? interests,
  }) {
    return MasterInterests(
      interests: interests ?? this.interests,
    );
  }
}

final masterInterestsProvider =
    StateProvider((ref) => MasterInterests(interests: []));
