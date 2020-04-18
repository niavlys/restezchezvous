
import 'package:date_format/date_format.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool alreadyOnBoarded(SharedPreferences prefs) {
  return (prefs.getBool('seen') ?? false);
}

bool allMandatoryPrefsOK(SharedPreferences prefs) {
  try {
    return (prefs.getString('firstName').isNotEmpty ?? false) &&
        (prefs.getString('lastName').isNotEmpty ?? false) &&
        (prefs.getString('birthDate').isNotEmpty ?? false) &&
        (prefs.getString('birthPlace').isNotEmpty ?? false) &&
        (prefs.getString('address').isNotEmpty ?? false) &&
        (prefs.getString('city').isNotEmpty ?? false) &&
        (prefs.getString('postalCode').isNotEmpty ?? false);
  } catch (Exception) {
    return false;
  }
}

String generateStringForQRCode(SharedPreferences prefs, DateTime now, String motif){
  return """Cree le: ${formatDate(now, [dd, '/', mm, '/', yyyy, ' a ', HH, '\\h',nn])}; Nom: ${prefs.getString("lastName")}; Prenom: ${prefs.getString("firstName")}; Naissance: ${prefs.getString("birthDate")} a ${prefs.getString("birthPlace")}; Adresse: ${prefs.get("address")} ${prefs.get("postalCode")} ${prefs.get("city")}; Sortie: ${formatDate(now, [dd, '/', mm, '/', yyyy, ' a ', HH,'\\h',nn])}; Motifs: $motif""";

}