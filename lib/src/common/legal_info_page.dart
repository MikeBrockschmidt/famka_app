// lib/src/common/legal_info_page.dart

import 'package:flutter/material.dart';

class LegalInfoPage extends StatelessWidget {
  const LegalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Rechtliche Informationen'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impressum',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Angaben gemäß § 5 TMG',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            const Text(
              'Max Mustermann\nMusterweg 123\n12345 Musterstadt\nDeutschland',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              'Kontakt:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            const Text(
              'Telefon: +49 123 456789\nE-Mail: kontakt@famka-app.de',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Text(
              'Datenschutzerklärung',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              '1. Erhebung und Verarbeitung personenbezogener Daten',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            const Text(
              'Wir nehmen den Schutz Ihrer persönlichen Daten sehr ernst. Wenn Sie unsere App nutzen, erheben wir verschiedene Arten von Informationen zu unterschiedlichen Zwecken, um unseren Dienst bereitzustellen und zu verbessern. Dazu gehören:\n\n'
              '- **Bestandsdaten:** Ihr Vorname, Nachname und E-Mail-Adresse, die Sie bei der Registrierung angeben.\n'
              '- **Nutzungsdaten:** Informationen darüber, wie die App genutzt wird (z.B. besuchte Seiten, Verweildauer, Interaktionen).\n'
              '- **Gerätedaten:** Informationen über das von Ihnen verwendete Gerät (z.B. Gerätetyp, Betriebssystemversion, eindeutige Gerätekennungen).\n'
              '- **Avatar-URL und optionale Telefonnummer/Notizen:** Wenn Sie diese in Ihrem Profil hinterlegen.\n\n'
              'Diese Daten werden zur Bereitstellung der App-Funktionen, zur Personalisierung Ihres Erlebnisses, zur Verbesserung unserer Dienste und zur Fehlerbehebung verarbeitet.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '2. Weitergabe von Daten',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            const Text(
              'Wir geben Ihre personenbezogenen Daten grundsätzlich nicht an Dritte weiter, es sei denn, dies ist gesetzlich vorgeschrieben oder für die Erbringung unserer Dienste erforderlich. Externe Dienstleister, die wir einsetzen (z.B. Firebase für Authentifizierung und Datenbank, Speicherdienste für Bilder), werden sorgfältig ausgewählt und vertraglich zur Einhaltung des Datenschutzes verpflichtet. Eine Weitergabe an Dritte erfolgt nur im Rahmen der von Ihnen erteilten Einwilligung oder aufgrund gesetzlicher Bestimmungen.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '3. Ihre Rechte',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            const Text(
              'Sie haben das Recht, jederzeit Auskunft über Ihre bei uns gespeicherten personenbezogenen Daten zu erhalten. Des Weiteren haben Sie das Recht auf Berichtigung, Sperrung oder Löschung dieser Daten, sofern dem keine gesetzlichen Aufbewahrungspflichten entgegenstehen. Bitte kontaktieren Sie uns dazu über die im Impressum angegebene E-Mail-Adresse.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Text(
              'Nutzungsbedingungen (Optional)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            const Text(
              'Die Nutzung der Famka-App unterliegt den hier dargelegten Nutzungsbedingungen. Durch die Registrierung und Nutzung der App erklären Sie sich mit diesen Bedingungen einverstanden. Die App ist für die Organisation von Familienaktivitäten und Gruppenereignissen gedacht. Missbrauch der App, das Posten von unangemessenen Inhalten oder die Verletzung der Rechte Dritter ist untersagt. Wir behalten uns das Recht vor, Nutzerkonten bei Verstößen gegen diese Bedingungen zu sperren oder zu löschen. Wir übernehmen keine Haftung für die Richtigkeit der von Nutzern bereitgestellten Inhalte oder für Schäden, die aus der Nutzung der App entstehen, es sei denn, diese beruhen auf grober Fahrlässigkeit oder Vorsatz unsererseits.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
