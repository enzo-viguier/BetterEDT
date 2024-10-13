import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'setting_screen.dart';
import 'data_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(BetterEDT());
}

class BetterEDT extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BetterEDT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarScreen(),
    );
  }
}

//
class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarController _calendarController;
  List<Appointment> _appointments = [];
  String? _icalLink;
  DataService dataService = DataService();

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _calendarController.view = CalendarView.day;  // On commence par la vue "jour"
    _downloadIcalAndUpdate();
  }

  // Télécharger et parser le fichier iCal, puis mettre à jour les événements
  void _downloadIcalAndUpdate() async {
    final icalFile = await dataService.downloadIcalFile();
    if (icalFile != null) {
      final events = await dataService.parseIcalFile();
      _appointments = _convertEventsToAppointments(events);  // Convertir en objets Appointment
      setState(() {});  // Mettre à jour l'affichage
    } else {
      print('Erreur lors du téléchargement du fichier iCal');
    }
  }

  // Convertir les événements iCal en objets Appointment
  List<Appointment> _convertEventsToAppointments(List<Map<String, dynamic>> events) {
    return events.map((event) {
      print("Date début : " + DateTime.parse(event['start']).toString());
      print("Date fin : " + DateTime.parse(event['end']).toString());
      return Appointment(
        startTime: DateTime.parse(event['start'] ?? DateTime.now().toString()),
        endTime: DateTime.parse(event['end'] ?? DateTime.now().add(Duration(hours: 1)).toString()),
        subject: event['summary'] ?? 'Sans titre',
        location: event['location'] ?? 'Aucun lieu',
        notes: event['description'] ?? '',
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emploi du Temps'),
        actions: [
          // Bouton pour basculer entre la vue "jour" et "semaine"
          IconButton(
            icon: Icon(_calendarController.view == CalendarView.day ? Icons.view_week : Icons.view_day),
            onPressed: () {
              setState(() {
                if (_calendarController.view == CalendarView.day) {
                  _calendarController.view = CalendarView.week;
                } else {
                  _calendarController.view = CalendarView.day;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigation vers la page Paramètres
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              ).then((_) {
                // Recharger les événements lorsque l'utilisateur revient de la page des paramètres
              });
            },
          ),
        ],
      ),
      body: SfCalendar(
        controller: _calendarController,  // On associe le CalendarController
        firstDayOfWeek: 1,
        timeSlotViewSettings: TimeSlotViewSettings(
          timeFormat: 'HH:mm',  // Format 24 heures
        ),
        appointmentTimeTextFormat: 'HH:mm',
        view: CalendarView.day,  // Vue par défaut
        todayHighlightColor: Colors.blue,
        backgroundColor: Colors.white,
        initialSelectedDate: DateTime.now(),  // Sélectionne automatiquement la date actuelle
        dataSource: AppointmentDataSource(_appointments),  // Utiliser les événements récupérés
        appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
          final Appointment appointment = details.appointments.first;
          return Container(
            padding: EdgeInsets.all(4),
            color: appointment.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.subject, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                // Si l'emploi du temps est en vision semaine, appointement.location n'est pas affiché
                if (_calendarController.view == CalendarView.day)
                Text(appointment.location ?? '', style: TextStyle(color: Colors.white70)),
              ],
            ),
          );
        },
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.appointment) {
            final Appointment tappedAppointment = details.appointments!.first;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(tappedAppointment.subject),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Salle: ${tappedAppointment.location ?? 'Non spécifié'}"),
                      Text("${tappedAppointment.notes ?? 'Non spécifié'}"),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Fermer'),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();  // Nettoie le controller lorsque le widget est détruit
    super.dispose();
  }
}

// Classe de gestion des événements pour le calendrier
class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
