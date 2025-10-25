// Screen del listado de mascotas para seleccionar y ver/agregar vacunas
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'vacuna_screen1.dart';
import 'vacuna_screen4.dart';
import 'gps_screen.dart';
import 'pet_screen1.dart';
import 'pet_screen2.dart';
import 'user_screen1.dart';

class VacunaScreen2 extends StatefulWidget {
  const VacunaScreen2({super.key});

  @override
  State<VacunaScreen2> createState() => _VacunaScreen2State();
}

class _VacunaScreen2State extends State<VacunaScreen2> {
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

    if (idUsuario == null) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse("http://10.1.118.93:5000/pet/$idUsuario");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.isEmpty) {
        //  No tiene mascotas → redirigir a VacunaScreen1
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VacunaScreen1()),
          );
        });
      } else {
        setState(() {
          mascotas = data;
          isLoading = false;
        });
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F3),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat',),
                  ),
                  Image.asset(
                    'assets/Minilogo dacky.png',
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ),

            // 🔹 Lista de mascotas + botón agregar al final
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: mascotas.length + 1, // 👈 Se suma 1 para el botón
                      itemBuilder: (context, index) {
                        if (index == mascotas.length) {
                          // 👇 Último ítem → botón agregar
                          return Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PetScreen2()),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Image.asset(
                                  'assets/agregar.png',
                                  width: 45,
                                  height: 45,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        }

                        final mascota = mascotas[index];
                        return _buildMascotaCard(
                          context,
                          idMascota: mascota['IdMascota'],
                          nombre: mascota['NomMascota'] ?? 'Sin nombre',
                          imagePath: 'assets/images/Perfil_Perro_Gato.png', // ✅ luego dinámico
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // 🔹 Barra de navegación inferior
      bottomNavigationBar: SafeArea(child: _buildBottomNavBar(context)),
    );
  }

  // 🔹 Tarjeta de mascota
  Widget _buildMascotaCard(BuildContext context,
      {required int idMascota, required String nombre, required String imagePath}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VacunaScreen4(idMascota: idMascota),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFD8CFBC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              nombre,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                // fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }

  // 🔹 Barra inferior
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
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const GpsScreen()));
            },
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              // Ya estamos en VacunaScreen2
            },
            child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const PetScreen1()));
            },
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => UserScreen1()));
            },
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}
