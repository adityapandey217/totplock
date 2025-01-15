import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TotpEntry {
  final String totpUri;
  final String secret;
  final String name;
  final String issuer;
  int remainingTime;

  TotpEntry(
      {required this.totpUri,
      required this.secret,
      this.remainingTime = 30,
      this.name = '',
      this.issuer = ''});
}

class TotpProvider extends ChangeNotifier {
  final List<TotpEntry> _totpList = [];
  static const String _prefsKey = 'totpEntries';
  final int interval = 30;

  List<TotpEntry> get totpList => _totpList;

  TotpProvider() {
    _loadTotpEntries();
  }

  Future<void> _loadTotpEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_prefsKey) ?? [];
    _totpList.clear();
    _totpList.addAll(data.map((jsonStr) {
      final json = jsonDecode(jsonStr);
      final Uri uri = Uri.parse(json['totpUri']);

      // Extract issuer and name from the URI
      final parts =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.last.split(':') : [];
      final name = parts.length > 1
          ? Uri.decodeComponent(parts[1])
          : 'Unknown'; // Decode name if encoded
      final issuer = uri.queryParameters['issuer'] ??
          'Unknown'; // Extract issuer from query parameter

      return TotpEntry(
        totpUri: json['totpUri'],
        secret: json['secret'],
        remainingTime: interval,
        name: name,
        issuer: issuer,
      );
    }));
    notifyListeners();
  }

  Future<void> _saveTotpEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _totpList
        .map((entry) => jsonEncode({
              'totpUri': entry.totpUri,
              'secret': entry.secret,
            }))
        .toList();
    await prefs.setStringList(_prefsKey, data);
  }

  void addTotpEntry(String totpUri, String secret) {
    final Uri uri = Uri.parse(totpUri);

    // Extract issuer and name from the URI
    final parts =
        uri.pathSegments.isNotEmpty ? uri.pathSegments.last.split(':') : [];
    final name = parts.length > 1
        ? Uri.decodeComponent(parts[1])
        : 'Unknown'; // Decode name if encoded
    final issuer = uri.queryParameters['issuer'] ??
        'Unknown'; // Extract issuer from query parameter

    _totpList.add(TotpEntry(
      totpUri: totpUri,
      secret: secret,
      issuer: issuer,
      name: name,
      remainingTime: interval,
    ));
    _saveTotpEntries();
    notifyListeners();
  }

  void removeTotpEntry(int index) {
    _totpList.removeAt(index);
    _saveTotpEntries();
    notifyListeners();
  }

  bool checkTotpEntry(String totpUri) {
    return _totpList.any((entry) => entry.totpUri == totpUri);
  }

  void updateRemainingTime() {
    for (final entry in _totpList) {
      entry.remainingTime = interval - DateTime.now().second % interval;
    }
    notifyListeners();
  }
}
