import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar_service.dart';
import 'setting_screen.dart';


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

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarController _calendarController;
  List<Appointment> _appointments = [];
  CalendarService _calendarService = CalendarService();
  String? _icalLink;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _calendarController.view = CalendarView.day;  // On commence par la vue "jour"
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
            icon: Icon(Icons.settings),
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
        todayHighlightColor: Colors.blue,
        backgroundColor: Colors.white,
        initialSelectedDate: DateTime.now(),  // Sélectionne automatiquement la date actuelle
        dataSource: AppointmentDataSource(_appointments),  // Utiliser les événements récupérés
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
