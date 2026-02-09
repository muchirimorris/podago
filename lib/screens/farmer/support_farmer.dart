import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:podago/widgets/bottom_nav_bar.dart';
import 'package:podago/utils/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podago/screens/shared/chat_screen.dart'; // NEW

class FarmerSupportScreen extends StatefulWidget {
  final String farmerId;

  const FarmerSupportScreen({super.key, required this.farmerId});

  @override
  State<FarmerSupportScreen> createState() => _FarmerSupportScreenState();
}

class _FarmerSupportScreenState extends State<FarmerSupportScreen> {
  String _farmerName = "Farmer";
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _fetchFarmerName();
  }

  Future<void> _fetchFarmerName() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.farmerId).get();
      if (doc.exists && mounted) {
        setState(() {
          _farmerName = doc.data()?['name'] ?? "Farmer";
          _isLoadingName = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingName = false);
    }
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot open $url'), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
        );
      }
    }
  }

  // WhatsApp
  Future<void> _launchWhatsApp(BuildContext context) async {
    const phone = "254792746672";
    const message = "Hello, I need support with my Podago account";
    final url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";
    await _launchUrl(url, context);
  }

  // Phone Call
  Future<void> _launchPhoneCall(BuildContext context) async {
    const phone = "+254792746672";
    final url = "tel:$phone";
    await _launchUrl(url, context);
  }

  // SMS
  Future<void> _launchSMS(BuildContext context) async {
    const phone = "+254792746672";
    const message = "Hello, I need support with my Podago account";
    final url = "sms:$phone?body=${Uri.encodeComponent(message)}";
    await _launchUrl(url, context);
  }

  // Email
  Future<void> _launchEmail(BuildContext context) async {
    const email = "muchirimorris007@gmail.com";
    const subject = "Support Request - Podago Farmer";
    const body = "Hello Podago Support Team,\n\nI need assistance with:\n\n";
    final url = "mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}";
    await _launchUrl(url, context);
  }

  void _openInAppChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          userId: widget.farmerId,
          userName: _farmerName,
          userRole: 'farmer',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Help & Support"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Card ---
            _buildHeroCard(),
            const SizedBox(height: 24),

            // --- NEW: In-App Chat Section ---
            Text("Live Support", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _openInAppChat,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  border: Border.all(color: AppTheme.kPrimaryGreen.withOpacity(0.3), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.kPrimaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chat, color: AppTheme.kPrimaryGreen, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Chat with Support", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                          const SizedBox(height: 4),
                          Text(
                            "Get instant help directly in the app.",
                            style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.kPrimaryGreen),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Account Security Section ---
            Text("Account Security", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.lock_reset, color: Colors.orange),
                ),
                title: Text("Change Login PIN", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
                subtitle: Text("Update your 4-digit security PIN", style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () => _showChangePinDialog(context),
              ),
            ),
            const SizedBox(height: 24),

            // --- Contact Grid (Replaces vertical list) ---
            Text("Other Ways to Connect", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildContactTile(
                  icon: Icons.headset_mic,
                  title: "Call Support",
                  subtitle: "Talk to us",
                  color: Colors.blue,
                  onTap: () => _launchPhoneCall(context),
                  context: context,
                ),
                _buildContactTile(
                  icon: Icons.chat_bubble,
                  title: "WhatsApp",
                  subtitle: "Chat now",
                  color: Colors.green,
                  onTap: () => _launchWhatsApp(context),
                  context: context,
                ),
                _buildContactTile(
                  icon: Icons.email,
                  title: "Email",
                  subtitle: "Send details",
                  color: Colors.purple,
                  onTap: () => _launchEmail(context),
                  context: context,
                ),
                _buildContactTile(
                  icon: Icons.sms,
                  title: "SMS",
                  subtitle: "Text us",
                  color: Colors.orange,
                  onTap: () => _launchSMS(context),
                  context: context,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- FAQ Section ---
            Text("Frequently Asked Questions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            _buildFAQList(context),

            const SizedBox(height: 24),

            // --- Footer Info ---
            Center(
              child: Column(
                children: [
                  Icon(Icons.verified_user_outlined, color: Colors.grey.shade400, size: 40),
                  const SizedBox(height: 8),
                  Text("Support ID: ${widget.farmerId}", style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                  const SizedBox(height: 4),
                  Text("v1.0.0 • Podago Secure", style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
        role: "farmer",
        farmerId: widget.farmerId,
      ),
    );
  }

  // --- UI Components ---

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.kPrimaryGreen, AppTheme.kPrimaryGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppTheme.kPrimaryGreen.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.support_agent, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          const Text("How can we help?", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            "Our team is available 24/7 to assist with payments, collections, and app issues.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
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
              const SizedBox(height: 4),
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
          _buildFAQTile(
            "How do I update my profile?",
            "Navigate to your profile section and tap on 'Edit Profile' to update your personal details securely.",
            context,
            showDivider: true,
          ),
          _buildFAQTile(
            "When are payments processed?",
            "Payments are automatically processed every Friday for the previous week's milk collection totals.",
            context,
            showDivider: true,
          ),
          _buildFAQTile(
            "Incorrect milk records?",
            "If you spot a discrepancy, please use the WhatsApp button above to send us a screenshot of your receipt.",
            context,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer, BuildContext context, {bool showDivider = true}) {
    return Column(
      children: [
        Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(question, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
            childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            children: [
              Text(answer, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5)),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 20, endIndent: 20),
      ],
    );
  }

  void _showChangePinDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ChangePinDialog(farmerDocId: widget.farmerId),
    );
  }
}

class _ChangePinDialog extends StatefulWidget {
  final String farmerDocId;
  const _ChangePinDialog({required this.farmerDocId});

  @override
  State<_ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<_ChangePinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _updatePin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Verify Old PIN
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.farmerDocId).get();
      if (!docSnapshot.exists) throw "User not found";
      
      final currentPin = docSnapshot.data()?['pin'];
      if (currentPin != _oldPinController.text.trim()) {
        throw "Incorrect current PIN";
      }

      // 2. Update to New PIN
      await FirebaseFirestore.instance.collection('users').doc(widget.farmerDocId).update({
        'pin': _newPinController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PIN updated successfully"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Change Login PIN", style: TextStyle(fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPinField("Current PIN", _oldPinController, _obscureOld, (val) {
                setState(() => _obscureOld = val);
              }),
              const SizedBox(height: 16),
              _buildPinField("New PIN (4 digits)", _newPinController, _obscureNew, (val) {
                setState(() => _obscureNew = val);
              }, validator: (val) {
                if (val == null || val.length != 4) return "Must be 4 digits";
                return null;
              }),
              const SizedBox(height: 16),
              _buildPinField("Confirm New PIN", _confirmPinController, _obscureConfirm, (val) {
                setState(() => _obscureConfirm = val);
              }, validator: (val) {
                if (val != _newPinController.text) return "PINs do not match";
                return null;
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updatePin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.kPrimaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Update"),
        ),
      ],
    );
  }

  Widget _buildPinField(
    String label, 
    TextEditingController controller, 
    bool obscure, 
    Function(bool) onToggle,
    {String? Function(String?)? validator}
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: TextInputType.number,
      maxLength: 4,
      validator: validator ?? (val) => (val == null || val.isEmpty) ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        counterText: "",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => onToggle(!obscure),
        ),
      ),
    );
  }
}