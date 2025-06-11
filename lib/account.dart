import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'static_gesture.dart';
import 'main.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.title});
  final String title;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isOpen = false;

  void onFlagChanged() {
    setState(() {
      isOpen = StaticGesture.menuFlag.value;
    });
  }

  @override
  void initState() {
    super.initState();
    isOpen = StaticGesture.menuFlag.value;
    StaticGesture.menuFlag.addListener(onFlagChanged);
  }

  @override
  Widget build(BuildContext context) {
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
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: StaticGesture.getContainerColor(context).withAlpha(128),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Dati dell\'utente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildRow(
                      context,
                      'Nome',
                      user?.displayName?.split(' ').first ?? 'Non disponibile',
                    ),
                    buildRow(
                      context,
                      'Cognome',
                      (user?.displayName?.split(' ').length == 2)
                        ? user!.displayName!.split(' ')[1]
                        : 'Non disponibile',
                    ),
                    buildRow(
                      context,
                      'Email',
                      user?.email ?? 'Non disponibile',
                    ),
                    buildRow(
                      context,
                      'Ultimo Accesso',
                      user?.metadata.lastSignInTime != null
                        ? user!.metadata.lastSignInTime!.toLocal().toString().substring(0,user.metadata.lastSignInTime!.toLocal().toString().length - 7)
                        : 'Non disponibile',
                    ),
                    const SizedBox(height: 30),
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
                        await FirebaseAuth.instance.signOut();
                        await GoogleSignIn().signOut();

                        if (!mounted) return;
                        await StaticGesture.playSound('sounds/porta_chiusa.wav');
                        StaticGesture.showAppSnackBar(context, 'Logout effettuato');

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MyHomePage(title: 'login')),
                        );
                      },
                    ),
                  ],
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
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: StaticGesture.getTextColor(context, Colors.white,Colors.black87),
                            size: 35,
                          ),
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

  Widget buildRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: StaticGesture.getContainerColor(context).withAlpha(128),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
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