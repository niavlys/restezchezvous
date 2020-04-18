
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This is our global ServiceLocator
GetIt getIt = GetIt.instance;

void setupGetIt() {
  //register shared prefs 
  getIt.registerSingletonAsync<SharedPreferences>(SharedPreferences.getInstance);
}
