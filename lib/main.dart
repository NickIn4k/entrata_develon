import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'theme/theme.dart';
import 'theme/provider_theme.dart';
import 'package:provider/provider.dart';
import 'static_gesture.dart';
import 'second_page.dart';
import 'hero.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: lightMode.copyWith(
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating, 
          contentTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: darkMode.copyWith(
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating, 
          contentTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      themeMode: StaticGesture.getThemeMode(context),
      home: user != null 
        ? SecondaPagina() 
        : const MyHomePage(title: 'Login'),
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
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    isOpen = StaticGesture.menuFlag.value;
    StaticGesture.menuFlag.addListener(onFlagChanged);
  }

  void onFlagChanged() {
    setState(() {
      isOpen = StaticGesture.menuFlag.value;
    });
  }

  @override
  void dispose() {
    StaticGesture.menuFlag.removeListener(onFlagChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // disattiva il pulsante indietro
      child: Scaffold(
        body: Stack(
          children: [
            ValueListenableBuilder<bool>(
                valueListenable: StaticGesture.menuFlag,
                builder: (context, value, child) {
                  return SizedBox.shrink();
                },
            ),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(StaticGesture.getPath(context, 'assets/background/Background.jpg', 'assets/background/DarkBackground.png')),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: StaticGesture.getContainerColor(context),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Benvenuto!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: StaticGesture.getTextColor(context, Colors.white, Colors.black),
                      ),
                    ),
                    Text(
                      "Per ragioni di sicurezza, identificati per proseguire.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: StaticGesture.getTextColor(context, Colors.white70, Colors.black87),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 250,
                      height: 80,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StaticGesture.getButtonColor(context),
                          foregroundColor: StaticGesture.getTextColor(context, Colors.white, Colors.black87),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: StaticGesture.getBorderColor(context)),
                          ),
                        ),
                        icon: Image.asset(
                          'assets/logo/LogoMigliore.png',
                          height: 24,
                        ),
                        label: Text(
                          'Continua con Google',
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () async {
                          bool successo = await signInWithGoogle();
                          if (successo) {
                            navigatorKey.currentState?.pushReplacement(
                              MaterialPageRoute(builder: (_) => SecondaPagina()),
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
                    MaterialPageRoute(builder: (_) => HeroDetailPage(pagina: Pagina.prima)),
                  );
                },
                child: Hero(
                  tag: 'logo-hero',
                  child: Container(
                    height: 92,
                    width: 92,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: StaticGesture.getTextColor(context, Colors.black54, Colors.white70),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        StaticGesture.getPath(context, 'assets/logo/logoDevelon.png','assets/logo/logoDevelonI.png'),
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
                top: 45,
                left: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: StaticGesture.getContainerColor(context),
                      borderRadius: BorderRadius.circular(isOpen ? 20 : 100),
                    ),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.centerLeft, // fondamentale: si apre da sinistra
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.settings,
                                color: StaticGesture.getTextColor(context, Colors.white, Colors.black87), size: 35),
                            onPressed: () {
                              setState(() {
                                StaticGesture.menuFlag.value = !StaticGesture.menuFlag.value;
                              });
                            },
                          ),
                          if (isOpen)
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    StaticGesture.getIconTheme(context),
                                    color: StaticGesture.getTextColor(context, Colors.white, Colors.black),
                                    size: 35,
                                  ),
                                  onPressed: () {
                                    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
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

      await StaticGesture.playSound('sounds/messaggio_errore.mp3');
      StaticGesture.showAppSnackBar(navigatorKey.currentContext!, 'Errore: impossibile recuperare l\'email utente.');

      return false;
    }

    //dominio deve essere "@develon.com"
    if (!email.toLowerCase().endsWith('@gmail.com')) {
      //Logout 
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      await StaticGesture.playSound('sounds/messaggio_errore.mp3');
      StaticGesture.showAppSnackBar(navigatorKey.currentContext!, 'Accesso consentito solo con email @develon.com');
      return false;
    }
    return true;
  } catch (e) {
    await StaticGesture.playSound('sounds/messaggio_errore.mp3');
    StaticGesture.showAppSnackBar(navigatorKey.currentContext!, 'Errore: $e');
    return false;
  }
}