import 'package:azkar/services/service_provider.dart';
import 'package:azkar/views/core_views/layout_organizer.dart';
import 'package:azkar/views/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';

class LandingWidget extends StatefulWidget {
  @override
  _LandingWidgetState createState() => _LandingWidgetState();
}

class _LandingWidgetState extends State<LandingWidget> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isSignedIn =
          await ServiceProvider.secureStorageService.userSignedIn();
      if (mounted) {
        if (isSignedIn) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LayoutOrganizer()),
              (_) => false);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => OnboardingScreen()),
              (_) => false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: FittedBox(
                child: Icon(
              Icons.directions_run,
              color: Colors.green.shade800,
            )),
          )
        ],
      ),
    );
  }
}
