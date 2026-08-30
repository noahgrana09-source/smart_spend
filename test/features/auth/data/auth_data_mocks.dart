import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:smart_spend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:smart_spend/features/auth/data/local/user_profile_dao.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockUserProfileDao extends Mock implements UserProfileDao {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockAdditionalUserInfo extends Mock implements AdditionalUserInfo {}

class MockUserMetadata extends Mock implements UserMetadata {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// ignore: subtype_of_sealed_class
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}
