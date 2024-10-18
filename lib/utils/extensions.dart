extension NameExtension on String {
  String get formattedName {
    final nameSplits = split(' ');
    final name = nameSplits.length > 1 ? "${nameSplits[0]} ${nameSplits[1][0]}." : nameSplits[0];
    return name;
  }
}
