enum ObjectType {
  modpack,
  mod,
  shader,
  world,
  resource,
}

class ObjectTypeTools {
  static String todir(ObjectType objectType) {
    switch (objectType) {
      case ObjectType.mod:
        return "mods";
      case ObjectType.resource:
        return "resourcepacks";
      case ObjectType.shader:
        return "shaders";
      case ObjectType.world:
        return "saves";
      case ObjectType.modpack:
        throw "Type Modpack cannot be parsed to a Directory";
    }
  }
}
