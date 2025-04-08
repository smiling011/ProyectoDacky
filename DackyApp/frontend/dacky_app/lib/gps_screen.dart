import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'gps_screen.dart';
import 'vacuna_screen1.dart';
import 'pet_screen1.dart';
import 'user_screen1.dart';

class GpsScreen extends StatefulWidget {
  @override
  _GpsScreenState createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  late GoogleMapController mapController;

  final LatLng _initialPosition =
      const LatLng(19.432608, -99.133209); // CDMX de ejemplo

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Image.asset(
              'assets/Minilogo dacky.png', // Logo en la esquina superior derecha
              width: 50,
              height: 50,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xFF11120D),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton('assets/collar-para-mascotas.png', 'Conectar GPS'), // Reemplaza con la ruta correcta
                      _buildButton('assets/localizacion.png', 'Buscar'), // Reemplaza con la ruta correcta
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildBottomNavBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String imagePath, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 30,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              imagePath,
              width: 30,
              height: 30,
              color: Color(0xFF11120D), // Opcional: aplica un color si es necesario
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GpsScreen()),
                );
              },
              child: Image.asset(
                'assets/gps_icon.png', // Reemplaza con la ruta correcta
                width: 30,
                height: 30,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VacunaScreen1()),
                );
              },
              child: Image.asset(
                'assets/vacuna_icon.png', // Reemplaza con la ruta correcta
                width: 30,
                height: 30,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PetScreen1()),
                );
              },
              child: Image.asset(
                'assets/huella_icon.png', // Reemplaza con la ruta correcta
                width: 30,
                height: 30,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserScreen1()),
                );
              },
              child: Image.asset(
                'assets/user_icon.png', // Reemplaza con la ruta correcta
                width: 30,
                height: 30,
              ),
            ),
          ],
        ));
  }
}