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

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

 Future<void> _cargarPerfil() async {
  final prefs = await SharedPreferences.getInstance();
  final idUsuario = prefs.getInt('id'); // guardado en login.dart

  if (idUsuario == null) return;

  final url = Uri.parse("http://10.1.114.19:5000/perfil/$idUsuario");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    setState(() {
      perfil = json.decode(response.body);
    });
  } else {
    print("Error al cargar perfil: ${response.body}");
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFBF4),
      body: SafeArea(
        child: perfil == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Encabezado
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/atras.png', width: 28, height: 28),
                        Text('Mi Perfil',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Image.asset('assets/menu.png', width: 28, height: 28),
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
                              backgroundImage: AssetImage('assets/usuario.png'),
                            ),
                            SizedBox(height: 20),
                            _buildInfoRow('Nombre', perfil!['NomDueño']),
                            _buildInfoRow('Apellidos', perfil!['Apell']),
                            _buildInfoRow('Correo', perfil!['Email']),
                            _buildInfoRow('Celular', perfil!['NumCel']),
                            _buildInfoRow('Teléfono', perfil!['NumTelf']),
                            _buildInfoRow('Dirección', perfil!['Direccion']),
                            SizedBox(height: 20),
                            IconButton(
                              icon: Image.asset('assets/editar.png',
                                  width: 24, height: 24),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserScreen2()),
                                );
                              },
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
          InkWell(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserScreen1())),
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}

