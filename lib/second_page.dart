import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:provider/provider.dart';
import 'theme/provider_theme.dart';
import 'static_gesture.dart';
import 'hero.dart';
import 'main.dart';

class SecondaPagina extends StatefulWidget {
  const SecondaPagina({super.key});

  @override
  State<SecondaPagina> createState() => _SecondaPaginaState();
}

class _SecondaPaginaState extends State<SecondaPagina> {
  final double max = 100;

  Position? currentPosition;
  double? distanceFromDoor;
  bool isLoading = false;
  bool portaAperta = false;
  bool gpsAttivo = true;

  final double doorLatitude = 45.5149300;
  final double doorLongitude = 11.4880930;

  @override
  void initState() {
    super.initState();
    ascoltaStatoGps();
    locationUpdates();
  }

  void ascoltaStatoGps() {
    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      setState(() {
        gpsAttivo = status == ServiceStatus.enabled;
      });
    });

    Geolocator.isLocationServiceEnabled().then((enabled) {
      setState(() {
        gpsAttivo = enabled;
      });
    });
  }

  Future<void> mostraDialogErrore(String messaggio) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Errore GPS'),
        content: Text(messaggio),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  Future<void> locationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => gpsAttivo = false);
      mostraDialogErrore('Attiva la geolocalizzazione per usare l\'app.');
      return;
    }

    LocationPermission permesso = await Geolocator.checkPermission();
    if (permesso == LocationPermission.denied) {
      permesso = await Geolocator.requestPermission();
      if (permesso == LocationPermission.denied) {
        mostraDialogErrore('Permessi di geolocalizzazione negati.');
        return;
      }
    }

    if (permesso == LocationPermission.deniedForever) {
      mostraDialogErrore('Permessi di geolocalizzazione negati in modo permanente.');
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      double distanza = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        doorLatitude,
        doorLongitude,
      );

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
        content: Text('Porta Aperta'),
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
        content: Text('Porta Chiusa'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    bool isWithinRange = distanceFromDoor != null &&
        distanceFromDoor! >= 0 &&
        distanceFromDoor! <= max;

    return Scaffold(
      body: Stack(
        children: [
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
                  child: isLoading || currentPosition == null
                      ? const CircularProgressIndicator()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: AbsorbPointer(
                            absorbing: !isWithinRange || !gpsAttivo,
                            child: Opacity(
                              opacity: (!isWithinRange || !gpsAttivo) ? 0.5 : 1.0,
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
              if (!gpsAttivo)
                Container(
                  color: Colors.redAccent,
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Attiva la geolocalizzazione!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
            top: 40,
            left: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon:
                      Icon(Icons.settings, color: StaticGesture.getTextColor(context, Colors.white, Colors.black87), size: 35),
                  onPressed: () {
                    setState(() => StaticGesture.showMenu = !StaticGesture.showMenu);
                  },
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: StaticGesture.showMenu
                      ? Row(
                          key: const ValueKey('menu'),
                          children: [
                            IconButton(
                              icon: Icon(
                                Provider.of<ThemeProvider>(context).isDarkMode
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: StaticGesture.getTextColor(context, Colors.white, Colors.black),
                                size: 35,
                              ),
                              onPressed: () {
                                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.logout, color: StaticGesture.getTextColor(context, Colors.white, Colors.black), size: 35),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                await GoogleSignIn().signOut();
                                
                                if(!mounted) return;
                                StaticGesture.showAppSnackBar(context, 'Logout effettuato');

                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => MyHomePage(title: 'login')),
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
        ],
      ),
    );
  }
}