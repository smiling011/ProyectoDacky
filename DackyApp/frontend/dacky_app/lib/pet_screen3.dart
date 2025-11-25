// Elistado de mascotas - Pantalla 3
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'pet_screen1.dart';
import 'pet_screen2.dart';
import 'pet_screen4.dart';
import 'gps_screen.dart';
import 'user_screen1.dart';
import 'vacuna_screen1.dart';

class PetScreen3 extends StatefulWidget {
  const PetScreen3({super.key});

  @override
  _PetScreen3State createState() => _PetScreen3State();
}

class _PetScreen3State extends State<PetScreen3> {
  List<dynamic> mascotas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMascotas();
  }

  Future<void> _cargarMascotas() async {
    final prefs = await SharedPreferences.getInstance();
    final idUsuario = prefs.getInt('id');

    if (idUsuario == null) return;

    final url = Uri.parse("https://proyectodackybackend.onrender.com/pet/$idUsuario");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        mascotas = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado fijo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/atras.png',
                      width: 28,
                      height: 28,
                    ),
                  ),
                  const Text(
                    'Perfil de Mascota',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat'),
                  ),
                  Image.asset(
                    'assets/Minilogo dacky.png',
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ),

            // Contenido principal
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      children: [
                        if (mascotas.isEmpty) ...[
                          const SizedBox(height: 50),
                          const Text(
                            "No tienes mascotas registradas",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat'),
                          ),
                          const SizedBox(height: 20),
                        ] else ...[
                          for (var mascota in mascotas) ...[
                            _buildPetCard(
                              context,
                              mascota: mascota,
                            ),
                            const SizedBox(height: 16),
                          ]
                        ],

                        // Botón agregar SIEMPRE al final
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PetScreen2()),
                              ).then((_) => _cargarMascotas());
                            },
                            child: Image.asset(
                              'assets/agregar.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
            ),

            // Barra de navegación inferior
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildBottomNavBar(context),
            ),
          ],
        ),
      ),
    );
  }

  // 🆕 Tarjeta de mascota mejorada con imagen dinámica
  Widget _buildPetCard(BuildContext context, {required Map<String, dynamic> mascota}) {
    final idMascota = mascota['IdMascota'];
    final nombre = mascota['NomMascota'] ?? 'Sin nombre';
    final tieneImagen = mascota['tieneImagen'] == true;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PetScreen4(idMascota: idMascota)),
        ).then((_) => _cargarMascotas()); // Recargar al volver
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF565449),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 🆕 Avatar con imagen dinámica
            ClipOval(
              child: tieneImagen
                  ? Image.network(
                      "https://proyectodackybackend.onrender.com/pet/detalle/$idMascota/imagen",
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Si falla la carga, mostrar imagen por defecto
                        return Image.asset(
                          'assets/images/Perfil_Perro_Gato.png',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/Perfil_Perro_Gato.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mascota['Raza'] ?? 'Sin raza',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Icono de flecha
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  // Barra de navegación inferior
  static Widget _buildBottomNavBar(BuildContext context) {
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
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => GpsScreen()));
            },
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => VacunaScreen1()));
            },
            child:
                Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => PetScreen1()));
            },
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => UserScreen1()));
            },
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}