import 'package:equatable/equatable.dart';
import 'package:expense_tracking_app/services/auth_session_service.dart';
import 'package:expense_tracking_app/utils/auth_error_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'social_login_cubit_state.dart';

class SocialLoginCubit extends Cubit<SocialLoginCubitState> {
  SocialLoginCubit() : super(SocialLoginCubitInitial());

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> signInWithGoogle() async {
    emit(LoadingState());

    try {
      final googleSignInAccount = await _googleSignIn.authenticate();
      final googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
      );

      await _performSignIn(
        credential,
        name: googleSignInAccount.displayName,
        providerId: 'google.com',
      );
    } catch (e) {
      emit(FailedState(errorMessage: AuthErrorMessage.from(e)));
    }
  }

  Future<void> signInWithApple() async {
    emit(LoadingState());

    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );

      final name = appleIdCredential.givenName != null ||
              appleIdCredential.familyName != null
          ? '${appleIdCredential.givenName ?? ''} ${appleIdCredential.familyName ?? ''}'
              .trim()
          : null;

      await _performSignIn(
        credential,
        name: name?.isNotEmpty == true ? name : null,
        providerId: 'apple.com',
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        emit(SocialLoginCubitInitial());
        return;
      }
      emit(FailedState(errorMessage: AuthErrorMessage.from(e)));
    } catch (e) {
      emit(FailedState(errorMessage: AuthErrorMessage.from(e)));
    }
  }

  Future<void> _performSignIn(
    AuthCredential credential, {
    String? name,
    String? providerId,
  }) async {
    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      emit(const FailedState(errorMessage: 'Sign-in failed. Please try again.'));
      return;
    }

    await AuthSessionService.completeSignIn(
      firebaseUser,
      name: name,
      providerId: providerId,
    );

    emit(LoginSuccess());
  }
}
