import 'package:flutter/material.dart';
import 'gps_screen.dart';
import 'vacuna_screen1.dart';
import 'pet_screen1.dart';
import 'user_screen1.dart'; // Este mismo archivo
import 'user_screen2.dart';

class UserScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFBF4),
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/atras.png',
                    width: 28,
                    height: 28,
                  ),
                  Text(
                    'Mi Perfil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Image.asset(
                    'assets/menu.png',
                    width: 28,
                    height: 28,
                  ),
                ],
              ),
            ),

            // Tarjeta de información
            Expanded(
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage(
                            'assets/usuario.png'), // Reemplaza con tu imagen
                      ),
                      SizedBox(height: 20),
                      _buildInfoRow('Nombre', 'Victoria'),
                      _buildInfoRow('Apellidos', 'Vielma'),
                      _buildInfoRow('Correo', 'victoria@gmail.com'),
                      _buildInfoRow('Celular', '3246254615'),
                      _buildInfoRow('Teléfono', '12345'),
                      _buildInfoRow('Dirección', 'Cl 8 cr2 int 44'),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Image.asset(
                              'assets/editar.png', // Asegúrate de tener esta imagen en tu carpeta assets
                              width: 24,
                              height: 24,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UserScreen2()), // Asegúrate de importar esta pantalla
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child:
                  Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
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
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => GpsScreen())),
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => VacunaScreen1())),
            child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => PetScreen1())),
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => UserScreen1())),
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}
