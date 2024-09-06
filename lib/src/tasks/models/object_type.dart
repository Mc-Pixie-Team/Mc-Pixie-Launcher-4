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
      return "shaderpacks";
    case ObjectType.world:
      return "saves";
    case ObjectType.modpack:
      return "";
  }

}

static String toName(ObjectType objectType) {
    switch (objectType) {
    case ObjectType.mod:
      return "Mods";
    case ObjectType.resource:
      return "ResourcePacks";
    case ObjectType.shader:
      return "Shaders";
    case ObjectType.world:
      return "Worlds";
    case ObjectType.modpack:
      throw "Modpack";
  }
}

}