import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({Key? key}) : super(key: key);

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUpdateDialog();
    });
  }

  Future<void> _launchStore() async {
    // Replace with your app's actual store URLs
    const appStoreUrl = 'https://apps.apple.com/us/app/your-app/id1234567890';
    const playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.your.app';

    final uri = Uri.parse(Theme.of(context).platform == TargetPlatform.iOS
        ? appStoreUrl
        : playStoreUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch store';
    }
  }

  Future<void> _showUpdateDialog() async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: ligtBlackColor, // Dark background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              "Please get the new us.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.02,
                fontFamily: 'Mulish',
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
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
                
              },
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      body: Container(), // Empty container since we only want the dialog
    );
  }
}
