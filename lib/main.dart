import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: const MyHomePage(title: 'Login'),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
  );
}
}

// Login

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Pulsante grande "Accedi con Google" ---
            SizedBox(
              width: 300,
              height: 80,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.login, size: 32),
                label: const Text('Accedi con Google'),
                onPressed: () => signInWithGoogle(),
              ),
            ),

            const SizedBox(height: 24), // spazio tra i due bottoni

            // --- Pulsante "Login" che apre SecondaPagina ---
            SizedBox(
              width: 200, // puoi regolare la larghezza a piacere
              height: 50, // altezza “normale” per un pulsante
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecondaPagina(),
                    ),
                  );
                },
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

signInWithGoogle() async {
  GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
  AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken
  );
  UserCredential? userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

  print(userCredential.user?.displayName);
}

// Seconda Pagina --------------

class SecondaPagina extends StatefulWidget {
  const SecondaPagina({super.key});

  @override
  _SecondaPaginaState createState() => _SecondaPaginaState();
}

class _SecondaPaginaState extends State<SecondaPagina>{
  Position? _currentPosition;
  double? _distanceFromFixedPoint;

  // Da cambiare!
  final double fixedLatitude = 45.553500;
  final double fixedLongitude = 11.546028;

    @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  Future<void> _startLocationUpdates() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      print("I serivizi di localizzazione sono disabilitati");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Permessi negati");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Permessi negati permanentemente");
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
        // timeLimit: Duration(seconds: 3),
      ),
    ).listen((Position position) {
      double distanza = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        fixedLatitude,
        fixedLongitude,
      );

      setState(() {
        _currentPosition = position;
        _distanceFromFixedPoint = distanza;
      });
    });
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apertura porta d\'ingresso'),
      ),
      body: Center(
        child: _currentPosition == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Latitudine: ${_currentPosition!.latitude.toStringAsFixed(5)}',
                  ),
                  Text(
                    'Longitudine: ${_currentPosition!.longitude.toStringAsFixed(5)}',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Distanza dal punto fisso:',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${_distanceFromFixedPoint?.toStringAsFixed(2)} metri',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Torna alla Prima Pagina"),
                  ),
                ],
              ),
      ),
    );
  }
}
