import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';  // ?

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:provider/provider.dart';

// FILE LOCALI
import 'theme/provider_theme.dart';
import 'static_gesture.dart';
import 'hero.dart';
import 'main.dart';
import 'account.dart';

// SecondaPagina è un widget a stato variabile
class SecondaPagina extends StatefulWidget {
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
class _SecondaPaginaState extends State<SecondaPagina> {
  // Distanza massima ( in metri )
  final double max = 1000000;

  // Contiene la posizione GPS attuale dell'utente
  Position? currentPosition;
  // Contiene la distanza calcolata tra l'utente e la porta
  double? distanceFromDoor;

  // Indica se un operazione in corso
  bool isLoading = false;
  // Se la porta è aperta o chiusa
  bool portaAperta = false;
  bool gpsAttivo = true;
  // Menu a tendina
  bool isOpen = false;

  // Latidudine e longitudine della porta
  final double doorLatitude = 45.5149300;
  final double doorLongitude = 11.4880930;

  // Gestore dello stream della posizione GPS (da chiudere nel dispose)
  StreamSubscription<Position>? positionStream;

  // Metodo chiamato alla creazione del widget, quando la schermata viene creata
  @override
  void initState() {
    // Chiama il comportamento base della superclasse ( super: superclasse )
    super.initState();

    isOpen = StaticGesture.menuFlag.value;

    StaticGesture.menuFlag.addListener(onFlagChanged);
    
    // Controlla se il GPS è attivo o disattivato
    ascoltaStatoGps();
    // Inizia ad ascoltare la posizione GPS in tempo reale
    locationUpdates();
    
  }

  void onFlagChanged() {
    setState(() {
      isOpen = StaticGesture.menuFlag.value;
    });
  }

  // ?
  @override
  void dispose() {
    positionStream?.cancel();
    StaticGesture.menuFlag.removeListener(onFlagChanged);
    super.dispose();
  }

  // Metodo per mostrare il messaggio di errore, per il GPS ( se è attivo o disattivata la geolocalizzazione )
  Future<void> mostraDialogErroreGPSAD(String messaggio) async {
    // Funzione per mostrare un dialogo modale
    // Flutter costruisce un nuovo widget sopra l'interfaccia utente
    // Blocca l'interazione con la UI, finche l'utente non chiude il dialogo 
    await showDialog(
      // context serve a Flutter per sapere dove mostrare il dialogo ( in quale parte dell'app )
      context: context,
      // builder: Funzione che costruisce il contenuto del dialogo
      builder: (_) => AlertDialog(
        title: const Text('Errore GPS'),
        content: Text(messaggio),
        // actions è una lista di pulsanti in basso nel popup
        actions: [
          TextButton(
            child: const Text('Attiva'),
            onPressed: () {
              // Per aprire la pagina di impostazioni GPS del dispositivo
              AppSettings.openAppSettings(type: AppSettingsType.location);
              // Chiudo il dialogo
              Navigator.of(context).pop();


              // Aspetto 2 secondi e poi ricontrollo se il GPS è attivo
              // Se NON è stata riattivata la geolocalizzazione il popup di errore viene mostrato di nuovo
              Future.delayed(const Duration(seconds: 2), 
              // Funzione asincrona che verrà eseguita dopo 2 secondi
              () async {
                bool gps = await Geolocator.isLocationServiceEnabled();
                if (!gps) {
                  // Mostra di nuovo il popup se GPS è ancora spento
                  mostraDialogErroreGPSAD('Attiva la geolocalizzazione per usare l\'app.');
                }
                // Aggiorna lo stato dell'app
                setState(() {
                  gpsAttivo = gps;
                });
              });
            },
          ),
          TextButton(
            child: const Text("Nega"),
            onPressed: () {
              // Chiude il dialogo
              Navigator.of(context).pop(); 
              // Chiude l'app
              SystemNavigator.pop();        
            },
          ),
        ],
      ),
    );
  }

