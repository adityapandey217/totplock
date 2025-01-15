import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totplock/components/button.dart';
import 'package:totplock/utils/totp_provider.dart';
import 'package:f_authenticator/f_authenticator.dart';

class SetupKeyScreen extends StatefulWidget {
  const SetupKeyScreen({super.key});

  @override
  State<SetupKeyScreen> createState() => _SetupKeyScreenState();
}

class _SetupKeyScreenState extends State<SetupKeyScreen> {
  final _accountNameController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _issuerController = TextEditingController();
  final key = GlobalKey<FormState>();

  String? accountNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account Name is required';
    }
    if (value.length < 2) {
      return 'Account Name must be at least 2 characters';
    }
    if (value.length > 32) {
      return 'Account Name must be at most 32 characters';
    }
    return null;
  }

  String? totpSecretValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Secret Key is required';
    }
    if (value.length < 16) {
      return 'Secret Key must be at least 16 characters';
    }
    if (value.length > 32) {
      return 'Secret Key must be at most 32 characters';
    }
    // CHECK IF SECRET KEY IS BASE32
    RegExp regExp = RegExp(r'^[A-Z2-7]*$');
    if (!regExp.hasMatch(value)) {
      return 'Secret Key must be base32 encoded. Only characters A-Z and 2-7 are allowed';
    }
    return null;
  }

  void saveAccount() {
    if (key.currentState!.validate()) {
      final totpProvider = Provider.of<TotpProvider>(context, listen: false);
      FAuthenticator authenticator = FAuthenticator(
        appName: _issuerController.text,
        username: _accountNameController.text,
        secret: _secretKeyController.text.toUpperCase().replaceAll(' ', ''),
      );
      String totpUri = authenticator.getLink;
      totpProvider.addTotpEntry(totpUri, _secretKeyController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Setup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Manual Setup Help'),
                content: const SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('How to set up manually:'),
                      SizedBox(height: 8),
                      Text(
                          '1. Enter the account name (e.g., "Gmail", "GitHub")'),
                      Text(
                          '2. Enter the issuer name (e.g., "Google", "GitHub")'),
                      Text('3. Enter the secret key provided by the service'),
                      SizedBox(height: 16),
                      Text(
                          'Note: The secret key is case-insensitive and spaces are automatically removed.'),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _accountNameController,
                          decoration: const InputDecoration(
                            labelText: 'Account Name',
                            prefixIcon: Icon(Icons.account_circle),
                            border: OutlineInputBorder(),
                            helperText: 'e.g., Gmail, GitHub, etc.',
                          ),
                          validator: accountNameValidator,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _issuerController,
                          decoration: const InputDecoration(
                            labelText: 'Issuer Name',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(),
                            helperText: 'e.g., Google, GitHub, etc.',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _secretKeyController,
                          decoration: InputDecoration(
                            labelText: 'Secret Key',
                            prefixIcon: const Icon(Icons.key),
                            border: const OutlineInputBorder(),
                            helperText: 'Base32 encoded secret key',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.paste),
                              onPressed: () async {
                                // Add clipboard paste functionality
                              },
                              tooltip: 'Paste from clipboard',
                            ),
                          ),
                          validator: totpSecretValidator,
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // SizedBox(
                //   width: double.infinity,
                //   height: 50,
                //   child: ElevatedButton.icon(
                //     onPressed: saveAccount,
                //     icon: const Icon(Icons.save),
                //     label: const Text('Save Account'),
                //     style: ElevatedButton.styleFrom(
                //       foregroundColor: Colors.white,
                //       backgroundColor: Theme.of(context).colorScheme.primary,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //     ),
                //   ),
                // ),
                Button(onPressed: saveAccount, text: 'Save Account'),
                const SizedBox(height: 16),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Important Notes:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('• The secret key is case-insensitive'),
                        Text(
                            '• Spaces in the secret key are automatically removed'),
                        Text('• The secret key must be in Base32 format'),
                        Text(
                            '• Keep your secret key secure and never share it'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
