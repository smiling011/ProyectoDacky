import 'package:flutter/material.dart';
import 'gps_screen.dart';
import 'vacuna_screen1.dart';
import 'pet_screen1.dart';
import 'user_screen1.dart';

class VacunaScreen1 extends StatelessWidget {
  const VacunaScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F3), // Fondo claro
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado
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

            const SizedBox(height: 80),

            // Imagen centrada con botón
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // Aquí navegas al formulario para agregar mascota
                    Navigator.pushNamed(context, '/add_pet');
                  },
                  child: Image.asset(
                    'assets/agregar.png',
                    width: 65,  // o el tamaño que prefieras
                    height: 65,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomNavBar(context)),
    );
  }

  // Barra de navegación inferior
  Widget _buildBottomNavBar(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              context,
              MaterialPageRoute(builder: (context) => GpsScreen()),
            );
          },
          child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VacunaScreen1()),
            );
          },
          child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PetScreen1()),
            );
          },
          child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserScreen1()),
            );
          },
          child: Image.asset('assets/user_icon.png', width: 30, height: 30),
        ),
      ],
    ),
  );
}

}
