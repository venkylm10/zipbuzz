class Host {
  final String name;
  final String? imagePath;
  final String? phoneNumber;
  final String? email;

  const Host({
    required this.name,
    this.imagePath,
    this.phoneNumber,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'imagePath': imagePath,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  factory Host.fromMap(Map<String, dynamic> map) {
    return Host(
      name: map['name'] as String,
      imagePath: map['imagePath'] != null ? map['imagePath'] as String : null,
      phoneNumber:
          map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
    );
  }
}
