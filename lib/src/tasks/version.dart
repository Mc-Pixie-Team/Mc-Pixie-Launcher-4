class Version {
  late int release;
  late int major;
  late int? minor;

  Version(this.release, this.major,[ this.minor]);

  int get getRelease => release;
  int get getMajor => major;
  int? get getMinor => minor;
  //Code by Mc-Pixie
  

  @override
  String toString() {
    

    return release.toString() + '.' + major.toString()  +'${minor == null ? "" : "."+ minor.toString()}' ;
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
    if (release != other.release) return release.compareTo(other.release);
    if (major != other.major) return major.compareTo(other.major);
    if(minor == null) return 0;
    if (minor != other.minor) return (minor as int).compareTo(other.minor as num);
    return 0;
  }
  

  
}

