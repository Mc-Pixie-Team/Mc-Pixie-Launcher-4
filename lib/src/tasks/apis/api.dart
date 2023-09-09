class Api {


  String getTitlename() {
    throw "you cannot call api alone";
  }

  // getModpack() {
  //   // TODO: implement getModpack
  //   throw "you cannot call api alone";
  // }

  // getModpackVersion() {
  //   // TODO: implement getModpack
  //   throw "you cannot call api alone";
  // }

   getMMLVersion(modpackVersion, String instanceName, String modloader){}

  getMoreModpacks() {}
  getAllMV() {}
  getModpackList() {}
  getModpack(String id){}
  getModpackVersion(String version){}
  downloadModpack(Map modpackVersion, String instanceName) {}
}
