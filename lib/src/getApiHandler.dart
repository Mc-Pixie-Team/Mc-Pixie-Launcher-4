import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/apis/modrinth.api.dart';

class ApiHandler {

   Map<String, Api> _handlers = {
    "modrinth": ModrinthApi(),
  };

 Api getApi(String handler) {
      
     if (_handlers[handler] == null) throw Exception("handler not found in list pls try: " + _handlers.keys.toList().toString());
     return _handlers[handler] as Api;
  } 
}