// Screen para agregar vacunas si la mascota seleccionada no tiene ninguna registrada
import 'package:flutter/material.dart';
import 'gps_screen.dart';
import 'vacuna_screen5.dart';
import 'pet_screen1.dart';
import 'user_screen1.dart';

class VacunaScreen3 extends StatelessWidget {
  final int idMascota;
  const VacunaScreen3({super.key, required this.idMascota});

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
                    child: Image.asset('assets/atras.png', width: 28, height: 28),
                  ),
                  const Text(
                    'Tarjeta de Vacunas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Image.asset('assets/Minilogo dacky.png', width: 50, height: 50),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // 🔹 Botón + mensaje centrados
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 🔹 ajusta al contenido
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => VacunaScreen5(idMascota: idMascota)),
                        );
                      },
                      child: Image.asset(
                        'assets/agregar.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Agrega la primera vacuna para tu mascota",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            _buildBottomNavBar(context),
          ],
        ),
      ),
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
          InkWell(onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const GpsScreen()));
          }, child: Image.asset('assets/gps_icon.png', width: 30, height: 30)),
          Image.asset('assets/vacuna_icon.png', width: 30, height: 30), // ya estamos aquí
          InkWell(onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PetScreen1()));
          }, child: Image.asset('assets/huella_icon.png', width: 30, height: 30)),
          InkWell(onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => UserScreen1()));
          }, child: Image.asset('assets/user_icon.png', width: 30, height: 30)),
        ],
      ),
    );
  }
}
