import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icalendar_parser/icalendar_parser.dart';


class DataService {

  var logger = Logger();

  // Méthode pour récupérer le lien iCal depuis SharedPreferences
  Future<String?> _getIcalLink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('ical_link');
  }

  // Méthode pour télécharger le fichier iCal à partir du lien
  Future<File?> downloadIcalFile() async {
    String? icalLink = await _getIcalLink();

    if (icalLink == null || icalLink.isEmpty) {
      logger.i('Lien iCal non trouvé.');
      return null;
    }

    try {
      // Faire la requête HTTP pour récupérer le fichier .ics
      final response = await http.get(Uri.parse(icalLink));

      if (response.statusCode == 200) {
        // Vérification si le contenu du fichier ressemble à un fichier iCal
        String responseBody = response.body;
        if (responseBody.contains("BEGIN:VCALENDAR")) {
          // Obtenir le chemin vers le répertoire local
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/calendar.ics';

          // Sauvegarder les données dans un fichier local
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          logger.i('Fichier iCal téléchargé et sauvegardé à $filePath');
          return file;
        } else {
          logger.w('Le fichier récupéré n\'est pas un fichier iCal valide.');
          return _getLocalIcalFile();  // Utiliser le fichier local en cas de mauvais format
        }
      }
      else {
        logger.w('Erreur lors de la récupération du fichier iCal : ${response.statusCode}');
        return _getLocalIcalFile();
      }
    } catch (e) {
      logger.w('Erreur lors de la récupération du fichier iCal : $e');
      return _getLocalIcalFile();
    }

  }

  // Méthode pour récupérer le fichier iCal déjà téléchargé localement
  Future<File?> _getLocalIcalFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/calendar.ics';
      final file = File(filePath);

      if (await file.exists()) {
        logger.i('Utilisation du fichier iCal local.');
        return file;
      } else {
        logger.w('Aucun fichier iCal local trouvé.');
        return null;
      }
    } catch (e) {
      logger.w('Erreur lors de la récupération du fichier iCal local : $e');
      return null;
    }
  }

  String icalToDateTimeString(String icalDate) {
    // Convertir le format iCalendar en un format compatible avec DateTime.parse()
    // Exemple : 20241107T084500Z -> 2024-11-07T08:45:00Z
    return icalDate.substring(0, 4) + '-' +
        icalDate.substring(4, 6) + '-' +
        icalDate.substring(6, 8) + 'T' +
        icalDate.substring(9, 11) + ':' +
        icalDate.substring(11, 13) + ':' +
        icalDate.substring(13, 15) + 'Z';
  }


  Future<List<Map<String, dynamic>>> parseIcalFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/calendar.ics';
      final file = File(filePath);
      final icalString = await file.readAsString();
      final icalendar = ICalendar.fromString(icalString);

      // Extraire les événements VEVENT en utilisant 'type'
      final events = icalendar.data.where((component) => component['type'] == 'VEVENT').toList();

      // Mapper les événements en un format plus simple
      return events.map((event) {

        event['description'] = event['description']?.replaceAll('\\n', '\n');

        // Dans event['description'], Je veux garder tous ce qui a avant "A valider" et supprimer tout ce qui a après
        if (event['description'] != null) {
          final description = event['description'];
          final index = description.indexOf("A valider");
          if (index != -1) {
            event['description'] = description.substring(0, index);
          }
        }

        // Convertir les dates iCal en DateTime
        final String? dtstart = event['dtstart']?.dt;
        final String? dtend = event['dtend']?.dt;

        DateTime? startDate;
        DateTime? endDate;

        if (dtstart != null && dtend != null) {
          startDate = DateTime.parse(icalToDateTimeString(dtstart));
          endDate = DateTime.parse(icalToDateTimeString(dtend));
        }

        return {
          'start': startDate,
          'end': endDate,
          'summary': event['summary'],
          'location': event['location'],
          'description': event['description'],
        };
      }).toList();
    } catch (e) {
      if (e is ICalendarFormatException && e == "The first line must be BEGIN:VCALENDAR but was <!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">.") {
        logger.e("Erreur : Le service EDT n'est pas accessible ou est en maintenance.");
      }
      return [];
    }
  }

}
