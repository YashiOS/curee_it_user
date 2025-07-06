import 'package:cureeit_user_app/utils/theme.dart';
import 'package:cureeit_user_app/screens/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({Key? key}) : super(key: key);

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  bool _isCheckingUpdate = true;
  bool _updateAvailable = false;

static const bool DEBUG_MODE = false; 
  static const bool FORCE_SHOW_UPDATE = true;
  static const String MOCK_LATEST_VERSION = "2.0.0";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (DEBUG_MODE) {
        _testUpdateFlow();
      } else {
        _checkForUpdate();
      }
    });
  }

   Future<void> _testUpdateFlow() async {
    await Future.delayed(Duration(seconds: 2));
    
    if (FORCE_SHOW_UPDATE) {
      setState(() {
        _updateAvailable = true;
        _isCheckingUpdate = false;
      });
      _showUpdateDialog();
    } else {
      setState(() {
        _isCheckingUpdate = false;
      });
      _navigateToHome();
      
    }
  }


Future<void> _checkForUpdate() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      if (DEBUG_MODE) {
        currentVersion = "1.0.0";
      }
      
      String? latestVersion;
      if (Platform.isIOS) {
        latestVersion = await _getLatestVersionFromAppStore();
      } else if (Platform.isAndroid) {
        latestVersion = await _getLatestVersionFromPlayStore();
      }

      // In debug mode, use mock version
      if (DEBUG_MODE) {
        latestVersion = MOCK_LATEST_VERSION;
      }

      print('Current Version: $currentVersion');
      print('Latest Version: $latestVersion');

      if (latestVersion != null && _isVersionNewer(latestVersion, currentVersion)) {
        setState(() {
          _updateAvailable = true;
          _isCheckingUpdate = false;
        });
        _showUpdateDialog();
      } else {
        setState(() {
          _isCheckingUpdate = false;
        });
        _navigateToHome();
        
      }
    } catch (e) {
      print('Error checking for update: $e');
      setState(() {
        _isCheckingUpdate = false;
      });
     _navigateToHome();
     
    }
  }
  Future<String?> _getLatestVersionFromAppStore() async {
    try {
      const appId = '6746422404'; 
      final response = await http.get(
        Uri.parse('https://itunes.apple.com/lookup?id=$appId'),
        
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['version'];
        }
      }
    } catch (e) {
      print('Error fetching App Store version: $e');
    }
    return null;
  }

  Future<String?> _getLatestVersionFromPlayStore() async {
    try {
      const packageName = 'com.cureeit.medkaro';
      final response = await http.get(
        Uri.parse('https://play.google.com/store/apps/details?id=$packageName'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        },
      );

      if (response.statusCode == 200) {
        // Parse HTML to extract version
        final html = response.body;
        final versionMatch = RegExp(r'Current Version.*?>([\d.]+)<').firstMatch(html);
        if (versionMatch != null) {
          return versionMatch.group(1);
        }
        
        // Alternative regex patterns for Play Store
        final altVersionMatch = RegExp(r'\[\[\["([\d.]+)"\]\]').firstMatch(html);
        if (altVersionMatch != null) {
          return altVersionMatch.group(1);
        }
      }
    } catch (e) {
      print('Error fetching Play Store version: $e');
    }
    return null;
  }

  bool _isVersionNewer(String latestVersion, String currentVersion) {
    List<int> latest = latestVersion.split('.').map(int.parse).toList();
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    while (latest.length < current.length) latest.add(0);
    while (current.length < latest.length) current.add(0);

    for (int i = 0; i < latest.length; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }
    return false;
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BaseScreen(Navigatedfrom: "from_main"),
      ),
    );
  }

  Future<void> _launchStore() async {
    const appStoreUrl = 'https://apps.apple.com/in/app/medkaro-medicines-in-10-min/id6746422404';
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.cureeit.medkaro';
    
    final uri = Uri.parse(Platform.isIOS ? appStoreUrl : playStoreUrl);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch store';
    }
  }

  void _testVersionComparison() {
    print('=== Version Comparison Tests ===');
    print('1.0.0 vs 1.0.1: ${_isVersionNewer("1.0.1", "1.0.0")}'); // Should be true
    print('1.0.1 vs 1.0.0: ${_isVersionNewer("1.0.0", "1.0.1")}'); // Should be false
    print('1.0.0 vs 1.0.0: ${_isVersionNewer("1.0.0", "1.0.0")}'); // Should be false
    print('2.0.0 vs 1.9.9: ${_isVersionNewer("2.0.0", "1.9.9")}'); // Should be true
    print('1.2.3 vs 1.2.4: ${_isVersionNewer("1.2.4", "1.2.3")}'); // Should be true
  }

Future<void> _showUpdateDialog() async {
    return showDialog(
      barrierDismissible: false,
      context: context,
   
      builder: (context) => Dialog(
        backgroundColor: ligtBlackColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Get the new us!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.02,
                  fontFamily: 'Mulish',
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 
                  Container(
                    width: 130,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: greenColor,
                      ),
                      child: const Text(
                        "Update",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.02,
                          fontFamily: 'Mulish',
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onPressed: () {
                        _launchStore();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      body: Container(),
    );
  }
}