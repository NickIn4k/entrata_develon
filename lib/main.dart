import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'secondPage.dart';

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
        child: SizedBox(
          width: 300,
          height: 80,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.login, size: 32),
            label: const Text('Accedi con Google'),
            onPressed: () async {
              bool successo = await signInWithGoogle();
              if (successo) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondaPagina()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}


Future<bool> signInWithGoogle() async {
  try {
    // Avvia il flusso di login con Google
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return false;
    }

    // Ottengo i token di autenticazione
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Creo le credenziali Firebase
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Effettuo il login su Firebase
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Prelevo l’utente ed estraggo l’email
    final User? user = userCredential.user;
    final String? email = user?.email;

    if (email == null || email.isEmpty) {
      //Logout
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Errore: impossibile recuperare l’email utente.')),
      );
      return false;
    }

    //dominio deve essere "@develon.com"
    if (!email.toLowerCase().endsWith('@gmail.com')) {
      //Logout 
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Accesso consentito solo con email @develon.com')),
      );
      return false;
    }
    return true;
  } catch (e) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(content: Text('Errore durante accesso: $e'),
      backgroundColor: Colors.redAccent,),
    );
    return false;
  }
}
