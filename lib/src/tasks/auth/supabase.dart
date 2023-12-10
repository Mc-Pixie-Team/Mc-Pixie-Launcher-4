import "package:supabase_flutter/supabase_flutter.dart";

class supabaseHelpers {
  Future<void> init() async {
    await Supabase.initialize(
      url: 'https://api.supabase.mc-pixie.com/',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzAyMTYyODAwLAogICJleHAiOiAxODYwMDE1NjAwCn0.UJD1El-jMA7TGyOrPsDHJMSAtVCdbCgtiWMlQJ5WUXs',
    );

// Get a reference your Supabase client

    return;
  }

  void signoutUser() {
    final _supabase = Supabase.instance.client;
    _supabase.auth.signOut();
  }

  bool isLoggedIn() {
    final _supabase = Supabase.instance.client;
    if (_supabase.auth.currentUser != null) {
      return true;
    }

    return false;
  }
}
