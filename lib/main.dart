import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// File locali
import 'theme/theme.dart';
import 'theme/provider_theme.dart';
import 'package:provider/provider.dart';
import 'static_gesture.dart';
import 'second_page.dart';
import 'hero.dart';

// Chiave globale per la navigazione: permette di usare il Navigator da qualsiasi punto dell'app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Assicura che i binding di Flutter siano inizializzati prima di chiamare metodi asincroni
  WidgetsFlutterBinding.ensureInitialized();
  // Inizializza Firebase (per l'accesso con google)
  await Firebase.initializeApp();

  // Provider per la gestione del tema
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
    // Controlla se esiste un utente loggato
    User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      // Definizione dei temi con una personalizzazione delle Snackbars
      // Tema chiaro
      theme: lightMode.copyWith(
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating, 
          contentTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Tema scuro
      darkTheme: darkMode.copyWith(
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating, 
          contentTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Sceglie il tema basato sul ValueNotifier gestito da StaticGesture
      themeMode: StaticGesture.getThemeMode(context),

      // redirect diretto a SecondaPagina in caso di utente già loggato
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
  // isOpen: stato del menu ad espansione
  bool isOpen = false;
  // traduzioneOn: stato della traduzione => false = ita / true = eng
  bool traduzioneOn = false;

  // Costruttore
  @override
  void initState() {
    super.initState();
    // Stati dai ValueNotifier<bool>
    isOpen = StaticGesture.menuFlag.value;
    traduzioneOn = StaticGesture.traduzioneOn.value;
    // Listener di aggiornamento
    StaticGesture.menuFlag.addListener(onFlagChanged);
    StaticGesture.traduzioneOn.addListener(onTraduzione);
  }

  // Eventi di callback per il menù e per la traduzione
  void onFlagChanged() {
    setState(() {
      isOpen = StaticGesture.menuFlag.value;
    });
  }

  void onTraduzione(){
    setState(() {
      traduzioneOn = StaticGesture.traduzioneOn.value;
    });
  }

  // Rimozione dei listener dopo il dispose del widget
  @override
  void dispose() {
    StaticGesture.menuFlag.removeListener(onFlagChanged);
    StaticGesture.traduzioneOn.removeListener(onTraduzione);
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // No back button di android
      child: Scaffold(
        body: Stack(
          children: [
            // Builder di ValueNotifier<bool>
            ValueListenableBuilder<bool>(
              valueListenable: StaticGesture.menuFlag,
              builder: (context, value, child) {
                return SizedBox.shrink();
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: StaticGesture.traduzioneOn,
              builder: (context, value, child) {
                return SizedBox.shrink();
              },
            ),
            // Sfondo dinamico basato sul tema
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(StaticGesture.getPath(context, 'assets/background/Background.jpg', 'assets/background/DarkBackground.png')),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Box centrale con testo e pulsante di login
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
                    // Titolo
                    Text(
                      StaticGesture.getTraduzione("Benvenuto!", "Welcome!"),  // Traduzione dinamica => spiegata in StaticGesture
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: StaticGesture.getTextColor(context, Colors.white, Colors.black),
                      ),
                    ),
                    // Sottotitolo
                    Text(
                      StaticGesture.getTraduzione("Per ragioni di sicurezza, identificati per proseguire.","For security reasons, please identify yourself to continue."),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: StaticGesture.getTextColor(context, Colors.white70, Colors.black87),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Pulsante di login => colori con StaticGesture
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
                          'assets/logo/LogoGoogle.png',
                          height: 24,
                        ),
                        label: Text(
                          StaticGesture.getTraduzione('Continua con Google','Continue with Google'),
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () async {
                          // Avvia il processo di login con firebase di Google
                          bool successo = await signInWithGoogle();
                          if (successo) {
                            navigatorKey.currentState?.pushReplacement(
                              MaterialPageRoute(builder: (_) => SecondaPagina()), // Avvia e sostituisci con la seconda pagina
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Logo per l'apertura di un piccolo About
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => HeroDetailPage(pagina: Pagina.prima)),  // Avvia ma NON sostiutisce la pagina corrente
                  );
                },
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
            // Menu impostazioni espandibile
            Positioned(
                top: 45,
                left: 16,
                // Animazione
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
                          // Button di apertura
                          IconButton(
                            icon: Icon(Icons.settings,
                                color: StaticGesture.getTextColor(context, Colors.white, Colors.black87), size: 35),
                            onPressed: () {
                              setState(() {
                                StaticGesture.changeMenuState();
                              });
                            },
                          ),
                          if (isOpen)
                            Row(
                              children: [
                                // Button per il cambio del tema
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
                                // Button per la traduzione
                                IconButton(
                                  icon: Icon(
                                    Icons.translate,
                                    color: StaticGesture.getTextColor(context, Colors.white, Colors.black),
                                    size: 35,
                                  ),
                                  onPressed: () {
                                    StaticGesture.changeLanguage();
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

// Login tramite Google e Firebase, restituzione di una boolean per il successo
Future<bool> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Chiusura pop-up senza aver sselezionato una mail
    if (googleUser == null) return false;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Credenziali per Firebase
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    final User? user = userCredential.user;
    final String? email = user?.email;

    // Controllo email valida
    if (email == null || email.isEmpty) {
      // Logout
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      await StaticGesture.playSound('sounds/error.mp3');
      StaticGesture.showAppSnackBar(navigatorKey.currentContext!, StaticGesture.getTraduzione('Errore: impossibile recuperare l\'email utente.', 'Error: Unable to retrieve user email.'));
      return false;
    }

    // Controllo di dominio => deve essere '@develon.com'
    else if (!email.toLowerCase().endsWith('@gmail.com')) {
      //Logout 
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      await StaticGesture.playSound('sounds/error.mp3');
      StaticGesture.showAppSnackBar(navigatorKey.currentContext!, StaticGesture.getTraduzione('Accesso consentito solo con email @develon.com','Access allowed only with @develon.com email'));
      return false;
    }

    // Login avvenuto con successo: riproduce suono di conferma
    await StaticGesture.playSound('sounds/logout.mp3');
    return true;
  } catch (e) {
    // Gestione di qualsiasi altro errore generico
    await StaticGesture.playSound('sounds/error.mp3');
    StaticGesture.showAppSnackBar(navigatorKey.currentContext!, StaticGesture.getTraduzione('Errore: $e', 'Error: $e'));
    return false;
  }
}