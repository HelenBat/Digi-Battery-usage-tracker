import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PermissionCheckScreen extends StatefulWidget {
  const PermissionCheckScreen({Key? key}) : super(key: key);

  @override
  State<PermissionCheckScreen> createState() => _PermissionCheckScreenState();
}

class _PermissionCheckScreenState extends State<PermissionCheckScreen>
    with WidgetsBindingObserver {
  static const MethodChannel _channel =
      MethodChannel('social_media_carbon_footprint/usage');

  bool _hasUsagePermission = false;
  bool _checkedOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndPrompt();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called whenever the app resumes from background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // Re-check usage permission when returning from Settings
      _checkPermissionAndPrompt();
    }
  }

  Future<void> _checkPermissionAndPrompt() async {
    bool hasPerm = await _hasUsagePermissionNative();

    setState(() {
      _hasUsagePermission = hasPerm;
      _checkedOnce = true;
    });

    // If still missing permission, show the dialog every time
    if (!hasPerm) {
      _showUsageAccessDialog();
    }
  }

  Future<bool> _hasUsagePermissionNative() async {
    try {
      final bool result = await _channel.invokeMethod('hasUsagePermission');
      return result;
    } catch (e) {
      debugPrint("Error checking usage permission: $e");
      return false;
    }
  }

  void _showUsageAccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Usage Access Required'),
          content: const Text(
            'This app needs Usage Access to track your social media usage '
            'and calculate your digital carbon footprint. Please grant '
            'Usage Access in the next screen.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _openUsageSettings();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openUsageSettings() async {
    try {
      await _channel.invokeMethod('openUsageSettings');
    } catch (e) {
      debugPrint("Error opening usage settings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we have permission and have checked at least once, go to /home
    if (_checkedOnce && _hasUsagePermission) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checking Permissions...'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
