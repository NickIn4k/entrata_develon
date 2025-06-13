import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// File locali
import 'static_gesture.dart';
import 'main.dart';

// Chiave globale per la navigazione: permette di usare il Navigator da qualsiasi punto dell'app
// Per Google
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.title});
  final String title;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // isOpen: stato del menu ad espansione
  bool isOpen = false;
  // traduzioneOn: stato della traduzione => false = ita / true = eng
  bool traduzioneOn = false;

  // Eventi di callback per il menù e per la traduzione
  // Funzione passata come parametro a un'altra funzione e richiamata in un secondo momento
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

  // Rimozione dei listener dopo il dispose del widget
  @override
  void dispose() {
    StaticGesture.menuFlag.removeListener(onFlagChanged);
    StaticGesture.traduzioneOn.removeListener(onTraduzione);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Recupera i dati dell'utente loggato
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              StaticGesture.getPath(
                context,
                'assets/background/Background3.jpeg',
                'assets/background/DarkBackground3.jpeg',
              ),
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Builder per il rebuild con ValueNotifier<bool>
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
            // Sezione centrale con i dati utente
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  // Colore semitrasparente => withAlpha()  {esiste anche withValues()}
                  color: StaticGesture.getContainerColor(context).withAlpha(128),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titolo
                    Text(
                      StaticGesture.getTraduzione('Dati dell\'utente', 'User\'s data'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Riga 1. => nome
                    buildRow(
                      context,
                      StaticGesture.getTraduzione('Nome', 'Name'),
                      user?.displayName?.split(' ').first ?? StaticGesture.getTraduzione('Non disponibile', 'Not found'),
                    ),
                    // Riga 2. => cognome
                    buildRow(
                      context,
                      StaticGesture.getTraduzione('Cognome', 'Surname'),
                      (user?.displayName?.split(' ').length == 2)
                        ? user!.displayName!.split(' ')[1]
                        : StaticGesture.getTraduzione('Non disponibile', 'Not found'),
                    ),
                    // Riga 3. => email
                    buildRow(
                      context,
                      'Email',
                      user?.email ?? StaticGesture.getTraduzione('Non disponibile', 'Not found'),
                    ),
                    // Riga 4. => ultimo accesso
                    buildRow(
                      context,
                      StaticGesture.getTraduzione('Ultimo Accesso', 'Last\naccess'),
                      user?.metadata.lastSignInTime != null
                        ? user!.metadata.lastSignInTime!.toLocal().toString().substring(0,user.metadata.lastSignInTime!.toLocal().toString().length - 7)
                        : StaticGesture.getTraduzione('Non disponibile', 'Not found'),
                    ),
                    const SizedBox(height: 30),
                    // Button per il logout
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.logout, size: 28),
                      label: const Text('Logout'),
                      onPressed: () async {
                        // Logout da Firebase e Google
                        await FirebaseAuth.instance.signOut();
                        await GoogleSignIn().signOut();

                        if (context.mounted){
                          // Notifica audio-video
                          await StaticGesture.playSound('sounds/logout.mp3');
                          StaticGesture.showAppSnackBar(context, StaticGesture.getTraduzione('Logout effettuato', 'Logout completed'));

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const MyHomePage(title: 'login')),  // Avvia e sostituisce la pagina di login
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Menu impostazioni espandibile in alto a sinistra
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
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Button di apertura
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: StaticGesture.getTextColor(context, Colors.white,Colors.black87),
                            size: 35,
                          ),
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
                                  color: StaticGesture.getTextColor(
                                    context,
                                    Colors.white,
                                    Colors.black,
                                  ),
                                  size: 35,
                                ),
                                onPressed: () {
                                  StaticGesture.changeTheme(context);
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
                              // Button per "l'apertura" della finestra entrance
                              IconButton(
                                icon: Icon(
                                  Icons.door_front_door,
                                  color: StaticGesture.getTextColor(context, Colors.white, Colors.black),
                                  size: 35,
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop();
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

  // Costruisce una riga etichetta-valore con scroll orizzontale per il valore
  Widget buildRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      // Background della riga
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: StaticGesture.getContainerColor(context).withAlpha(128),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            // Etichetta in grassetto
            Expanded(
              flex: 2,
              child: Text(
                '$label:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: StaticGesture.getTextColor(
                      context, Colors.white, Colors.black),
                  fontSize: 18,
                ),
              ),
            ),
            // Valore con scroll orizzontale in caso di testo lungo
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  value,
                  style: TextStyle(
                    color: StaticGesture.getTextColor(context, Colors.white, Colors.black),
                    fontSize: 18,
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