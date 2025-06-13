import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// File locali
import 'static_gesture.dart';

class HeroDetailPage extends StatefulWidget {
  final Pagina pagina;

  const HeroDetailPage({super.key, required this.pagina});

  @override
  State<HeroDetailPage> createState() => _HeroDetailPageState();
} 

class _HeroDetailPageState extends State<HeroDetailPage> {
  // isOpen: stato del menu ad espansione
  bool isOpen = false;
  // isOpen: stato del menu ad espansione
  bool traduzioneOn = false;

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

  // Eventi di callback per il menù e per la traduzione
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

  // Rimozione dei listener dopo il dispose del widget
  @override
  void dispose() {
    StaticGesture.menuFlag.removeListener(onFlagChanged);
    StaticGesture.traduzioneOn.removeListener(onTraduzione);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Disabilita il resize
      body: Stack(
        children: [
          // Builder per il rebuild con ValueNotifier<bool>
          ValueListenableBuilder<bool>(
            valueListenable: StaticGesture.menuFlag,
            builder: (context, value, child) {
              return SizedBox.shrink();
            },
          ),
          // Sfondo dinamico
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  widget.pagina == Pagina.prima 
                    ? StaticGesture.getPath(context, 'assets/background/Background.jpg', 'assets/background/DarkBackground.png')
                    : StaticGesture.getPath(context, 'assets/background/Background2.jpg', 'assets/background/DarkBackground2.png')
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenuto centrale con logo e testi
          Center(
            child: IntrinsicHeight(
              child: Container (
                padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: StaticGesture.getContainerColor(context),
                    borderRadius: BorderRadius.circular(32),
                  ),
                child: Column(
                  children: [
                    Stack(                     
                      children: [
                        // Logo cliccabile che apre il sito web
                        GestureDetector(
                          onTap: () async{
                            final Uri url = Uri.parse('https://www.develon.com/it/');
                            if (!await launchUrl(url)) {
                              throw Exception('Could not launch $url');
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              StaticGesture.getPath(context, 'assets/logo/logoDevelon.png','assets/logo/logoDevelonI.png'),
                              width: 200,
                              height: 200,
                            ),
                          ),
                        ),      
                        // Icona per indicare apertura esterna link                
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Icon(Icons.open_in_new, color: StaticGesture.getIconColor(context,Colors.black87, Colors.white)),
                        ),
                      ]
                    ),
                    // Titolo
                    Text(
                      "PCTO 2025",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: StaticGesture.getTextColor(context, Colors.white, Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Sottotitolo
                    Text(
                      'Carlassara Pietro & Creazzo Nicola',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: StaticGesture.getTextColor( context, Colors.white, Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Pulsante in basso a destra per tornare indietro
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
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
                      ? 'assets/logo/LogoGoogle.png'
                      : 'assets/logo/BuildingIcon.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
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
                  alignment: Alignment.centerLeft, // fondamentale: si apre da sinistra
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Button di apertura
                      IconButton(
                        icon: Icon(Icons.settings,
                            color: StaticGesture.getTextColor(context, Colors.white, Colors.black87), size: 35),
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
                                  context, Colors.white, Colors.black),
                                size: 35,
                              ),
                              onPressed: () {
                                StaticGesture.changeTheme(context);
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
    );
  }
}