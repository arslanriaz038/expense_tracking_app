import 'package:equatable/equatable.dart';
import 'package:expense_tracking_app/services/user_services.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'social_login_cubit_state.dart';

class SocialLoginCubit extends Cubit<SocialLoginCubitState> {
  SocialLoginCubit() : super(SocialLoginCubitInitial());

  final UserServices userServices = UserServices();

  Future<void> signInWithGoogle() async {
    emit(LoadingState());
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await GoogleSignIn().signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        await _performSignUp(
          credential,
          name: googleSignInAccount.displayName,
        );
      } else {
        emit(const FailedState());
      }
    } catch (e) {
      emit(FailedState(errorMessage: e.toString()));
    }
  }

  Future<void> signInWithApple() async {
    emit(LoadingState());
    try {
      final AuthorizationCredentialAppleID appleIdCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
      );

      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );
      final String name = appleIdCredential.givenName != null ||
              appleIdCredential.familyName != null
          ? "${appleIdCredential.givenName} ${appleIdCredential.familyName}"
          : '';

      await _performSignUp(
        credential,
        name: name.trim().isNotEmpty ? name.trim() : null,
      );
    } catch (e) {
      if (e is SignInWithAppleAuthorizationException) {
        emit(const FailedState());
      } else {
        emit(FailedState(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _performSignUp(
    AuthCredential credential, {
    String? name,
  }) async {
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    if (userCredential.user != null) {
      final user = await userServices.signUpUser(
        id: userCredential.user!.uid,
        email: userCredential.user!.email,
        name: userCredential.user?.displayName ?? name,
        profilePictureUrl: userCredential.user!.photoURL,
        providerId: credential.providerId,
      );

      MyPref.updateUserInfo(user);

      emit(LoginSuccess());
    } else {
      const FailedState(errorMessage: 'Failed to Sign up');
    }
  }
}
