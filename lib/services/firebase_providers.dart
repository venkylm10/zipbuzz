import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authProvider = Provider((ref) => FirebaseAuth.instance);
final databaseProvider = Provider((ref) => FirebaseDatabase.instance);
final googleSignInProvider = Provider((ref) => GoogleSignIn());
final storageProvider = Provider((ref) => FirebaseStorage.instance);
