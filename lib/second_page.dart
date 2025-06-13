import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';  // ?

import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:provider/provider.dart';

// File locali
import 'theme/provider_theme.dart';
import 'static_gesture.dart';
import 'hero.dart';
import 'main.dart';
import 'account.dart';

// SecondaPagina è un widget a stato variabile
class SecondaPagina extends StatefulWidget{
  // Costruttore
  // super.key, scorciatoia per passare la key al widget genitore
  // ( la key serve per identificare in modo univoco il widget )
  const SecondaPagina({super.key});

  @override
  // Il metodo restituisce una classe ( _SecondaPagina ) che gestisce lo stato di seconda pagina
  // State<SecondaPagina>, tipo di oggetto che ritorna ( uno stato per SecondaPagina )
  State<SecondaPagina> createState() => _SecondaPaginaState();
}

// _SecondaPaginaState è una classe privata ( _ ), estende la classe State<SecondaPagina> cioè gestisce lo stato della seconda pagina
class _SecondaPaginaState extends State<SecondaPagina> with WidgetsBindingObserver {
  // Distanza massima ( in metri )
  final double max = 10000000;

  // La posizione GPS attuale dell'utente
  Position? currentPosition;
  // La distanza calcolata tra l'utente e la porta
  double? distanceFromDoor = -1;

  // Indica se un operazione in corso
  bool isLoading = false;
  // Se la porta è aperta o chiusa
  bool portaAperta = false;
  bool gpsAttivo = false;
  // Menu a tendina
  bool isOpen = false;
  bool traduzioneOn = false;

  bool isDialogVisible = false;

  bool isReturningFromSettings = false;

  // Latidudine e longitudine della porta
  final double doorLatitude = 45.5149300;
  final double doorLongitude = 11.4880930;

  // Gestore dello stream della posizione GPS (da chiudere nel dispose)
  StreamSubscription<Position>? positionStream;

  // Metodo chiamato alla creazione del widget, quando la schermata viene creata
  // Metodo eseguito una sola volta, quando il widget viene creato per la prima volta
  @override // initState, metodo della superclasse
  void initState() {
    // Chiama il comportamento base della superclasse ( super: superclasse )
    super.initState();
    // Sto registrando questo widget come un osservatore de ciclo di vita dell'app
    WidgetsBinding.instance.addObserver(this);

    isOpen = StaticGesture.menuFlag.value;
    traduzioneOn = StaticGesture.traduzioneOn.value;

    // Listener che permettono di aggiornare l'interfaccia
    StaticGesture.menuFlag.addListener(onFlagChanged);
    StaticGesture.traduzioneOn.addListener(onTraduzione);
    
    // Controlla se il GPS è attivo o disattivato
    ascoltaStatoGps();
    // Inizia ad ascoltare la posizione GPS in tempo reale
    locationUpdates();
  }

