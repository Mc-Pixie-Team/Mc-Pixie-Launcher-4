enum DownloadState {
  notDownloaded,
  downloadingClient,
  downloadingLibraries,
  downloadAssets,
}

enum ForgeInstallState {
  downloadingClient,
  downloadingLibraries,
  patching,
  finished,
}

enum FabricInstallState {
  downloadingLibraries,
  finished,
}

enum ClientInstallState {
  downloadingClient,
  downloadingLibraries,
  downloadAssets,
  finished,
}

