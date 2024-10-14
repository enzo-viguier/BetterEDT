import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController _icalLinkController = TextEditingController();
  String _icalFilePath = "";

  @override
  void initState() {
    super.initState();
    _loadIcalLink();  // Charger le lien iCal sauvegardé au démarrage
  }

  // Charger le lien iCal sauvegardé à partir de SharedPreferences
  void _loadIcalLink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedIcalLink = prefs.getString('ical_link') ?? '';
    setState(() {
      _icalLinkController.text = savedIcalLink;  // Remplir le champ texte avec le lien sauvegardé
    });
  }

  // Méthode pour sauvegarder le lien iCal dans SharedPreferences
  void _saveIcalLink(String icalLink) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ical_link', icalLink);  // Sauvegarder le lien iCal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Entrez le lien iCal :', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _icalLinkController,
              decoration: InputDecoration(
                hintText: 'Lien iCal',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: Text('Sauvegarder'),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => _icalLinkController.clear(),
                child: Text('Effacer'),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Méthode pour sauvegarder les paramètres (fichier ou lien)
  void _saveSettings() {
    String icalLink = _icalLinkController.text;
    if (icalLink.isNotEmpty) {
      _saveIcalLink(icalLink);  // Sauvegarder le lien iCal
      print('Lien iCal sauvegardé : $icalLink');
    } else {
      print('Fichier iCal sauvegardé : $_icalFilePath');
    }

    // Revenir à l'écran précédent
    Navigator.pop(context);
  }
}