  // Metodo chiamato automaticamente quando lo stato del ciclo di vita dell'app cambia
  @override
  // state e il parametro che indica il nuovo stato dell'app
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // Controlla se l'app è tornata dopo essere stata in background
    // E se l'utente è ritornato dalle impostazioni
    if (state == AppLifecycleState.resumed && isReturningFromSettings) {
      // Resetta la flag, l'app è tornata
      isReturningFromSettings = false;
      // Controlla se il gps è attivo ...
      bool gpsEnabled = await Geolocator.isLocationServiceEnabled();
      // Aggiorna lo stato interno del widget
      // Notifica l'aggiornamento della UI
      setState(() => gpsAttivo = gpsEnabled);

      // mounted, se il widget e ancora montato ( visisbile )
      if (!gpsEnabled && !isDialogVisible && mounted) {
        mostraDialogErroreGPSAD(StaticGesture.getTraduzione('Attiva la geolocalizzazione per usare l\'app.', 'Enable geolocation to use the app.'));
      }
      // Se invece il GPS è attivo, chiama la funzione locationUpdates() per riprendere e ricevere aggiornamenti di posizione
      else if(gpsEnabled){
        locationUpdates();
      }
    }
  }

  // Listener collegati ad oggetti ValueNotifier
  // Chiamata ogni volta che il valore StaticGesture.menuFlag cambia il valore
  void onFlagChanged() {
    setState(() {
      isOpen = StaticGesture.menuFlag.value;
    });
  }

  // Chiamata ogni volta che il valore StaticGesture.traduzioneOn cambia il valore
  void onTraduzione() {
    setState(() {
      traduzioneOn = StaticGesture.traduzioneOn.value;
    });
  }

  // Metodo dispose, per pulire le risorse qunado il widget Stateful viene rimosso ( distrutto )
  // Verrà chiamato automaticamente quando il widget viene rimosso
  @override
  void dispose() {
    // Cancello un stream
    positionStream?.cancel();
    // Rimuovere il widget come osservatore del ciclo di vita dell'app
    WidgetsBinding.instance.removeObserver(this);
    // Rimuovi i listener dai ValueNotifier
    StaticGesture.menuFlag.removeListener(onFlagChanged);
    StaticGesture.traduzioneOn.removeListener(onTraduzione);
    // Chiama il metodo dispose() della superclasse ( super ) per completare la distruzione
    super.dispose();
  }

  // Metodo per mostrare un dialogo di errore all’utente quando la geolocalizzazione (GPS) è spenta
  // Mostra una finestra modale con un messaggio passato come parametro
  Future<void> mostraDialogErroreGPSAD(String messaggio) async {
    // Evita che il dialogo venga mostrato contemporaneamentre
    if (isDialogVisible) return;
    isDialogVisible = true;

    await StaticGesture.playSound('sounds/error.mp3');
    
    // Flutter costruisce un nuovo widget sopra l'interfaccia utente
    // Blocca l'interazione con la UI, finche l'utente non chiude il dialogo 
    await showDialog(
      // context serve a Flutter per sapere dove mostrare il dialogo ( in quale parte dell'app, nella gerarchia dei widget )
      context: context,
      // Per evitare che l'utente possa uscire accidentalmente, non può toccare fuori dal dialogo
      barrierDismissible: false,
      // builder: Funzione che costruisce il contenuto del dialogo
      // Parametro obbligatorio di showDialog
      // Flutter richiama questa funzione quando ha bisogno di costruire ( o ricostruire ) il dialogo
      // Vuole come parametro un buildContext
      // Restituisce un AlertDialog
      builder: (_) => AlertDialog(
        title: Text(StaticGesture.getTraduzione('Errore GPS', 'GPS Error')),
        content: Text(messaggio),
        // actions è una lista di pulsanti in basso nel popup
        actions: [
          // Pulsante ATTIVA
          TextButton(
            child: Text(StaticGesture.getTraduzione('Attiva', 'Activate')),
            onPressed: () async {
              // Chiude il dialogo
              Navigator.of(context).pop();
              isDialogVisible = false;

              // Per sapere se l'utenre e andato nella impostazioni
              isReturningFromSettings = true;
              
              // Apre le impostazioni di sistema per attivare la geolocalizzazione
              // Libreria, app_settings
              await AppSettings.openAppSettings(type: AppSettingsType.location);
            },
          ),
          // Pulsante NEGA
          TextButton(
            child: Text(StaticGesture.getTraduzione("Nega", "Deny")),
            onPressed: () {
              // Chiude il dialogo
              Navigator.of(context).pop();
              isDialogVisible = false;
              // Chiude l'app
              SystemNavigator.pop();        
            },
          ),
        ],
      ),
    );
    
    isDialogVisible = false;
  }

  // Metodo per mostrare il messaggio di errore, per il GPS ( per i permessi )
  Future<void> mostraDialogErrore(String messaggio) async {
    // Serve per impedire che più dialoghi vengano mostrati contemporaneamente
    if (isDialogVisible) return;
    isDialogVisible = true;

    await StaticGesture.playSound('sounds/error.mp3');

    // Funzione per mostrare un dialogo modale
    // Flutter costruisce un nuovo widget sopra l'interfaccia utente
    // Blocca l'interazione con la UI, finche l'utente non chiude il dialogo
    await showDialog(
      // context serve a Flutter per sapere dove mostrare il dialogo ( in quale parte dell'app )
      context: context,
      // builder: Funzione che costruisce il contenuto del dialogo
      builder: (_) => AlertDialog(
        title: Text(StaticGesture.getTraduzione('Permessi GPS negati', 'GPS Permissions Denied')),
        content: Text(messaggio),
        // actions è una lista di pulsanti in basso nel popup
        actions: [
          // Pulsante OK, pulsante di chiusura
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              // Chiude il dialogo
              Navigator.of(context).pop();
              isDialogVisible = false;
              // Chiude l'app
              SystemNavigator.pop();
            }
          ),
        ],
      ),
    );

    isDialogVisible = false;
  }

  // Metodo che ascolta lo stato del GPS ( attivato/disattivato )
  // Metodo che imposta un listener sullo stato del GPS
  void ascoltaStatoGps() {
    // Quando lo stato del servizio GPS cambia aggiorna la variabile gpsAttivo
    // GPS attivo: ServiceStatus.enabled
    // GPS disattivato: ServiceStatus.disabled

    // Monitoraggio dell stato del GPS
    // Restituisce uno stream che notifica ogni volta che lo stato del GPS cambia
    Geolocator.getServiceStatusStream().listen((ServiceStatus status) async {
      // Notifica Flutter che il widget deve essere aggiornato
      // Richiama il metodo build() del widget
      // Aggiornamento della variabile gpsAttivo in base allo stato ricevuto
      // setState per forzare il rebuild del widget
      setState(() {
        gpsAttivo = status == ServiceStatus.enabled;
      });

      // Se il gps è disattivato dopo 300 millisecondi, viene fatto un controllo agguintivo
      if (!gpsAttivo) {
        Future.delayed(Duration(milliseconds: 300), () async {
          bool check = await Geolocator.isLocationServiceEnabled();
          if (!check) {
            await mostraDialogErroreGPSAD(StaticGesture.getTraduzione('Attiva la geolocalizzazione per usare l\'app.', 'Enable geolocation to use the app.'));
          }
        });
      }
    });

    // Controllo iniziale, all'avvio ( viene quindi eseguita una sola volta )
    // Chiama il metodo asincrono Geolocator.isLocationServiceEnabled(), che restituisce un Future<bool>
    // Quando la risposta è pronta ( then )
    Geolocator.isLocationServiceEnabled().then((enabled) {
      // Notifica Flutter che il widget deve essere aggiornato
      // Richiama il metodo build() del widget
      setState(() {
        gpsAttivo = enabled;
      });

      if (!gpsAttivo) {
        Future.delayed(Duration(milliseconds: 300), () async {
          bool check = await Geolocator.isLocationServiceEnabled();
          if (!check) {
            await mostraDialogErroreGPSAD(StaticGesture.getTraduzione('Attiva la geolocalizzazione per usare l\'app.', 'Enable geolocation to use the app.'));
          }
        });
      }
    });
  }

  // Metodo asincrono che gestisce gli aggiornamenti della posizione GPS
  Future<void> locationUpdates() async {

    // Controlla se il GPS è attivo
    bool gpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!gpsEnabled) {
      // Mostra il tuo dialogo personalizzato
      await mostraDialogErroreGPSAD(StaticGesture.getTraduzione('Attiva la geolocalizzazione per usare l\'app.', 'Enable geolocation to use the app.'));
      return;
    }

    // PERMESSI
    // Controlla i permessi dell'app necessari per accedere alla posizione
    LocationPermission permesso = await Geolocator.checkPermission();
    // Verifica che i permessi di localizzazione sono stati concessi
    if (permesso == LocationPermission.denied) {
      // Se i permessi sono negati allora chiede di nuovo il permesso ( requestPermission )
      permesso = await Geolocator.requestPermission();
      // Se il permesso viene ancora negato
      if (permesso == LocationPermission.denied) {
        await mostraDialogErrore(StaticGesture.getTraduzione('Permessi di geolocalizzazione negati.', 'Location permissions denied.'));
        // Chiudo l'applicazione
        SystemNavigator.pop();

        return;
      }
    }

    // Se il permesso viene negato permanentemente
    if (permesso == LocationPermission.deniedForever) {
      await mostraDialogErrore(StaticGesture.getTraduzione('Permessi di geolocalizzazione negati in modo permanente.', 'Location permissions permanently denied.'));
      // Chiudo l'applicazione
      SystemNavigator.pop();

      return;
    }

    // Usa l'ultima posizione memorizzata dal sistema ( se c'è )
    // Non attiva il GPS
    Position? lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      // Aggiorna lo stato
      setState(() {
        // Aggiorna la variabile currentPosition
        currentPosition = lastKnown;
        // Calcola la distanza
        distanceFromDoor = Geolocator.distanceBetween(
          lastKnown.latitude,
          lastKnown.longitude,
          doorLatitude,
          doorLongitude,
        );
      });
    }

    // Ascolta la posizione in tempo reale
    // getPositionStream, riceve aggiornamenti continui della posizione
    // Metodo che restituisce un stream continuo di posizioni
    // Ogni colta che il GPS rileva un cambiamento fornisce un nuovo oggetto Position
    positionStream = Geolocator.getPositionStream(
      // Parametri di configurazione dello stream
      locationSettings: const LocationSettings(
        // Massima Precisione disponibile
        accuracy: LocationAccuracy.bestForNavigation,
        // L'evento si attiva ogni volta che ti sposti di almeno un metro
        distanceFilter: 1,
      ),
    // Ricezione posizione, permette di ascoltare i dati dello stream
    // Ogni volta che riceve un aggiornamento, ricalcola la posizione
    ).listen((Position position) {
      // Calcolo della distanza
      double distanza = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        doorLatitude,
        doorLongitude,
      );
      // Aggiornamento dello stato, notifica di aggiornare della UI
      setState(() {
        currentPosition = position;
        distanceFromDoor = distanza;
      });
    });
  }

  // QUI CI SARA' LA CHIAMATA API
  Future<void> apriPorta() async {
    // Avvio caricamento
    // Aggiornamento UI
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isLoading = false;
      portaAperta = true;
    });

    await StaticGesture.playSound('sounds/door_opened.mp3');
    // Mostra una SnackBar ( notifica )
    if (context.mounted){
      // Messaggio temporaneo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            StaticGesture.getTraduzione('Porta Aperta', 'Door Opened'),
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }

    return;
  }

  // QUI CI SARA' LA CHIAMATA API
  Future<void> chiudiPorta() async{
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
      portaAperta = false;
    });

    await StaticGesture.playSound('sounds/door_closed.mp3');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            StaticGesture.getTraduzione('Porta Chiusa', 'Closed Door'),
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3)
        ),
      );
    }
    
    return;
  }

  @override
  Widget build(BuildContext context) {
    bool isWithinRange = (distanceFromDoor ?? -1) >= 0 && (distanceFromDoor ?? -1) <= max;
    
    return PopScope(
      canPop: false,  // Blocco back button di Android
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
            // Background
            Positioned.fill(
              child: Image.asset(
                StaticGesture.getPath(context, 'assets/background/Background2.jpg', 'assets/background/DarkBackground2.png'),
                fit: BoxFit.cover,
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      // Per prendere la posizione esatta dello slider
                      child: AbsorbPointer(
                        absorbing: isLoading || currentPosition == null || !isWithinRange || !gpsAttivo,
                        child: Opacity(
                          opacity: (isLoading || currentPosition == null || !isWithinRange || !gpsAttivo) ? 0.5 : 1.0,
                          // Slider input animato
                          child: SlideAction(
                            borderRadius: 50,
                            elevation: 4,
                            innerColor: portaAperta 
                              ? StaticGesture.getIconColor(context, Colors.red, const Color.fromARGB(255, 150, 11, 1))
                              : StaticGesture.getIconColor(context, Colors.lightBlue, const Color.fromARGB(255, 9, 103, 226)),
                            outerColor: StaticGesture.getContainerColor(context),
                            sliderButtonIcon: Transform(
                              alignment: Alignment.center,
                              transform: portaAperta
                                ? Matrix4.rotationY(3.14159)
                                : Matrix4.identity(),
                              child: Icon(portaAperta? Icons.lock : Icons.lock_open, color: Colors.white),
                            ),
                            alignment: portaAperta ? Alignment.center : Alignment.center,
                            text: portaAperta ? StaticGesture.getTraduzione('Scorri per chiudere', 'Slide to close') : StaticGesture.getTraduzione('Scorri per aprire', 'Slide to open'),
                            textStyle: TextStyle(
                              color: StaticGesture.getTextColor(context, Colors.white, Colors.black), 
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                            ),
                            onSubmit: () {
                              if (portaAperta) {
                                chiudiPorta();
                              } else {
                                apriPorta();
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Slider (back) per la SlideBar
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
                        // Button di apertura
                        IconButton(
                          icon: Icon(Icons.settings, color: StaticGesture.getTextColor(context, Colors.white, Colors.black87), size: 35),
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
                              // Button per l'apertura della finestra utente
                              IconButton(
                                icon: Icon(Icons.person, color: StaticGesture.getTextColor(context, Colors.white, Colors.black), size: 35),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => AccountPage(title: "Account Page")),
                                  );
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
                              // Button per l'apertura di maps
                              IconButton(
                                icon: Icon(Icons.location_on, color: StaticGesture.getTextColor(context, Colors.white, Colors.black), size: 35),
                                onPressed: () async {
                                  final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$doorLatitude,$doorLongitude');
                                  if (!await launchUrl(url)) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                              ),
                              // Button per il logout
                              IconButton(
                                icon: Icon(Icons.logout, color: StaticGesture.getTextColor(context, Colors.white, Colors.black), size: 35),
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  await GoogleSignIn().signOut();

                                  if (context.mounted){
                                    await StaticGesture.playSound('sounds/logout.mp3');
                                    StaticGesture.showAppSnackBar(context, StaticGesture.getTraduzione('Logout effettuato', 'Logout completed'));

                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => MyHomePage(title: 'login')),
                                    );
                                  }
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
            // Logo per l'apertura di un about
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => HeroDetailPage(pagina: Pagina.seconda)),
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
            // Sottotitolo in basso
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  StaticGesture.getTraduzione("Entrata", 'Entrance'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: StaticGesture.getTextColor( context, Colors.white, Colors.black87),
                  ),
                ),
              ),
            ),
            // Box che indica la distanza (in caso fosse troppa)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: (gpsAttivo && distanceFromDoor != null && distanceFromDoor! > max) ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !(gpsAttivo && distanceFromDoor != null && distanceFromDoor! > max),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            StaticGesture.getTraduzione('Sei troppo lontano! (${distanceFromDoor!.toStringAsFixed(1)} m)', 'You\'re too far away! (${distanceFromDoor!.toStringAsFixed(1)} m)'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
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