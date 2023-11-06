class Version {
  late int release;
  late int major;
  late int? minor;
  late String? various;

  Version(this.release, this.major,[ this.minor, this.various]);

  int get getRelease => release;
  int get getMajor => major;
  int? get getMinor => minor;
  //Code by Mc-Pixie
  

  @override
  String toString() {
    if(this.various != null) {
      return this.various!;
    }

    return release.toString() + '.' + major.toString()  +'${minor == null ? ".0" : "."+ minor.toString()}' ;
  }

  static parse(String version) {
    try {
     List aftersplit = version.split('.');
     if(aftersplit.length <3) return Version(int.parse(aftersplit[0]),int.parse(aftersplit[1]));
     return Version(int.parse(aftersplit[0]),int.parse(aftersplit[1]), int.parse(aftersplit[2]));
    } catch (e) {
      return Version(0, 0, 0, version);
    }

  }



  //operator list
  bool operator <(Version other) => compareTo(other) < 0;
  bool operator >(Version other) => compareTo(other) > 0;
  bool operator <=(Version other) => compareTo(other) <= 0;
  bool operator >=(Version other) => compareTo(other) >= 0;

 @override
  bool operator ==( other) => compareTo(other as Version) == 0;

  //comparison
  int compareTo(Version other) {
    if(various != null) {

      if(other.various == null) {
      return  compareSnapANDRelease(various!, other.toString());
      }
      return isSnapshotNewer(various!, other.various!);
    }

    if (release != other.release) return release.compareTo(other.release);
    if (major != other.major) return major.compareTo(other.major);
    if(minor == null) return 0;
    if (minor != other.minor) return (minor as int).compareTo(other.minor as num);
    return 0;
  }
  //if screenshot
  isSnapshotNewer(String snapshot1, String snapshot2) {

  final version1 = snapshot1.split(' ')[0];
  final version2 = snapshot2.split(' ')[0];

  return version1.compareTo(version2);
}

int compareSnapANDRelease(String snapshotVersion, String releaseVersion) {
  final snapshotParts = snapshotVersion.split(RegExp(r'[a-zA-Z]')); // Split by letters
  final releaseParts = releaseVersion.split('.');

  // Convert parts to integers for numerical comparison
  final snapshotNumbers = snapshotParts.map((part) => int.tryParse(part) ?? 0).toList();
  final releaseNumbers = releaseParts.map((part) => int.tryParse(part) ?? 0).toList();

  // Compare each part of the version numbers
  for (int i = 0; i < snapshotNumbers.length; i++) {
    if (i >= releaseNumbers.length) {
      return 1; // Snapshot version has more parts, so it's considered newer
    }

    if (snapshotNumbers[i] > releaseNumbers[i]) {
      return 1; // Snapshot version is newer
    } else if (snapshotNumbers[i] < releaseNumbers[i]) {
      return -1; // Snapshot version is older
    }
  }

  if (snapshotNumbers.length < releaseNumbers.length) {
    return -1; // Snapshot version has fewer parts, so it's considered older
  }

  return 0; // Versions are equal
}
  

  
}

