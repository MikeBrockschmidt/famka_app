import 'package:flutter/material.dart';
import 'package:famka_app/src/theme/color_theme.dart';

class LegalInfoPage extends StatefulWidget {
  const LegalInfoPage({super.key});

  @override
  State<LegalInfoPage> createState() => _LegalInfoPageState();
}

class _LegalInfoPageState extends State<LegalInfoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Rechtliche Informationen'),
        backgroundColor: AppColors.famkaWhite,
        foregroundColor: AppColors.famkaBlack,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.famkaGreen,
          unselectedLabelColor: AppColors.famkaGrey,
          indicatorColor: AppColors.famkaGreen,
          tabs: const [
            Tab(text: 'Impressum'),
            Tab(text: 'Datenschutz'),
            Tab(text: 'AGB'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildImpressumTab(),
          _buildDatenschutzTab(),
          _buildAGBTab(),
        ],
      ),
    );
  }

  Widget _buildImpressumTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.famkaGreen, Color(0xFF81C784)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '💎 FAMKA Premium - 100% Werbefrei',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Impressum',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.famkaBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          _buildSection(
            'Angaben gemäß § 5 TMG',
            'Mike Brockschmidt\n[Ihre Adresse]\n[PLZ Stadt]\nDeutschland',
          ),

          _buildSection(
            '📧 Kontakt',
            'E-Mail: info@famka-app.de\nSupport: support@famka-app.de\nPrivacy: privacy@famka-app.de',
          ),

          _buildSection(
            '📱 App-Details',
            'FAMKA Familienkalender Premium\nVersion: 2.0.0\nPlattform: iOS\nPreis: €3.99 (einmalig über App Store)\nKategorie: Lifestyle / Produktivität',
          ),

          _buildSection(
            '⚖️ Rechtliche Hinweise',
            'Als Diensteanbieter sind wir gemäß § 7 Abs.1 TMG für eigene Inhalte nach den allgemeinen Gesetzen verantwortlich.\n\nFür externe Links übernehmen wir keine Haftung.\n\nAlle Inhalte unterliegen dem deutschen Urheberrecht.',
          ),

          _buildSection(
            '🌍 EU-Streitschlichtung',
            'Online-Streitbeilegung: https://ec.europa.eu/consumers/odr/',
          ),
        ],
      ),
    );
  }

  Widget _buildDatenschutzTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Highlight Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.famkaGreen, width: 2),
            ),
            child: const Text(
              '🎯 FAMKA Versprechen:\n100% WERBEFREI - Keine Tracking-Partner!\nIhre Familiendaten bleiben privat.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Datenschutzerklärung',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.famkaBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          _buildSection(
            '📊 Welche Daten sammeln wir?',
            '• Anmeldedaten: E-Mail, Name, Passwort (verschlüsselt)\n• Nutzungsdaten: Termine, Fotos, Gruppeninformationen\n• Technische Daten: Geräte-ID, App-Version (nur für Support)\n• Optional: Telefonnummer, Avatar (von Ihnen gewählt)',
          ),

          _buildSection(
            '🎯 Warum sammeln wir diese Daten?',
            '• Funktionalität: Kalender- und Gruppenfunktionen\n• Synchronisation: Echtzeit-Updates in der Familie\n• Sicherheit: Schutz vor Missbrauch\n• Support: Technische Hilfe bei Problemen',
          ),

          _buildSection(
            '🔒 Datensicherheit',
            '• SSL/TLS für sichere Datenübertragung\n• Firebase-Server (Google Cloud, EU-Region)\n• Regelmäßige Sicherheitsupdates\n• KEINE Weitergabe an Werbepartner!',
          ),

          _buildSection(
            '⚖️ Ihre DSGVO-Rechte',
            '• Auskunft über gespeicherte Daten\n• Berichtigung falscher Daten\n• Löschung Ihres Accounts (vollständig nach 30 Tagen)\n• Datenübertragbarkeit (Export-Funktion)\n• Widerspruch gegen Verarbeitung',
          ),

          _buildSection(
            '📧 Datenschutz-Kontakt',
            'E-Mail: privacy@famka-app.de\nReaktionszeit: 24h (Mo-Fr)',
          ),
        ],
      ),
    );
  }

  Widget _buildAGBTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Allgemeine Geschäftsbedingungen',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.famkaBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          _buildSection(
            '🛒 Premium-Kauf',
            'iOS: €3.99 (einmalig über App Store)\n\nZahlung über Apple - keine separaten Zahlungsdaten nötig.',
          ),

          // Premium Features Highlight
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.famkaGreen.withOpacity(0.1), Colors.white],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.famkaGreen),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ Premium-Features',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.famkaGreen),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 100% werbefrei - garantiert!\n• Unbegrenzte Familienmitglieder (bis 20)\n• Vollständige Kalenderfunktionen\n• Zeitraum-Bearbeitung für Events\n• Hochauflösende Fotogalerie\n• Priority E-Mail-Support (24h)',
                ),
              ],
            ),
          ),

          _buildSection(
            '📱 Nutzungsrechte',
            'Erlaubt:\n• Persönliche/familiäre Nutzung\n• Installation auf eigenen Geräten\n• Daten-Export\n\nVerboten:\n• Kommerzielle Nutzung\n• Weitergabe der App\n• Reverse Engineering',
          ),

          _buildSection(
            '↩️ EU-Widerrufsrecht',
            '14-Tage-Widerrufsrecht für digitale Inhalte.\n\nDas Widerrufsrecht erlischt bei Beginn der Nutzung nach Ihrer Zustimmung.\n\nWiderruf über: Apple App Store',
          ),

          _buildSection(
            '🛠️ Support & Verfügbarkeit',
            '• 24/7 App-Verfügbarkeit (99,5% Uptime-Ziel)\n• E-Mail-Support: support@famka-app.de\n• Reaktionszeit: 24h (Mo-Fr)\n• Kostenlose Updates\n• Gesetzliche Gewährleistung (24 Monate EU)',
          ),

          _buildSection(
            '⚖️ Recht & Gerichtsstand',
            'Deutsches Recht (unter Ausschluss UN-Kaufrecht)\nGerichtsstand: Deutschland\nEU-Verbraucherrechte bleiben unberührt',
          ),

          const SizedBox(height: 30),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.famkaGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'FAMKA Premium v2.0.0\nStand: November 2025',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.famkaGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.famkaBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.famkaBlack,
            ),
          ),
        ],
      ),
    );
  }
}