  // Metodo per mostrare il messaggio di errore, per il GPS ( per i permessi )
  Future<void> mostraDialogErrore(String messaggio) async {
    // Funzione per mostrare un dialogo modale
    // Flutter costruisce un nuovo widget sopra l'interfaccia utente
    // Blocca l'interazione con la UI, finche l'utente non chiude il dialogo 
    await showDialog(
      // context serve a Flutter per sapere dove mostrare il dialogo ( in quale parte dell'app )
      context: context,
      // builder: Funzione che costruisce il contenuto del dialogo
      builder: (_) => AlertDialog(
        title: const Text('Permessi GPS negati'),
        content: Text(messaggio),
        // actions è una lista di pulsanti in basso nel popup
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              // Chiudo il dialogo
              Navigator.of(context).pop();
              // Chiudo l'app
              SystemNavigator.pop();
            }
          ),
        ],
      ),
    );
  }


  // Metodo che ascolta lo stato del GPS ( attivato/disattivato )
  void ascoltaStatoGps() {
    // Quando lo stato del servizio GPS cambia aggiorna la variabile gpsAttivo
    // GPS attivo: ServiceStatus.enabled
    // GPS disattivato: ServiceStatus.disabled

    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      // Notifica Flutter che il widget deve essere aggiornato
      // Richiama il metodo build() del widget
      setState(() {
        gpsAttivo = status == ServiceStatus.enabled;
      });

      if(!gpsAttivo){
         mostraDialogErroreGPSAD('Attiva la geolocalizzazione per usare l\'app.');
      }
    });

    // Controllo iniziale, all'avvio ( viene quindi eseguita una sola volta )
    Geolocator.isLocationServiceEnabled().then((enabled) {
      // Notifica Flutter che il widget deve essere aggiornato
      // Richiama il metodo build() del widget
      setState(() {
        gpsAttivo = enabled;
      });

      if(!gpsAttivo){
         mostraDialogErroreGPSAD('Attiva la geolocalizzazione per usare l\'app.');
      }
    });
  }

  // Metodo asincrono che gestisce gli aggiornamenti della posizione GPS
  Future<void> locationUpdates() async {

    // PERMESSI
    // Controlla i permessi dell'app per accedere alla posizione
    LocationPermission permesso = await Geolocator.checkPermission();
    // Verifica che i permessi di localizzazione sono stati concessi
    if (permesso == LocationPermission.denied) {
      // Se i permessi sono negati allora chiede di nuovo il permesso ( requestPermission )
      permesso = await Geolocator.requestPermission();
      // Se il permesso viene ancora negato
      if (permesso == LocationPermission.denied) {
        mostraDialogErrore('Permessi di geolocalizzazione negati.');
        // Chiudo l'applicazione
        SystemNavigator.pop();

        return;
      }
    }

    // Se il permesso viene negato permanentemente
    if (permesso == LocationPermission.deniedForever) {
      mostraDialogErrore('Permessi di geolocalizzazione negati in modo permanente.');
      // Chiudo l'applicazione
      SystemNavigator.pop();

      return;
    }


    // Usa l'ultima posizione nota (se c'è)
    Position? lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      // Aggiorna lo stato
      setState(() {
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
        // Massima Precisione
        accuracy: LocationAccuracy.bestForNavigation,
        // L'evento si attiva ogni volta che ti sposti di almeno un metro
        distanceFilter: 1,
      ),
    // Ricezione posizione, permette di ascoltare i dati dello stream
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

  Future<void> apriPorta() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isLoading = false;
      portaAperta = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Porta Aperta', 
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }

  Future<void> chiudiPorta() async{
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isLoading = false;
      portaAperta = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Porta Chiusa',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3)
      ),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    bool isWithinRange = distanceFromDoor != null &&
        distanceFromDoor! >= 0 &&
        distanceFromDoor! <= max;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: StaticGesture.menuFlag,
              builder: (context, value, child) {
                return SizedBox.shrink();
              },
            ),
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
                    // child: isLoading || currentPosition == null
                        // ? const CircularProgressIndicator()
                        // : Padding(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            // child: AbsorbPointer(
                            //   absorbing: !isWithinRange || !gpsAttivo,
                            //   child: Opacity(
                            //    opacity: (!isWithinRange || !gpsAttivo) ? 0.5 : 1.0,
                            child: AbsorbPointer(
                                absorbing: isLoading || currentPosition == null || !isWithinRange || !gpsAttivo,
                                child: Opacity(
                                opacity: (isLoading || currentPosition == null || !isWithinRange || !gpsAttivo) ? 0.5 : 1.0,
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
                                  text: portaAperta ? 'Scorri per chiudere' : 'Scorri per aprire',
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
                                  },
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                if (gpsAttivo && distanceFromDoor != null && distanceFromDoor! > max)
                  Container(
                    color: Colors.redAccent,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    width: double.infinity,
                    child: Text(
                      'Devi avvicinarti al punto! (${distanceFromDoor!.toStringAsFixed(2)} m)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
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
                              IconButton(
                                icon: Icon(Icons.logout,
                                    color: StaticGesture.getTextColor(context, Colors.white, Colors.black),
                                    size: 35),
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  await GoogleSignIn().signOut();

                                  if (!mounted) return;
                                  StaticGesture.showAppSnackBar(context, 'Logout effettuato');

                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (_) => MyHomePage(title: 'login')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.person, color: StaticGesture.getTextColor(context, Colors.white, Colors.black), size: 35),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => AccountPage(title: "Account Page")),
                                  );
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
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => HeroDetailPage(pagina: Pagina.seconda)),
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
              bottom: 25,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Entrata",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: StaticGesture.getTextColor( context, Colors.white, Colors.black87),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}