import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'gps_screen.dart';
import 'vacuna_screen1.dart';
import 'pet_screen1.dart';
import 'user_screen2.dart';

class UserScreen1 extends StatefulWidget {
  @override
  _UserScreen1State createState() => _UserScreen1State();
}

class _UserScreen1State extends State<UserScreen1> {
  Map<String, dynamic>? perfil;
  int? idUsuario;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    idUsuario = prefs.getInt('id');

    if (idUsuario == null) return;

    final url = Uri.parse("http://192.168.0.15:5000/perfil/$idUsuario");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        perfil = json.decode(response.body);
      });
    } else {
      print("Error al cargar perfil: ${response.body}");
    }
  }

  // 🆕 Widget para mostrar avatar con imagen de perfil
  Widget _buildProfileAvatar() {
    final tieneImagen = perfil!['tieneImagen'] == true;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF11120D),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[300],
        backgroundImage: tieneImagen
            ? NetworkImage(
                "http://192.168.0.15:5000/perfil/$idUsuario/imagen",
              ) as ImageProvider
            : const AssetImage('assets/perfil_user.png'),
        child: tieneImagen ? null : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      body: SafeArea(
        child: perfil == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Encabezado
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
                          'Mi Perfil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Image.asset('assets/menu.png', width: 28, height: 28),
                      ],
                    ),
                  ),

                  // Tarjeta de información
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8CFBC),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // 🆕 Avatar con imagen dinámica
                            _buildProfileAvatar(),
                            
                            const SizedBox(height: 16),
                            
                            // Nombre completo destacado
                            Text(
                              '${perfil!['NomDueño']} ${perfil!['Apell']}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                                color: Color(0xFF11120D),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              perfil!['Email'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Información en tarjetas
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBF4),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    'Celular',
                                    perfil!['NumCel'] ?? 'No registrado',
                                    Icons.phone_android,
                                  ),
                                  const Divider(height: 24),
                                  _buildInfoRow(
                                    'Teléfono',
                                    perfil!['NumTelf'] ?? 'No registrado',
                                    Icons.phone,
                                  ),
                                  const Divider(height: 24),
                                  _buildInfoRow(
                                    'Dirección',
                                    perfil!['Direccion'] ?? 'No registrada',
                                    Icons.location_on,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Botón de editar
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserScreen2(),
                                  ),
                                ).then((_) {
                                  // Recargar perfil al volver
                                  _cargarPerfil();
                                });
                              },
                              icon: const Icon(Icons.edit, color: Colors.white),
                              label: const Text(
                                'Editar Perfil',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF11120D),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Barra de navegación inferior
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildBottomNavBar(context),
                  ),
                ],
              ),
      ),
    );
  }

  // 🆕 Widget mejorado para mostrar información con iconos
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: const Color(0xFF11120D),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF11120D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => GpsScreen())),
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => VacunaScreen1())),
            child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => PetScreen1())),
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          Image.asset('assets/user_icon.png', width: 30, height: 30), // Ya estamos aquí
        ],
      ),
    );
  }
}