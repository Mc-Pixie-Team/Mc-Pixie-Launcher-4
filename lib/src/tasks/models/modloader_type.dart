enum ModloaderType {
  forge,
  fabric,
  vanilla,
}

class ModloaderTypeTools {
  static String toName(ModloaderType type) {
    switch (type) {
      case ModloaderType.fabric:
        return "Fabric";
      case ModloaderType.forge:
        return "Forge";
      default:
        return "Vanilla";

    }
  }
}