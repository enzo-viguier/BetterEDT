import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarService {
  // Fonction pour récupérer et sauvegarder le fichier .ics
  Future<void> downloadIcsFile(String icalUrl) async {
    try {
      // Récupérer le fichier iCal via HTTP
      final response = await http.get(Uri.parse(icalUrl));

      if (response.statusCode == 200) {
        // Enregistrer le fichier .ics localement
        final file = await _getLocalFile();
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Failed to download iCal');
      }
    } catch (e) {
      print('Erreur lors du téléchargement du fichier iCal: $e');
    }
  }

  // Fonction pour obtenir le fichier local .ics
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/calendar.ics';
    return File(filePath);
  }

  // Fonction pour charger le fichier .ics localement (s'il existe)
  Future<List<Appointment>> loadLocalIcsFile() async {
    try {
      final file = await _getLocalFile();

      if (await file.exists()) {
        // Lire et parser le fichier localement
        final fileContent = await file.readAsString();
        final ical = ICalendar.fromString(fileContent);

        // Extraire les événements et les convertir en 'Appointment' pour le calendrier
        return _parseICalToAppointments(ical.data);
      } else {
        print('Aucun fichier .ics trouvé localement');
        return [];
      }
    } catch (e) {
      print('Erreur lors de la lecture du fichier iCal: $e');
      return [];
    }
  }

  // Fonction pour convertir les événements iCal en objets Appointment
  List<Appointment> _parseICalToAppointments(List<Map<String, dynamic>> data) {
    List<Appointment> appointments = [];

    for (var event in data) {
      if (event['type'] == 'VEVENT') {
        // Extraire les informations nécessaires pour chaque événement
        String summary = event['SUMMARY'] ?? 'Sans titre';
        DateTime start = DateTime.parse(event['DTSTART']);
        DateTime end = DateTime.parse(event['DTEND']);
        String location = event['LOCATION'] ?? 'Aucun lieu';
        String description = event['DESCRIPTION'] ?? '';

        // Créer un objet Appointment pour chaque événement
        appointments.add(Appointment(
          startTime: start,
          endTime: end,
          subject: summary,
          location: location,
          notes: description,
          color: Colors.blue,
          isAllDay: false,
        ));
      }
    }
    return appointments;
  }
}
