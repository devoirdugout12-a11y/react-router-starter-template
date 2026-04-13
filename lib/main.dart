import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'utils/constants.dart';
import 'screens/home_screen.dart';
import 'screens/partner_dashboard.dart';
import 'screens/event_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Seed données de démo
  final svc = FirebaseService();
  await svc.seedPartners();
  await svc.seedDemoEvent();

  runApp(const BakatiketApp());
}

class BakatiketApp extends StatelessWidget {
  const BakatiketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bakatiket - Billetterie Congo 🇨🇬',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: kPrimary,
          secondary: kSecondary,
          surface: kDarkSurface,
        ),
        scaffoldBackgroundColor: kDark,
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ).apply(bodyColor: kTextPrimary, displayColor: kTextPrimary),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';

        // Route /event/:id
        if (name.startsWith('/event/')) {
          final eventId = name.replaceFirst('/event/', '');
          return MaterialPageRoute(
            builder: (_) => EventDetailScreen(eventId: eventId),
            settings: settings,
          );
        }

        switch (name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/partner-dashboard':
            return MaterialPageRoute(builder: (_) => const PartnerDashboard());
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
