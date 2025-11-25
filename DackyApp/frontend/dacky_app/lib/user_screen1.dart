import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'gps_screen.dart';
import 'vacuna_screen1.dart';
import 'pet_screen1.dart';
import 'user_screen2.dart';
import 'login_screen.dart'; 

class UserScreen1 extends StatefulWidget {
  @override
  _UserScreen1State createState() => _UserScreen1State();
}

class _UserScreen1State extends State<UserScreen1> {
  Map<String, dynamic>? perfil;
  int? idUsuario;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // 🆕 Key para el Drawer

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

  // 🆕 Función para cerrar sesión
  Future<void> _cerrarSesion() async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBF4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Cerrar Sesión?',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF11120D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final prefs = await SharedPreferences.getInstance();
      
      // 🆕 Limpiar todos los datos de sesión
      await prefs.remove('id');
      await prefs.remove('email');
      await prefs.remove('token'); // Si usas token
      await prefs.remove('lastLoginTime'); // Para el tiempo de inactividad
      
      // O limpiar todo:
      // await prefs.clear();

      // 🆕 Navegar al login y remover todas las pantallas anteriores
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login', // Ajusta según tu ruta de login
        (Route<dynamic> route) => false,
      );
      
      // Si no usas rutas con nombre, usa esto:
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) => LoginScreen()),
      //   (Route<dynamic> route) => false,
      // );
    }
  }

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

  // 🆕 Drawer (menú lateral)
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFFFFBF4),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Encabezado del Drawer
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFD8CFBC),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage: perfil?['tieneImagen'] == true
                      ? NetworkImage(
                          "http://192.168.0.15:5000/perfil/$idUsuario/imagen",
                        ) as ImageProvider
                      : const AssetImage('assets/perfil_user.png'),
                ),
                const SizedBox(height: 12),
                Text(
                  perfil != null
                      ? '${perfil!['NomDueño']} ${perfil!['Apell']}'
                      : 'Usuario',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF11120D),
                  ),
                ),
                Text(
                  perfil?['Email'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Opción: Mi Perfil
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF11120D)),
            title: const Text(
              'Mi Perfil',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
            onTap: () {
              Navigator.pop(context); // Cerrar drawer
              // Ya estamos en UserScreen1
            },
          ),

          // Opción: Mis Mascotas
          ListTile(
            leading: const Icon(Icons.pets, color: Color(0xFF11120D)),
            title: const Text(
              'Mis Mascotas',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PetScreen1()),
              );
            },
          ),

          // Opción: Vacunas
          ListTile(
            leading: const Icon(Icons.medical_services, color: Color(0xFF11120D)),
            title: const Text(
              'Vacunas',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VacunaScreen1()),
              );
            },
          ),

          // Opción: GPS
          ListTile(
            leading: const Icon(Icons.location_on, color: Color(0xFF11120D)),
            title: const Text(
              'Rastreo GPS',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GpsScreen()),
              );
            },
          ),

          const Divider(),

          // 🆕 Opción: Cerrar Sesión
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Cerrar drawer primero
              _cerrarSesion();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // 🆕 Asignar key
      backgroundColor: const Color(0xFFFFFBF4),
      drawer: _buildDrawer(), // 🆕 Agregar el Drawer
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
                        // 🆕 Hacer funcional el botón de menú
                        GestureDetector(
                          onTap: () => _scaffoldKey.currentState?.openDrawer(),
                          child: Image.asset('assets/menu.png', width: 28, height: 28),
                        ),
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
                            _buildProfileAvatar(),
                            
                            const SizedBox(height: 16),
                            
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
                            
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserScreen2(),
                                  ),
                                ).then((_) {
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

                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildBottomNavBar(context),
                  ),
                ],
              ),
      ),
    );
  }

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
          Image.asset('assets/user_icon.png', width: 30, height: 30),
        ],
      ),
    );
  }
}