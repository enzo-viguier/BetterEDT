import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tutorial.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'l10n.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController _icalLinkController = TextEditingController();
  String _icalFilePath = "";
  String _version = '';

  var logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadIcalLink(); // Charger le lien iCal sauvegardé au démarrage
    _getVersion(); // Récupérer la version de l'application
  }

  Future<void> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;  // Récupérer le numéro de version
    });
  }

  // Charger le lien iCal sauvegardé à partir de SharedPreferences
  void _loadIcalLink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedIcalLink = prefs.getString('ical_link') ?? '';
    setState(() {
      _icalLinkController.text =
          savedIcalLink; // Remplir le champ texte avec le lien sauvegardé
    });
  }

  // Méthode pour sauvegarder le lien iCal dans SharedPreferences
  void _saveIcalLink(String icalLink) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ical_link', icalLink); // Sauvegarder le lien iCal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('AppBarSettingScreen')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.translate("InsertLink"), style: TextStyle(fontSize: 16)),
            TextField(
              controller: _icalLinkController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.translate("LienIcal"),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: Text(AppLocalizations.of(context)!.translate("Save")),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => _icalLinkController.clear(),
                child: Text(AppLocalizations.of(context)!.translate("Delete")),
              ),
            ),
            const SizedBox(height: 40),
            Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TutorialScreen()),
                    );
                  },
                child: Text(
                  AppLocalizations.of(context)!.translate("HowToGetICalLink"),
                    style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                    ),
                  ),
                )
            ),
            // Ajout du numéro de version
            const Spacer(), // Pour pousser le numéro de version en bas de l'écran
            Center(
              child: Text(
                "Version $_version by Enzo VIGUIER", // Remplace par ta version actuelle
                style: const TextStyle(
                  fontSize: 12, // Taille du texte
                  color: Colors.grey, // Couleur légèrement grise
                ),
              ),
            ),
            const SizedBox(height: 8), // Pour un petit espacement
          ],
        ),
      ),
    );
  }

  // Méthode pour sauvegarder les paramètres (lien)
  void _saveSettings() {

    String icalLink = _icalLinkController.text; // Récupérer le lien iCal

    if (icalLink.isNotEmpty) {

      if (icalLink.startsWith('https://proseconsult.umontpellier.fr')) {

        _saveIcalLink(icalLink);  // Sauvegarder le lien si valide
        logger.i('Lien iCal sauvegardé : $icalLink');

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.translate('iCalLinkSavedWithSuccess')))
        );

        // Revenir à l'écran précédent
        Navigator.pop(context);

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.translate('InsertICalLink')))
        );

      }

    } else {
      logger.i('Fichier iCal sauvegardé : $_icalFilePath');
    }

  }
}
