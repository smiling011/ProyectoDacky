// Screen con la API de Google Maps 
// Proximamente integrada con la API de GPS
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';// libreria de google maps
import 'package:shared_preferences/shared_preferences.dart';// libreria para guardar datos localmente

import 'vacuna_screen1.dart';
import 'pet_screen1.dart';
import 'user_screen1.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';


final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

// widget principal de la screen
class GpsScreen extends StatefulWidget {
  const GpsScreen({Key? key}) : super(key: key);

  @override
  _GpsScreenState createState() => _GpsScreenState();
}
// widget de estado para manejar el mapa 
class _GpsScreenState extends State<GpsScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = const LatLng(6.2442, -75.5812); // Medellín, Colombia // posicion inicial 

  String? _currentEmail;//variable que almacena el email del usuario
  int? _currentId;// variable que almacena el id del usuario

// el override inicia el estado y carga los datos del usuario
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

//metodo que carga los datos del usuario desde el almacenamiento local
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentEmail = prefs.getString('email');
      _currentId = prefs.getInt('id');
    });
  }

// y este es el metodo que crea el mapa
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

// este es el widget que construye la pantalla con el mapa y la barra inferior
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //  se muestra el mapa
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
          ),

          //  Encabezado 
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Image.asset(
                      'assets/Minilogo dacky.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // para que muestre el email y id del usuario 
                      child: Text(
                        _currentEmail != null && _currentId != null
                            ? 'Usuario: $_currentEmail\nID: $_currentId'
                            : 'Cargando usuario...',
                        style: const TextStyle(color: Colors.white, fontSize: 12),// esto es temporal solo para visulaizar el email y id para mis pruebas
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //  botones de rastreo gps y la  barra navegacion 
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea( 
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF11120D),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton('assets/collar-para-mascotas.png', 'Conectar GPS'),
                        _buildButton('assets/localizacion.png', 'Buscar'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildBottomNavBar(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// este widget construye los botones redondos con iconos y texto
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
              color: const Color(0xFF11120D),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat')),
      ],
    );
  }

// este widget construye la barra de navegacion inferior con iconos
  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {}, // Ya estás en GPS
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => VacunaScreen1()));
            },
            child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PetScreen1()));
            },
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserScreen1()));
            },
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}

