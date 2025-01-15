import 'package:totplock/utils/totp_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TotpListItem extends StatelessWidget {
  final String currentCode;
  final TotpEntry entry;
  final VoidCallback onDelete;

  const TotpListItem({
    super.key,
    required this.currentCode,
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Copy the code to clipboard
        Clipboard.setData(ClipboardData(text: currentCode)).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Code copied to clipboard")),
          );
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Timer with Remaining Time Indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: entry.remainingTime / 30, // Adjust based on interval
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primaryFixedDim,
                    ),
                    backgroundColor: Colors.grey[300],

                    strokeWidth: 6,
                  ),
                ),
                Text(
                  '${entry.remainingTime}s',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            // Code and Expiration Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentCode,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${entry.name}  (${entry.issuer})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Delete Button with Icon and Tooltip
            Tooltip(
              message: "Delete Code",
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.redAccent,
                  iconSize: 24,
                  onPressed: onDelete,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
