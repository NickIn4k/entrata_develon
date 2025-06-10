import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'static_gesture.dart';

class HeroDetailPage extends StatefulWidget {
  final Pagina pagina;

  const HeroDetailPage({super.key, required this.pagina});

  @override
  State<HeroDetailPage> createState() => _HeroDetailPageState();
}

class _HeroDetailPageState extends State<HeroDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // sfondo
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  widget.pagina == Pagina.prima 
                  ? StaticGesture.getPath(context, 'assets/background/Background.jpg', 'assets/background/DarkBackground.png')
                  : StaticGesture.getPath(context, 'assets/background/Background2.png', 'assets/background/Background2.png')
                  ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // contenuto centrale
          Center(
            child: Hero(
              tag: 'logo-hero',
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: StaticGesture.getContainerColor(context),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        StaticGesture.getPath(context, 'assets/logo/logoDevelon.png','assets/logo/logoDevelonI.png'),
                        width: 200,
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "PCTO 2025",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: StaticGesture.getTextColor(
                          context, Colors.white, Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Carlassara Pietro e Creazzo Nicola",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: StaticGesture.getTextColor(
                          context, Colors.white, Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // pulsante di ritorno
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Hero(
                tag: 'logo-login',
                child: Container(
                  height: 92,
                  width: 92,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: StaticGesture.getContainerColor(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Center(
                      child: Image.asset(
                        widget.pagina == Pagina.prima 
                        ? 'assets/logo/LogoMigliore.png'
                        : 'assets/logo/BuildingIcon.png',
                        width: widget.pagina == Pagina.prima ? 60 : 90,
                        height: widget.pagina == Pagina.prima ? 60 : 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // settings / logout
          Positioned(
            top: 40,
            left: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: StaticGesture.getTextColor(
                      context, Colors.white, Colors.black87),
                    size: 35,
                  ),
                  onPressed: () {
                    setState(() {
                      StaticGesture.showMenu = !StaticGesture.showMenu;
                    });
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
                                StaticGesture.getIconTheme(context),
                                color: StaticGesture.getTextColor(
                                  context, Colors.white, Colors.black),
                                size: 35,
                              ),
                              onPressed: () {
                                StaticGesture.changeTheme(context);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.logout,
                                color: StaticGesture.getTextColor(
                                  context, Colors.white, Colors.black),
                                size: 35,
                              ),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                await GoogleSignIn().signOut();
                                StaticGesture.showAppSnackBar(context, 'Logout effettuato');
                              },
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}