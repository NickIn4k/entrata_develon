//DA SISTEMARE LA CHIUSURA APP E IL POPUP DI ERRORE QUANDO LA GEOLOCALIZZAZIONE NON VIENE ATTIVATA


import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

class SecondaPagina extends StatefulWidget {
  const SecondaPagina({super.key});

  @override
  State<SecondaPagina> createState() => _SecondaPaginaState();
}

class _SecondaPaginaState extends State<SecondaPagina> {
  final double max = 200;

  Position? currentPosition;
  double? distanceFromDoor;
  bool isLoading = false;
  bool portaAperta = false;

  bool gpsAttivo = true;

  final double doorLatitude = 45.504111;
  final double doorLongitude = 11.409306;

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

    // Controllo iniziale
    Geolocator.isLocationServiceEnabled().then((enabled) {
      setState(() {
        gpsAttivo = enabled;
      });
    });
  }

  Future<void> locationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Future.delayed(const Duration(seconds: 5));
      SystemNavigator.pop();
      return;
    }

    LocationPermission permesso = await Geolocator.checkPermission();
    if (permesso == LocationPermission.denied) {
      permesso = await Geolocator.requestPermission();
      if (permesso == LocationPermission.denied){
        await Future.delayed(const Duration(seconds: 5));
        SystemNavigator.pop();
        return;
      }
    }

    if (permesso == LocationPermission.deniedForever){
      await Future.delayed(const Duration(seconds: 5));
      SystemNavigator.pop();
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
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 5));

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
  }

  @override
  Widget build(BuildContext context) {
    bool isWithinRange = distanceFromDoor != null &&
        distanceFromDoor! >= 0 &&
        distanceFromDoor! <= max;

    Widget content;

    if (currentPosition == null) { content = const CircularProgressIndicator(); }
    else if (isLoading) { content = const CircularProgressIndicator();}
    else {
      if (isWithinRange) {
        content = ElevatedButton(
          onPressed: () {
            if (!portaAperta) apriPorta();
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(60),
            backgroundColor: portaAperta ? Colors.red : Colors.blue,
          ),
          child: Text(
            portaAperta ? 'Chiudi porta' : 'Apri porta',
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
        );
      } else {
        content = ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(60),
            backgroundColor: Colors.grey,
          ),
          child: const Text(
            'Apri porta',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apertura porta d\'ingresso'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(child: content),
          ),

          // Banner GPS disattivato
          if (!gpsAttivo)
          Container(
            color: Colors.redAccent,
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
    );
  }
}