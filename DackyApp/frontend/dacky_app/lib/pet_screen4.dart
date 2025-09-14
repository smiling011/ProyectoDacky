// Perfil de la mascota - Pantalla 4 Vista detalle
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'pet_screen1.dart';
import 'pet_screen2.dart';
import 'gps_screen.dart';
import 'user_screen1.dart';
import 'vacuna_screen1.dart';

class PetScreen4 extends StatefulWidget {
  final int idMascota;

  const PetScreen4({super.key, required this.idMascota});

  @override
  State<PetScreen4> createState() => _PetScreen4State();
}

class _PetScreen4State extends State<PetScreen4> {
  Map<String, dynamic>? mascota;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMascota();
  }

  Future<void> _cargarMascota() async {
    final url =
        Uri.parse("http://192.168.0.12:5000/pet/detalle/${widget.idMascota}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        mascota = json.decode(response.body) as Map<String, dynamic>;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        mascota = null;
      });
    }
  }

  Future<void> _eliminarMascota() async {
    final url = Uri.parse("http://192.168.0.12:5000/pet/${widget.idMascota}");
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      Navigator.pop(context); // Regresa a la lista
    } else {
      print("Error al eliminar mascota: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      body: SafeArea(
        // ✅ Protegemos encabezado
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
                    'Hoja de Vida',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  Image.asset(
                    'assets/Minilogo dacky.png',
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ),

            // 🔹 Contenido
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : mascota == null
                      ? const Center(child: Text("Mascota no encontrada"))
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              const CircleAvatar(
                                radius: 90,
                                backgroundImage: AssetImage(
                                    'assets/images/dog-7694676_1280.jpg'),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                mascota!['NomMascota'] ?? 'Sin nombre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 20),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InfoRow(
                                        label: 'Raza',
                                        value: mascota!['Raza'] ?? ''),
                                    InfoRow(
                                        label: 'Peso',
                                        value: "${mascota!['Peso']} kg"),
                                    InfoRow(
                                        label: 'Altura',
                                        value: "${mascota!['Altura']} cm"),
                                    InfoRow(
                                        label: 'Edad',
                                        value: "${mascota!['Edad']} años"),
                                    InfoRow(
                                        label: 'Descripción',
                                        value: mascota!['Descripcion'] ?? ''),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Botones editar y borrar
                              // Dentro del Row de botones en PetScreen4:
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PetScreen2(
                                              mascota:
                                                  mascota), // ✅ pasamos datos
                                        ),
                                      ).then((_) {
                                        _cargarMascota(); // 🔄 refrescamos al volver
                                      });
                                    },
                                    child: Image.asset('assets/editar.png',
                                        width: 35, height: 35),
                                  ),
                                  const SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: _eliminarMascota,
                                    child: Image.asset('assets/borrar.png',
                                        width: 35, height: 35),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        // ✅ Barra protegida
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildBottomNavBar(context),
        ),
      ),
    );
  }

  static Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  context, MaterialPageRoute(builder: (_) => GpsScreen()));
            },
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => VacunaScreen1()));
            },
            child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => PetScreen1()));
            },
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => UserScreen1()));
            },
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}

// 🔹 Fila de información
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
