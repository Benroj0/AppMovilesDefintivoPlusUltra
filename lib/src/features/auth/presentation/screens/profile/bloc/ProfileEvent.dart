abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class UpdateUserNameEvent extends ProfileEvent {
  final String userName;
  UpdateUserNameEvent(this.userName);
}

class UpdateUserEmailEvent extends ProfileEvent {
  final String userEmail;
  UpdateUserEmailEvent(this.userEmail);
}

class LogoutEvent extends ProfileEvent {}

class ClearProfileEvent extends ProfileEvent {}
