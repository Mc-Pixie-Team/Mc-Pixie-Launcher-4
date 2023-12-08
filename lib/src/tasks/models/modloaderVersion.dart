class ModloaderVersion {
  late int release;
  late int major;
  late int minor;
  late int? patch;

  ModloaderVersion(this.release, this.major, this.minor, [this.patch]);

  int get getRelease => release;
  int get getMajor => major;
  int get getMinor => minor;
  int? get getPatch => patch;
  //Code by Mc-Pixie

  @override
  String toString() {
    if (patch == null) return release.toString() + '.' + major.toString() + '.' + minor.toString();
    return release.toString() + '.' + major.toString() + '.' + minor.toString() + '.' + patch.toString();
  }

  static parse(String version) {
    List aftersplit = version.split('.');
    if (aftersplit.length < 4)
      return ModloaderVersion(int.parse(aftersplit[0]), int.parse(aftersplit[1]), int.parse(aftersplit[2]));
    return ModloaderVersion(
        int.parse(aftersplit[0]), int.parse(aftersplit[1]), int.parse(aftersplit[2]), int.parse(aftersplit[3]));
  }

  //operator list
  bool operator <(ModloaderVersion other) => compareTo(other) < 0;
  bool operator >(ModloaderVersion other) => compareTo(other) > 0;
  bool operator <=(ModloaderVersion other) => compareTo(other) <= 0;
  bool operator >=(ModloaderVersion other) => compareTo(other) >= 0;

  @override
  bool operator ==(other) => compareTo(other as ModloaderVersion) == 0;

  //comparison
  int compareTo(ModloaderVersion other) {
    if (release != other.release) return release.compareTo(other.release);
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch == null) return 0;
    if (patch != other.patch) return patch!.compareTo(other.patch as int);
    return 0;
  }
}
