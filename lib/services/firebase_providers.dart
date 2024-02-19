import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final authProvider = Provider((ref) => FirebaseAuth.instance);
final databaseProvider = Provider((ref) => FirebaseDatabase.instance);
final googleSignInProvider = Provider((ref) => GoogleSignIn());
final appleSignInProvider = Provider((ref) => SignInWithApple());
final storageProvider = Provider((ref) => FirebaseStorage.instance);
