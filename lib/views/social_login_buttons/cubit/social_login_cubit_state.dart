part of 'social_login_cubit.dart';

abstract class SocialLoginCubitState extends Equatable {
  const SocialLoginCubitState();

  @override
  List<Object> get props => [];
}

class SocialLoginCubitInitial extends SocialLoginCubitState {}

class LoadingState extends SocialLoginCubitState {}

class SignUpSuccessChildSetupNeeded extends SocialLoginCubitState {}

class SignUpSuccessNameSetupNeeded extends SocialLoginCubitState {}

class LoginSuccess extends SocialLoginCubitState {}

class FailedState extends SocialLoginCubitState {
  final String? errorMessage;

  const FailedState({this.errorMessage});
}
