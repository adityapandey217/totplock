import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:totplock/screens/qr_code_scanner_screen.dart';
import 'package:totplock/screens/setup_key_screen.dart';
import 'package:totplock/screens/totp_list_item.dart';
import 'package:totplock/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totplock/providers/totp_provider.dart';
import 'package:otp/otp.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class TotpListScreen extends StatefulWidget {
  const TotpListScreen({super.key});

  @override
  State<TotpListScreen> createState() => _TotpListScreenState();
}

class _TotpListScreenState extends State<TotpListScreen> {
  Timer? _timer;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      Provider.of<TotpProvider>(context, listen: false).updateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  final _key = GlobalKey<ExpandableFabState>();

  void _onScroll(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.forward) {
        setState(() {
          _isFabVisible = true;
        });
      } else if (notification.direction == ScrollDirection.reverse) {
        setState(() {
          _isFabVisible = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).brightness;
    bool isDark = theme == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Image(
              image: AssetImage('assets/logo.png'),
              width: 60,
              height: 60,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text('Totp Lock'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              AppTheme().toggleTheme(context);
            },
          ),
        ],
        elevation: 0,
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: AnimatedOpacity(
        opacity: _isFabVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: ExpandableFab(
          distance: 100.0,
          key: _key,
          type: ExpandableFabType.fan,
          pos: ExpandableFabPos.center,
          fanAngle: 80,
          overlayStyle: ExpandableFabOverlayStyle(
            color: Colors.black.withOpacity(0.5),
          ),
          openButtonBuilder: RotateFloatingActionButtonBuilder(
            child: const Icon(Icons.manage_accounts),
            fabSize: ExpandableFabSize.regular,
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigoAccent,
            shape: const CircleBorder(),
          ),
          closeButtonBuilder: DefaultFloatingActionButtonBuilder(
            child: const Icon(Icons.close),
            fabSize: ExpandableFabSize.regular,
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigoAccent,
            shape: const CircleBorder(),
          ),
          children: [
            FloatingActionButton(
              heroTag: 'qr_code_scanner',
              onPressed: () {
                final state = _key.currentState;
                if (state != null) {
                  state.toggle();
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QrCodeScannerScreen(),
                  ),
                );
              },
              foregroundColor: Colors.white,
              backgroundColor: Colors.indigoAccent.withOpacity(0.9),
              child: const Icon(Icons.qr_code_scanner),
            ),
            FloatingActionButton(
              heroTag: 'setup_key',
              onPressed: () {
                final state = _key.currentState;
                if (state != null) {
                  state.toggle();
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SetupKeyScreen()),
                );
              },
              foregroundColor: Colors.white,
              backgroundColor: Colors.indigoAccent.withOpacity(0.9),
              child: const Icon(Icons.keyboard),
            ),
          ],
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          _onScroll(scrollNotification);
          return true;
        },
        child: Consumer<TotpProvider>(
          builder: (context, provider, child) {
            if (provider.totpList.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner),
                    SizedBox(height: 10),
                    Text('No Accounts added yet'),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: provider.totpList.length,
              itemBuilder: (context, index) {
                final entry = provider.totpList[index];
                try {
                  final currentCode = OTP.generateTOTPCodeString(
                    entry.secret,
                    DateTime.now().millisecondsSinceEpoch,
                    interval: provider.interval,
                    algorithm: Algorithm.SHA1,
                    isGoogle: true,
                  );
                  return TotpListItem(
                    currentCode: currentCode,
                    entry: entry,
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Account'),
                            content: const Text(
                                'Are you sure you want to remove this account?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel',
                                    style: TextStyle(color: Colors.grey[500])),
                              ),
                              TextButton(
                                onPressed: () {
                                  provider.removeTotpEntry(index);
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                } catch (e) {
                  provider.removeTotpEntry(index);
                  return const SizedBox.shrink();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
