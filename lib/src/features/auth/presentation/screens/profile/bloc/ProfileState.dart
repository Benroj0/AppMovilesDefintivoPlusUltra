class ProfileState {
  final String userName;
  final String userEmail;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.userName = 'Jasson Laureano',
    this.userEmail = 'jasson.laureano@upeu.edu.pe',
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    String? userName,
    String? userEmail,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<Object?> get props => [userName, userEmail, isLoading, error];
}
