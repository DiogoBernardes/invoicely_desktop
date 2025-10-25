enum LoginStatus { initial, loading, success, error }

class LoginState {
  final LoginStatus status;
  final String? errorMessage;
  final bool hasCompany;

  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.hasCompany = false,
  });

  bool get isLoading => status == LoginStatus.loading;
  bool get success => status == LoginStatus.success;
  bool get isError => status == LoginStatus.error;

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    bool? hasCompany,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      hasCompany: hasCompany ?? this.hasCompany,
    );
  }
}
