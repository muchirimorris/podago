import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:podago/widgets/bottom_nav_bar.dart';
import 'package:podago/screens/shared/chat_screen.dart'; // NEW import

class CollectorSupportScreen extends StatelessWidget {
  final String? collectorId; // NEW

  const CollectorSupportScreen({super.key, this.collectorId});

  // --- Professional Theme Colors ---
  // Using AppTheme constants

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri telLaunchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(telLaunchUri)) {
      await launchUrl(telLaunchUri);
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'muchirimorris007@gmail.com',
      queryParameters: {
        'subject': 'Collector Support Request',
        'body': 'Hello Support Team,\n\nI need assistance with:',
      },
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  Future<void> _launchWhatsApp() async {
    final Uri whatsappLaunchUri = Uri(
      scheme: 'https',
      path: 'wa.me/254792746672',
      queryParameters: {
        'text': 'Hello! I need support with the Milk Collector app.',
      },
    );
    if (await canLaunchUrl(whatsappLaunchUri)) {
      await launchUrl(whatsappLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Support Center", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeroCard(context),
            const SizedBox(height: 24),

            // Contact Grid
            Text("Get in Touch", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            _buildContactGrid(context),

            const SizedBox(height: 24),

            // FAQ
            Text("Frequently Asked Questions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            _buildFAQList(context),

            const SizedBox(height: 24),

            // Emergency
            _buildEmergencySection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3, role: "collector", collectorId: collectorId),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("We're here to help", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(
                        "Get assistance with app features, sync issues, or general inquiries.",
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (collectorId != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          userId: collectorId!,
                          userName: "Collector", 
                          userRole: "collector",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat, color: Colors.green),
                  label: const Text("Chat with Support", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
      );
    }

  Widget _buildContactGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildContactTile(
          context,
          icon: Icons.phone_in_talk,
          title: "Call Us",
          subtitle: "+254 792...",
          color: Colors.blue,
          onTap: () => _launchPhone("+254792746672"),
        ),
        _buildContactTile(
          context,
          icon: Icons.chat_bubble_outline,
          title: "WhatsApp",
          subtitle: "Chat Support",
          color: Colors.green,
          onTap: _launchWhatsApp,
        ),
        _buildContactTile(
          context,
          icon: Icons.email_outlined,
          title: "Email",
          subtitle: "Send details",
          color: Colors.orange,
          onTap: _launchEmail,
        ),
      ],
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Column(
        children: [
          _buildFAQItem(
            context,
            "How do I register a new farmer?",
            "Go to the Dashboard and tap the 'person with plus' icon in the top right corner. Fill in the required details.",
            showDivider: true,
          ),
          _buildFAQItem(
            context,
            "Can I edit records?",
            "For security reasons, records cannot be edited after submission. Please contact admin for corrections.",
            showDivider: true,
          ),
          _buildFAQItem(
            context,
            "What if I lose internet?",
            "The app automatically saves data locally. It will sync to the cloud once you are back online.",
            showDivider: true,
          ),
          _buildFAQItem(
            context,
            "How do I reset a PIN?",
            "Contact support using the buttons above to request a PIN reset for a farmer.",
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer, {bool showDivider = true}) {
    return Column(
      children: [
        Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            title: Text(question, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              Text(answer, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5)),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: Colors.grey.shade100, indent: 20, endIndent: 20),
      ],
    );
  }

  Widget _buildEmergencySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
              const SizedBox(width: 8),
              Text("Emergency Support", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade800)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "For urgent technical issues preventing collection.",
            style: TextStyle(color: Colors.red.shade700, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchPhone("+254792746672"),
              icon: const Icon(Icons.emergency, size: 18),
              label: const Text("Call Emergency Line"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}