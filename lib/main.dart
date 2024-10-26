import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'setting_screen.dart';
import 'data_service.dart';
import 'l10n.dart';

void main() {
  runApp(const BetterEDT());
}

class BetterEDT extends StatelessWidget {
  const BetterEDT({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SfGlobalLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      debugShowCheckedModeBanner: false,
      title: 'BetterEDT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarController _calendarController;
  List<Appointment> _appointments = [];
  DataService dataService = DataService();

  var logger = Logger();

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

      logger.e('Erreur lors du téléchargement du fichier iCal');

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.translate('ErrorDownloadICalFile')))
      );

    }

  }

  // Convertir les événements iCal en objets Appointment
  List<Appointment> _convertEventsToAppointments(List<Map<String, dynamic>> events) {
    return events.map((event) {
      final DateTime? startUtc = event['start']; // DateTime en UTC
      final DateTime? endUtc = event['end'];     // DateTime en UTC

      final DateTime? startLocal = startUtc?.toLocal();  // Conversion en local
      final DateTime? endLocal = endUtc?.toLocal();      // Conversion en local

      final String? subject = event['summary'] ?? AppLocalizations.of(context)!.translate("Untitled");
      final String? location = event['location'] ?? AppLocalizations.of(context)!.translate("NoPlace");
      final String? description = event['description'] ?? AppLocalizations.of(context)!.translate("NoDescription");

      return Appointment(
        startTime: startLocal ?? DateTime.now(),
        endTime: endLocal ?? DateTime.now().add(const Duration(hours: 1)),
        subject: subject ?? AppLocalizations.of(context)!.translate("Untitled"),
        location: location,
        notes: description, // Utilise notes pour afficher la description
        color: Colors.blue, // Peut être personnalisé
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('AppBarHomePage')),
        actions: [
          // Bouton pour basculer entre la vue "jour" et "semaine"
          IconButton(
            icon: Icon(_calendarController.view == CalendarView.day ? Icons.view_week : Icons.view_day),
            onPressed: () {
              setState(() {
                if (_calendarController.view == CalendarView.day) {
                  _calendarController.view = CalendarView.workWeek;
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
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) {
                _downloadIcalAndUpdate();
              });
            },
          ),
        ],
      ),
      body: SfCalendar(
        controller: _calendarController,  // On associe le CalendarController
        firstDayOfWeek: 1,
        timeSlotViewSettings: const TimeSlotViewSettings(
          timeFormat: 'HH:mm',  // Format 24 heures
          startHour: 7, // Commence à 7h00
          endHour: 22,  // Termine à 21h00
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
            padding: const EdgeInsets.all(4),
            color: appointment.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.subject, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                // Si l'emploi du temps est en vision semaine, appointement.location n'est pas affiché
                if (_calendarController.view == CalendarView.day)
                Text(appointment.location ?? '', style: const TextStyle(color: Colors.white70)),
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
                      Text("${AppLocalizations.of(context)!.translate('Room')}: ${tappedAppointment.location ?? AppLocalizations.of(context)!.translate('NotSpecified')}"),
                      Text(tappedAppointment.notes ?? AppLocalizations.of(context)!.translate('NotSpecified')),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.translate('Close')),
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
