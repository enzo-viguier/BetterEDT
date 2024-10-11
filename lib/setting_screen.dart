import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
              ),
            ),
            SizedBox(height: 20),
            Text('Ou téléchargez un fichier iCal :', style: TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: _pickIcalFile,
              child: Text('Choisir un fichier iCal'),
            ),
            if (_icalFilePath != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  'Fichier sélectionné : $_icalFilePath',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: Text('Sauvegarder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour sélectionner un fichier iCal
  Future<void> _pickIcalFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ics'],
    );

    if (result != null) {
      setState(() {
        _icalFilePath = result.files.single.path!;
      });
    }
  }

  // Méthode pour sauvegarder les paramètres (fichier ou lien)
  void _saveSettings() {
    String icalLink = _icalLinkController.text;
    if (icalLink.isNotEmpty) {
      _saveIcalLink(icalLink);  // Sauvegarder le lien iCal
      print('Lien iCal sauvegardé : $icalLink');
    } else if (_icalFilePath != null) {
      print('Fichier iCal sauvegardé : $_icalFilePath');
    } else {
      print('Aucune donnée fournie');
    }
    // Revenir à l'écran précédent
    Navigator.pop(context);
  }
}
