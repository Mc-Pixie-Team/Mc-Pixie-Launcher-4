import "package:supabase_flutter/supabase_flutter.dart";

class supabaseHelpers {
  Future<void> init() async {
    await Supabase.initialize(
      url: 'https://api.supabase.mc-pixie.com/',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE',
    );

// Get a reference your Supabase client

    return;
  }
}
