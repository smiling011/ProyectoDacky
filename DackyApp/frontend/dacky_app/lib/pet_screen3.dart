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
    final idUsuario = prefs.getInt('id'); //  El ID guardado en login

    if (idUsuario == null) return;

    final url = Uri.parse("http://192.168.0.12:5000/pet/$idUsuario");
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
      body: Column(
        children: [
          // 🔹 Encabezado fijo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            color: const Color(0xFFFFFBF4),
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

          // 🔹 Contenido principal
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : mascotas.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "No tienes mascotas registradas",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PetScreen2()),
                              ).then((_) => _cargarMascotas()); // 🔄 Recargar lista al volver
                            },
                            child: Image.asset(
                              'assets/agregar.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        itemCount: mascotas.length,
                        itemBuilder: (context, index) {
                          final mascota = mascotas[index];
                          return Column(
                            children: [
                              _buildPetCard(
                                context,
                                idMascota: mascota['IdMascota'],
                                name: mascota['NomMascota'],
                                imagePath: 'assets/images/dog-7694676_1280.jpg',
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PetScreen2()),
                ).then((_) => _cargarMascotas());
              },
              child: Image.asset(
                'assets/agregar.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // 🔹 Barra de navegación inferior
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  // 🔹 Tarjeta de mascota
  Widget _buildPetCard(BuildContext context,
      {required int idMascota,
      required String name,
      required String imagePath}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PetScreen4(idMascota: idMascota)), // 🔑 Pasamos ID
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF565449),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Barra de navegación inferior
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
