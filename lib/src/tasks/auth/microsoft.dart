import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/apis/modrinth.api.dart';

class Microsoft {
  final storage = new LocalStorage('auth_data.json');
  Future<Map> authenticate() async {

  

    String msaToken = await launchMSA();
    String authTokenMicrosoft = await microsoftSignIn(msaToken);
    Map authTokenXboxLive = await xboxSignIn(authTokenMicrosoft);
    String authXSTSToken = await XSTSToken(authTokenXboxLive);
    Map minecraftUserToken = await minecraftBearerToken(authXSTSToken, authTokenXboxLive["uhs"]);
    return {
      "access_token": "",
      "xbox_username": "",
    };
  }

  Future<String> launchMSA() async {
    var result = await Process.run("rundll32", [
      'url.dll,FileProtocolHandler',
      'https://login.live.com/oauth20_authorize.srf?client_id=91f49b7b-7e40-461f-9eb0-2389c32c0cd6&response_type=code&redirect_uri=http://localhost:25458&scope=XboxLive.signin%20offline_access&state=NOT_NEEDED'
    ]);
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

  Future<String> microsoftSignIn(msaToken) async {
    await http.get(Uri.parse("https://1.1.1.1"));

    Uri uri = Uri.parse('https://login.live.com/oauth20_token.srf');
    print(uri);
    String clientId = "91f49b7b-7e40-461f-9eb0-2389c32c0cd6";
    String clientSecret = "-.O8Q~BCSm2qhiKjPkN9oHbTT6q2ZzD1Kj8V9ax.";

    http.Response firstAuthResponse = await http.post(
      uri,
      headers: {'Content-Type': "application/x-www-form-urlencoded"},
      body: "client_id=$clientId&client_secret=$clientSecret&code=$msaToken&grant_type=authorization_code&redirect_uri=http://localhost:25458",
    );
    Map rsp = jsonDecode(firstAuthResponse.body);
    if (firstAuthResponse.statusCode == 200) {
      storage.setItem("microsoftRefreshToken", rsp["refresh_token"]);
    }
    print(storage.getItem("microsoftRefreshToken"));
    return rsp["access_token"];
  }

  Future<Map> xboxSignIn(authTokenMicrosoft) async {
    Uri uri = Uri.parse('https://user.auth.xboxlive.com/user/authenticate');
    print(uri);

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
    print(firstAuthResponse.body);

    Map rsp = jsonDecode(firstAuthResponse.body);

    return {"token": rsp["Token"], "uhs": rsp["DisplayClaims"]["xui"][0]["uhs"]};
  }

  Future<String> XSTSToken(authTokenXboxLive) async {
    Uri uri = Uri.parse('https://xsts.auth.xboxlive.com/xsts/authorize');
    print(uri);

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
    print(firstAuthResponse.statusCode);
    if (firstAuthResponse.statusCode != 401) {
      Map rsp = jsonDecode(firstAuthResponse.body);
      print(rsp["Token"]);
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
    print(uri);

    Map data = {"identityToken": "XBL3.0 x=$xboxUserHash;$authXSTSToken", "ensureLegacyEnabled": true};

    http.Response firstAuthResponse =
        await http.post(uri, headers: {'Content-Type': "application/json", "Accept": "application/json"}, body: jsonEncode(data));
    print(firstAuthResponse.body);
    print(firstAuthResponse.statusCode);
    //Map rsp = jsonDecode(firstAuthResponse.body);

    return {};
  }
}
