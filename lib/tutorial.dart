import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Obtenir le lien iCal'),
      ),
      body: SingleChildScrollView(  // Permet le défilement si le contenu est long
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTutorialSection(
                text: "Étape 1 : Connectez-vous à l'ENT et accédez à votre emploi du temps avec l'onglet \"Planning 2X-2X\".",
                imagePath: 'lib/assets/images/ent_menu.png',
              ),
              SizedBox(height: 40),
              _buildTutorialSection(
                text: "Étape 2 : Dans le menu du planning, cliquer sur le bouton iCal",
                imagePath: 'lib/assets/images/planning_menu.png',
              ),
              SizedBox(height: 40),
              _buildTutorialSection(
                text: "Étape 3 : Copier entièrement le lien iCal.",
                imagePath: 'lib/assets/images/iCal_page.png',
              ),
              SizedBox(height: 40),
              _buildTutorialSection(
                text: "Étape 4 : Coller le lien dans l'application dans la boite de texte et sauvegarder.",
                imagePath: 'lib/assets/images/setting_page.png',
              ),
              SizedBox(height: 40),
              _buildTutorialSection(
                text: "IMPORTANT: Penser à chaque semestre à mettre à jour votre emploi du temps dans \"Préférence\" et de changer le lien iCal dans l'application.",
                imagePath: 'lib/assets/images/planning_menu.png',
              ),
              SizedBox(height: 40),
              _buildTutorialSection(
                text: "Profiter de votre emploi du temps.",
                imagePath: 'lib/assets/images/happy.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialSection({required String text, required String imagePath}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: text.contains("IMPORTANT") ? Colors.red : Colors.black, // Met en rouge si le texte contient "IMPORTANT"
            ),
          ),
        ),
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity, // S'adapte à la largeur de l'écran
        ),
      ],
    );
  }

}
