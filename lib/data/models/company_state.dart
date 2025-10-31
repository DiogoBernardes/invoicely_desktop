enum CompanyStatus { initial, loading, success, error }

class LoginState {
  final CompanyStatus status;
  final String? errorMessage;

  const LoginState({
    this.status = CompanyStatus.initial,
    this.errorMessage,
  });

  bool get isLoading => status == CompanyStatus.loading;
  bool get success => status == CompanyStatus.success;
  bool get isError => status == CompanyStatus.error;

  LoginState copyWith({
    CompanyStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
