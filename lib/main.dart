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
final TextEditingController _usernameController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

@override
void dispose() {
  _usernameController.dispose();
  _passwordController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textInputAction: TextInputAction.next,
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SecondaPagina()),
                );
              },
              child: const Text('Login'),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.login),
              label: Text('Accedi con Google'),
              onPressed: () => signInWithGoogle(),
            ),

            const SizedBox(height: 40),
          ],
        ),
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

// -----------

// class SecondaPagina extends StatefulWidget {
//   const SecondaPagina({super.key});

//   @override
//   _SecondaPaginaState createState() => _SecondaPaginaState();
// }


class SecondaPagina extends StatelessWidget {
  const SecondaPagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geolocation App'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Torna alla Prima Pagina'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
