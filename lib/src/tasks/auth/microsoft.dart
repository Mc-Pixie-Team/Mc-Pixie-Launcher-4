import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:mclauncher4/src/objects/accounts/minecraft.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/apis/modrinth.api.dart';

class Microsoft {
  Future<Map> authenticate() async {
    String msaToken = await launchMSA();
    Map authResponseMicrosoft = await microsoftSignIn(msaToken, false);
    Map authTokenXboxLive = await xboxSignIn(authResponseMicrosoft["access_token"]);
    String authXSTSToken = await XSTSToken(authTokenXboxLive);
    Map minecraftUserToken = await minecraftBearerToken(authXSTSToken, authTokenXboxLive["uhs"]);
    Map userDetail = await minecraftUserDetails(minecraftUserToken["access_token"]);
    return {
      "refreshToken": authResponseMicrosoft["refreshToken"],
      "uuid": userDetail["id"],
      "username": userDetail["name"],
      "xbox_username": "",
    };
  }

  Future<Map> reAuthenticate(MinecraftAccount account) async {
    Map authResponseMicrosoft = await microsoftSignIn(account.refreshToken, true);
    Map authTokenXboxLive = await xboxSignIn(authResponseMicrosoft["access_token"]);
    String authXSTSToken = await XSTSToken(authTokenXboxLive);
    Map minecraftUserToken = await minecraftBearerToken(authXSTSToken, authTokenXboxLive["uhs"]);
    Map userDetail = await minecraftUserDetails(minecraftUserToken["access_token"]);
    return {
      "authToken": minecraftUserToken["access_token"],
      "refreshToken": authTokenXboxLive["refreshToken"],
      "uuid": userDetail["id"],
      "username": userDetail["name"],
      "xbox_username": ""
    };
  }

  Future<String> launchMSA() async {
    var result;

    if (Platform.isWindows) {
      result = await Process.run("rundll32", [
        'url.dll,FileProtocolHandler',
        'https://login.live.com/oauth20_authorize.srf?client_id=91f49b7b-7e40-461f-9eb0-2389c32c0cd6&response_type=code&redirect_uri=http://localhost:25458&scope=XboxLive.signin%20offline_access&state=NOT_NEEDED&prompt=select_account'
      ]);
    } else {
      result = await Process.run("open", [
        'https://login.live.com/oauth20_authorize.srf?client_id=91f49b7b-7e40-461f-9eb0-2389c32c0cd6&response_type=code&redirect_uri=http://localhost:25458&scope=XboxLive.signin%20offline_access&state=NOT_NEEDED&prompt=select_account'
      ]);
    }

    String token = "";
    var server = await HttpServer.bind(InternetAddress.anyIPv6, 25458, shared: true);
    server.idleTimeout = Duration(seconds: 20);
    await server.forEach((HttpRequest request) {
      request.response.write('Logged in! You can now close this window.');
      request.response.close();
      if ((request.uri.queryParameters.keys).contains("code") == true) {
        token = request.uri.queryParameters["code"]!;
        server.close(force: false);
      }
    });

    return token;
  }

  Future<Map> microsoftSignIn(token, bool isReauth) async {
    if (!isReauth) {
      http.Response firstAuthResponse = await http.post(
        Uri.parse('https://n8n.mc-pixie.com/webhook/d16395b2-c5bf-4a21-99c4-3fd44f74ad7e?code=$token&isRefresh=false'),
      );
      Map rsp = jsonDecode(firstAuthResponse.body);

      rsp = rsp["data"][0];
      return {"access_token": rsp["access_token"], "refreshToken": rsp["refresh_token"]};
    } else if (isReauth) {
      http.Response firstAuthResponse = await http.post(
        Uri.parse('https://n8n.mc-pixie.com/webhook/d16395b2-c5bf-4a21-99c4-3fd44f74ad7e?code=$token&isRefresh=true'),
      );
      Map rsp = jsonDecode(firstAuthResponse.body);
      rsp = rsp["data"][0];
      return {"access_token": rsp["access_token"], "refreshToken": rsp["refresh_token"]};
    }
    return {"access_token": "", "refreshToken": ""};
  }

  Future<Map> xboxSignIn(authTokenMicrosoft) async {
    Uri uri = Uri.parse('https://user.auth.xboxlive.com/user/authenticate');

    Map data = {
      "Properties": {
        "AuthMethod": "RPS",
        "SiteName": "user.auth.xboxlive.com",
        "RpsTicket": "d=" + authTokenMicrosoft // you may need to add "d=" before the access token as mentioned earlier
      },
      "RelyingParty": "http://auth.xboxlive.com",
      "TokenType": "JWT"
    };

    http.Response firstAuthResponse =
        await http.post(uri, headers: {'Content-Type': "application/json", "Accept": "application/json"}, body: jsonEncode(data));

    Map rsp = jsonDecode(firstAuthResponse.body);

    return {"token": rsp["Token"], "uhs": rsp["DisplayClaims"]["xui"][0]["uhs"]};
  }

  Future<String> XSTSToken(authTokenXboxLive) async {
    Uri uri = Uri.parse('https://xsts.auth.xboxlive.com/xsts/authorize');

    Map data = {
      "Properties": {
        "SandboxId": "RETAIL",
        "UserTokens": ["${authTokenXboxLive["token"]}"]
      },
      "RelyingParty": "rp://api.minecraftservices.com/",
      "TokenType": "JWT"
    };

    http.Response firstAuthResponse =
        await http.post(uri, headers: {'Content-Type': "application/json", "Accept": "application/json"}, body: jsonEncode(data));
   // print(firstAuthResponse.statusCode);
    if (firstAuthResponse.statusCode != 401) {
      Map rsp = jsonDecode(firstAuthResponse.body);
     // print(rsp["Token"]);
      return rsp["Token"];
    } else {
      Map rsp = jsonDecode(firstAuthResponse.body);

      print(
          "error: ${rsp["XErr"]}\nMessage: ${(rsp["XErr"] == 2148916238) ? "account belongs to someone under 18 and needs to be added to a family" : "account has no Xbox account, you must sign up for one first"}");
      return "";
    }
  }

  Future<Map> minecraftBearerToken(authXSTSToken, xboxUserHash) async {
    Uri uri = Uri.parse('https://api.minecraftservices.com/authentication/login_with_xbox');

    Map data = {"identityToken": "XBL3.0 x=$xboxUserHash;$authXSTSToken", "ensureLegacyEnabled": true};

    http.Response firstAuthResponse =
        await http.post(uri, headers: {'Content-Type': "application/json", "Accept": "application/json"}, body: jsonEncode(data));
    // print(firstAuthResponse.body);
    // print(firstAuthResponse.statusCode);
    //Map rsp = jsonDecode(firstAuthResponse.body);

    return jsonDecode(firstAuthResponse.body);
  }

  Future<Map> minecraftUserDetails(minecraftAuthToken) async {
    Uri uri = Uri.parse('https://api.minecraftservices.com/minecraft/profile');
  //  print('Bearer $minecraftAuthToken');
    http.Response firstAuthResponse = await http.get(
      uri,
      headers: {"Authorization": 'Bearer $minecraftAuthToken'},
    );
    // print(firstAuthResponse.body);
    // print(firstAuthResponse.statusCode);
    //Map rsp = jsonDecode(firstAuthResponse.body);

    return jsonDecode(firstAuthResponse.body);
  }
}
