class Convert {
  bool isSurrounded(String str, String prefix, String suffix) {
    return str.startsWith(prefix) && str.endsWith(suffix);
  }

  List parseMaven(String mavenString) {
    /*
    原始內容: de.oceanlabs.mcp:mcp_config:1.16.5-20210115.111550@zip
    轉換後內容: https://maven.minecraftforge.net/de/oceanlabs/mcp/mcp_config/1.16.5-20210115.110354/mcp_config-1.16.5-20210115.110354.zip

    . -> / (套件包名稱)
    : -> /
    第一個 : 後面代表套件名稱，第二個 : 後面代表版本號
    @ -> . (副檔名)
    檔案名稱組合方式: 套件名稱-套件版本號/.副檔名 (例如: mcp_config-1.16.5-20210115.110354.zip)
    */

    /// 是否為方括號，例如這種格式: [de.oceanlabs.mcp:mcp_config:1.16.5-20210115.111550@zip]
    if (isSurrounded(mavenString, "[", "]")) {
      mavenString =
          mavenString.split("[").join("").split("]").join(""); //去除方括號，方便解析
    }

    /// 以下範例的原始字串為 de.oceanlabs.mcp:mcp_config:1.16.5-20210115.111550@zip 的格式
    /// 結果: de/oceanlabs/mcp
    String packageGroup = mavenString.split(":")[0].replaceAll(".", "/");

    /// 結果: mcp_config
    String packageName = mavenString.split(":")[1];

    /// 結果: 1.16.5-20210115.111550
    String packageVersion = mavenString.split(":")[2].split("@")[0];

    /// 結果: zip
    String packageExtension = mavenString.split("@")[1];

    return [
      "$packageGroup/$packageName/$packageVersion",
      "$packageName-$packageVersion.$packageExtension"
    ];
  }
}
