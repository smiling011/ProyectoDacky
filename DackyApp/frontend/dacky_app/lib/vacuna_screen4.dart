import 'package:flutter/material.dart';
import 'vacuna_screen5.dart';
import 'vacuna_screen1.dart';
import 'gps_screen.dart';
import 'pet_screen1.dart';
import 'user_screen1.dart';

class VacunaScreen4 extends StatelessWidget {
  const VacunaScreen4({super.key});

  // Barra de navegación inferior
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GpsScreen()));
            },
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VacunaScreen1()));
            },
            child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PetScreen1()));
            },
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserScreen1()));
            },
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }

  // Widget para una tarjeta de vacuna
  Widget _buildVaccineCard(String nombre, String fecha) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/ampolla.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nombre:  $nombre",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Fecha:  $fecha"),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F3),
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Image.asset(
                    'assets/Minilogo dacky.png',
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ),

            // Mascota (imagen + nombre)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/perfil_mascota.png'),
                    radius: 30,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Mascota 1',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Lista de vacunas (puedes duplicar según los datos reales)
            _buildVaccineCard('Rabia Canina', '10 / 07 / 2013'),
            _buildVaccineCard('Rabia Canina', '10 / 07 / 2013'),

            const SizedBox(height: 20),

            // Botón agregar (icono central)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VacunaScreen5()),
                );
              },
              child: Image.asset(
                'assets/agregar.png',
                width: 55,
                height: 55,
              ),
            ),

            const Spacer(),

            // Barra de navegación inferior
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }
}
