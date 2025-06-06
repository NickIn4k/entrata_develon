// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// class SecondaPagina extends StatefulWidget {
//   const SecondaPagina({super.key});

//   @override
//   _SecondaPaginaState createState() => _SecondaPaginaState();
// }

// class _SecondaPaginaState extends State<SecondaPagina> {
//   Position? _currentPosition;
//   double? _distanceFromFixedPoint;
//   final double fixedLatitude = 45.504111;
//   final double fixedLongitude = 11.409306;

//   @override
//   void initState() {
//     super.initState();
//     _startLocationUpdates();
//   }

//   Future<void> _startLocationUpdates() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled)
//       return;

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied)
//         return;
//     }

//     if (permission == LocationPermission.deniedForever) 
//       return;

//     Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.bestForNavigation,
//         distanceFilter: 1, // aggiorna ogni metro
//       ),
//     ).listen((Position position) {
//       double distanza = Geolocator.distanceBetween(
//         position.latitude,
//         position.longitude,
//         fixedLatitude,
//         fixedLongitude,
//       );

//       setState(() {
//         _currentPosition = position;
//         _distanceFromFixedPoint = distanza;
//       });

//       // Mostra SnackBar solo se si supera la distanza massima
//       if (distanza > 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Devi avvicinarti al punto! (${distanza.toStringAsFixed(2)} metri)',
//             ),
//             backgroundColor: Colors.redAccent,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isWithinRange = _distanceFromFixedPoint != null &&
//         _distanceFromFixedPoint! >= 0 &&
//         _distanceFromFixedPoint! <= 200;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Apertura porta d\'ingresso'),
//       ),
//       body: Center(
//         child: _currentPosition == null
//             ? const CircularProgressIndicator()
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Latitudine: ${_currentPosition!.latitude.toStringAsFixed(5)}',
//                   ),
//                   Text(
//                     'Longitudine: ${_currentPosition!.longitude.toStringAsFixed(5)}',
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Distanza dal punto fisso:',
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   Text(
//                     '${_distanceFromFixedPoint?.toStringAsFixed(2)} metri',
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blueAccent,
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   // Bottone "Apri porta"
//                   ElevatedButton(
//                     onPressed: isWithinRange
//                         ? () {
//                             // Logica per aprire la porta
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Porta aperta!'),
//                                 backgroundColor: Colors.green,
//                               ),
//                             );
//                           }
//                         : null,
//                     style: ElevatedButton.styleFrom(
//                       shape: const CircleBorder(),
//                       padding: const EdgeInsets.all(40),
//                       backgroundColor:
//                           isWithinRange ? Colors.blue : Colors.grey,
//                     ),
//                     child: const Text(
//                       'Apri porta',
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SecondaPagina extends StatefulWidget {
  const SecondaPagina({super.key});

  @override
  _SecondaPaginaState createState() => _SecondaPaginaState();
}

class _SecondaPaginaState extends State<SecondaPagina> {
  final double max = 150.5;

  Position? _currentPosition;
  double? _distanceFromFixedPoint;
  bool _isLoading = false;
  bool _portaAperta = false;

  final double fixedLatitude = 45.504111;
  final double fixedLongitude = 11.409306;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  Future<void> _startLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
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

  Future<void> _apriPorta() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 5));

    setState(() {
      _isLoading = false;
      _portaAperta = true;
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
    bool isWithinRange = _distanceFromFixedPoint != null &&
        _distanceFromFixedPoint! >= 0 &&
        _distanceFromFixedPoint! <= max;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apertura porta d\'ingresso'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: _currentPosition == null
                  ? const CircularProgressIndicator()
                  : _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: isWithinRange
                              ? () {
                                  if (!_portaAperta) {
                                    _apriPorta();
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(60),
                            backgroundColor: _portaAperta
                                ? Colors.red
                                : (isWithinRange ? Colors.blue : Colors.grey),
                          ),
                          child: Text(
                            _portaAperta ? 'Chiudi porta' : 'Apri porta',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                        ),
            ),
          ),
          if (_distanceFromFixedPoint != null &&
              _distanceFromFixedPoint! > max)
            Container(
              color: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              width: double.infinity,
              child: Text(
                'Devi avvicinarti al punto! (${_distanceFromFixedPoint!.toStringAsFixed(2)} m)',
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