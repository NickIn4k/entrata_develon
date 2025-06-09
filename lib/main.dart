import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'second_page.dart';
import 'hero.dart';
import 'theme/theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const MyHomePage(title: 'Login'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showMenu = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0x80FFFFFF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Benvenuto!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(221, 41, 40, 40),
                    ),
                  ),
                  const Text(
                    "Per ragioni di sicurezza, identificati prima di continuare",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(221, 41, 40, 40),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 250,
                    height: 80,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      icon: Image.asset(
                        'assets/LogoMigliore.png',
                        height: 24,
                      ),
                      label: const Text('Continua con Google'),
                      onPressed: () async {
                        bool successo = await signInWithGoogle();
                        if (successo) {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(builder: (_) => const SecondaPagina()),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HeroDetailPage()),
                );
              },
              child: Hero(
                tag: 'logo-hero',
                child: Container(
                  height: 92,
                  width: 92,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0x80FFFFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/logoDevelon.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.black87, size: 35),
                  onPressed: () {
                    setState(() {
                      showMenu = !showMenu;
                    });
                  },
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: showMenu
                      ? Row(
                          key: const ValueKey('menu'),
                          children: [
                            IconButton(
                              icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode, color: Colors.black, size: 35),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  ///////////////////////////////////////////////////////////////////
                                  SnackBar(content: Text('Modalità modificata')),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.logout, color: Colors.black, size: 35),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                await GoogleSignIn().signOut();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Logout effettuato')),
                                );
                              },
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) return false;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    final User? user = userCredential.user;
    final String? email = user?.email;

    if (email == null || email.isEmpty) {
      //Logout
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Errore: impossibile recuperare l\'email utente.')),
      );
      return false;
    }

    //dominio deve essere "@develon.com"
    if (!email.toLowerCase().endsWith('@gmail.com')) {
      //Logout 
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Accesso consentito solo con email @develon.com'),
          backgroundColor: Colors.redAccent
        ),
      );
      return false;
    }
    return true;
  } catch (e) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text('Errore durante accesso: $e'),
        backgroundColor: Colors.redAccent
      ),
    );
    return false;
  }
}