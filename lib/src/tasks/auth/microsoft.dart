import 'dart:io';
import 'package:http/http.dart' as http;

class Microsoft {
  Future<Map> authenticate() async {
    //String msaToken = await launchMSA();
    await xboxSignIn("msaToken");
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

  Future<String> xboxSignIn(msaToken) async {
    await http.get(Uri.parse("https://1.1.1.1"));

    Uri uri = Uri.parse('https://login.live.com/oauth20_token.srf');
    print(uri);
    String clientId = "91f49b7b-7e40-461f-9eb0-2389c32c0cd6";
    String clientSecret = "-.O8Q~BCSm2qhiKjPkN9oHbTT6q2ZzD1Kj8V9ax.";
    http.Response response = await http.post(
      uri,
      headers: {'Content-Type': "application/x-www-form-urlencoded"},
      body: "client_id=$clientId&client_secret=$clientSecret&code=$msaToken&grant_type=authorization_code&redirect_uri=http://localhost:25458",
    );
    print(response.body);
    return response.body;
    return "";
  }
}
