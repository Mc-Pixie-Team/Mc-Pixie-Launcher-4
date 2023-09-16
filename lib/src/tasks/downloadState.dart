

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

enum MainState {
  downloadingMods,
  downloadingMinecraft,
  downloadingML,
  running,
  installed,
  notinstalled,
}

enum Modinstall {
  downloadingMod,
  getML,
}




