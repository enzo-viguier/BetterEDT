import 'package:better_edt/l10n.dart';
import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('GetIcalLink')),
      ),
      body: SingleChildScrollView(  // Permet le défilement si le contenu est long
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTutorialSection(
                text: AppLocalizations.of(context)!.translate('FirstStep').replaceAll(r'\"', '"'),
                imagePath: 'lib/assets/images/ent_menu.png',
              ),
              const SizedBox(height: 40),
              _buildTutorialSection(
                text: AppLocalizations.of(context)!.translate('SecondStep'),
                imagePath: 'lib/assets/images/planning_menu.png',
              ),
              const SizedBox(height: 40),
              _buildTutorialSection(
                text: AppLocalizations.of(context)!.translate('ThirdStep'),
                imagePath: 'lib/assets/images/iCal_page.png',
              ),
              const SizedBox(height: 40),
              _buildTutorialSection(
                text: AppLocalizations.of(context)!.translate('FourthStep'),
                imagePath: 'lib/assets/images/setting_page.png',
              ),
              const SizedBox(height: 40),
              _buildTutorialSection(
                text: AppLocalizations.of(context)!.translate('ImportantStep').replaceAll(r'\"', '"'),
                imagePath: 'lib/assets/images/planning_menu.png',
              ),
              const SizedBox(height: 40),
              _buildTutorialSection(
                text: AppLocalizations.of(context)!.translate('EnjoyStep'),
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
