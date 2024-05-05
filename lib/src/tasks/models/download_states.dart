enum DownloadState {
  notDownloaded,
  downloadingClient,
  downloadingLibraries,
  downloadAssets,
  customDownload,
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

enum ModloaderInstallState {
  downloadingClient,
  downloadingLibraries,
  patching,
  finished,
}

enum ClientInstallState {
  downloadingClient,
  downloadingLibraries,
  downloadAssets,
  finished,
}

enum MainState { downloadingMods, downloadingMinecraft, downloadingML, running, installed, notinstalled, fetching, unzipping }

enum Modinstall {
  downloadingMod,
  getML,
}

enum ExportImport { notHandeled, exporting, importing, fetching }
