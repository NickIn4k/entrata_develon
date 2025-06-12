import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'static_gesture.dart';
import 'account.dart';

class HeroDetailPage extends StatefulWidget {
  final Pagina pagina;

  const HeroDetailPage({super.key, required this.pagina});

  @override
  State<HeroDetailPage> createState() => _HeroDetailPageState();
}

class _HeroDetailPageState extends State<HeroDetailPage> {
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    isOpen = StaticGesture.menuFlag.value;
    StaticGesture.menuFlag.addListener(onFlagChanged);
  }

  void onFlagChanged() {
    setState(() {
      isOpen = StaticGesture.menuFlag.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: StaticGesture.menuFlag,
            builder: (context, value, child) {
              return SizedBox.shrink();
            },
          ),
          // Sfondo
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
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Icon(Icons.open_in_new, color: StaticGesture.getIconColor(context,Colors.black87, Colors.white)),
                        ),
                      ]
                    ),
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
                    Text(
                      "Carlassara Pietro e Creazzo Nicola",
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
                      ? 'assets/logo/LogoMigliore.png'
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
                                color: StaticGesture.getTextColor(
                                  context, Colors.white, Colors.black),
                                size: 35,
                              ),
                              onPressed: () {
                                StaticGesture.changeTheme(context);
                              },
                            ),
                            if(widget.pagina == Pagina.seconda)
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
        ],
      ),
    );
  }
}