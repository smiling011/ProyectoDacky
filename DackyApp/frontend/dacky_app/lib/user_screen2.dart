import 'package:flutter/material.dart';
import 'gps_screen.dart';
import 'vacuna_screen1.dart';
import 'pet_screen1.dart';
import 'user_screen1.dart';

class UserScreen2 extends StatelessWidget {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

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

            // Formulario
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildTextField('Nombre', nombreController),
                      _buildTextField('Apellidos', apellidosController),
                      _buildTextField('Correo', correoController),
                      _buildTextField('Celular', celularController),
                      _buildTextField('Telefono', telefonoController),
                      _buildTextField('Direccion', direccionController),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF11120D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                        ),
                        onPressed: () {
                          // Acción para guardar datos
                        },
                        child: Text('Guardar',
                            style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Barra inferior
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildBottomNavBar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFFFFBF4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
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
