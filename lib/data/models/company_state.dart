enum CompanyStatus { initial, loading, success, error }

class CompanyState {
  final CompanyStatus status;
  final String? errorMessage;

  const CompanyState({
    this.status = CompanyStatus.initial,
    this.errorMessage,
  });

  bool get isLoading => status == CompanyStatus.loading;
  bool get success => status == CompanyStatus.success;
  bool get isError => status == CompanyStatus.error;

  CompanyState copyWith({
    CompanyStatus? status,
    String? errorMessage,
  }) {
    return CompanyState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
