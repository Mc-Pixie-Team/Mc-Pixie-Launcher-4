import 'dart:convert';

import 'package:http/http.dart' as http;
import './config/apis.dart';

class ModrinthApi {
 
  Future<List<dynamic>> getRandomModpacks(int count) async{
    var res = await http.get(Uri.parse('https://api.modrinth.com/v2/projects_random?count=$count'));
    
    return json.decode(res.body.toString());
  }
}
