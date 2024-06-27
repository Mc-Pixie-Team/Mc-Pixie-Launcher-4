import 'dart:io';

class InstallUtils {


static bool parseRuleList(List<dynamic> rules, {List<String>? options }) {
  // Rule parsing logic 

  for (var i in rules) {
    if(!parseRule(i as Map, options: options)){
      return false;
    } 
  }

  return true;
}

static bool parseFeatures(List<String> options, Map rule) {
  bool isvalid = true;

  (rule["features"] as Map).forEach((feature, enabled) { 
        if(options.length == 0) {
          isvalid = false;
          return;
        }
        options.forEach((element) { 
          if (element == feature) {
            if (!enabled) {
              isvalid = false;
              return;
            }
          }else {
            if(enabled) {
              isvalid = false;
              return;
            }
          }
        });
        if(!isvalid) {
          return;
        }
      
     });

  return isvalid;
}

static bool parseRule(Map rule, {List<String>? options }) {
    bool returnValue = rule["action"] == "disallow" ? false : true;

  if(options != null && rule["features"] != null) {
   if(!parseFeatures(options, rule)){
    return !returnValue;
   };
  }

  if (rule["os"] != null) {

    for (var osKey in (rule["os"] as Map).keys) {
      var osValue = rule["os"][osKey];
      if (osKey == "name") {
        if (osValue == "windows" && Platform.isWindows) {
          print("returning true for windows!");
          return returnValue;
        } else if (osValue == "osx" && Platform.isMacOS) {
          return returnValue;
        } else if (osValue == "linux" && Platform.isLinux) {
          return returnValue;
        }
      } else if (osKey == "arch") {
        if (osValue == "x86" && Platform.environment['PROCESSOR_ARCHITECTURE'] == "x86") {
          return returnValue;
        }
      } else if (osKey == "version") {
        if (RegExp(osValue).hasMatch(Platform.operatingSystemVersion)) {
          return returnValue;
        }
      }
    }
  }else {
    return returnValue;
  }

  return !returnValue;
}
}