// Screen para mostrar cuando NO hay mascotas registradas
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'gps_screen.dart';
import 'vacuna_screen2.dart';
import 'pet_screen1.dart';
import 'pet_screen2.dart';
import 'user_screen1.dart';

class VacunaScreen1 extends StatefulWidget {
  const VacunaScreen1({super.key});

  @override
  State<VacunaScreen1> createState() => _VacunaScreen1State();
}

class _VacunaScreen1State extends State<VacunaScreen1> {
  bool _loading = true;
  bool _hasPets = false;

  @override
  void initState() {
    super.initState();
    _checkPets();
  }

  Future<void> _checkPets() async {
    final prefs = await SharedPreferences.getInstance();
    final idUsuario = prefs.getInt('id');

    if (idUsuario == null) {
      setState(() => _loading = false);
      return;
    }

    final url = Uri.parse("http://192.168.0.17:5000/pet/$idUsuario");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List mascotas = json.decode(response.body);

      if (mascotas.isNotEmpty) {
        // ✅ Si ya tiene mascotas → ir directo a VacunaScreen2
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VacunaScreen2()),
          );
        });
      } else {
        setState(() {
          _hasPets = false;
          _loading = false;
        });
      }
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F3), // Fondo claro
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Encabezado
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
                    'Tarjeta de Vacunas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                  ),
                  Image.asset(
                    'assets/Minilogo dacky.png',
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // 🔹 Imagen centrada con botón para registrar mascota
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // ✅ Navegar a formulario de mascotas
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PetScreen2()),
                    );
                  },
                  child: Image.asset(
                    'assets/agregar.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
            // const Text(
            //   "Agrega tu primera mascota para\nactivar la tarjeta de vacunas",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
          ],
        ),
      ),

      // 🔹 Barra inferior
      bottomNavigationBar: SafeArea(child: _buildBottomNavBar(context)),
    );
  }

  // 🔹 Barra de navegación inferior
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GpsScreen()));
            },
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              // Ya estamos en VacunaScreen1
            },
            child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PetScreen1()));
            },
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) =>  UserScreen1()));
            },
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}
