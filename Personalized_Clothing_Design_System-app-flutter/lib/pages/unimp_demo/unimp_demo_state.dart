class UniMPDemoState {
  const UniMPDemoState({
    this.appId = '__UNI__1A35A87',
    this.status = '',
    this.loading = false,
    this.downloadProgress,
  });

  final String appId;
  final String status;
  final bool loading;
  final double? downloadProgress;

  UniMPDemoState copyWith({
    String? appId,
    String? status,
    bool? loading,
    double? Function()? downloadProgress,
  }) {
    return UniMPDemoState(
      appId: appId ?? this.appId,
      status: status ?? this.status,
      loading: loading ?? this.loading,
      downloadProgress:
          downloadProgress != null ? downloadProgress() : this.downloadProgress,
    );
  }
}
