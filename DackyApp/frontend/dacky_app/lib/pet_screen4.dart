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
        Uri.parse("https://proyectodackybackend.onrender.com/pet/detalle/${widget.idMascota}");
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
    // Confirmación antes de eliminar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFD8CFBC),
        title: const Text('Confirmar eliminación', 
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro de eliminar a ${mascota!['NomMascota']}?',
          style: const TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(fontFamily: 'Montserrat')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', 
              style: TextStyle(fontFamily: 'Montserrat', color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final url = Uri.parse("https://proyectodackybackend.onrender.com/pet/detalle/${widget.idMascota}");
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      Navigator.pop(context); // Regresa a la lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar mascota')),
      );
    }
  }
// 🆕 Widget para mostrar imagen de perfil
Widget _buildProfileAvatar() {
  final tieneImagen = mascota!['tieneImagen'] == true;
  
  // 🆕 AGREGAR ESTOS PRINTS
  print("🖼️ tieneImagen: $tieneImagen");
  print("🆔 idMascota: ${widget.idMascota}");
  print("📦 mascota completa: $mascota");

  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: const Color(0xFF11120D),
        width: 4,
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
      radius: 90,
      backgroundColor: Colors.grey[300],
      backgroundImage: tieneImagen
          ? NetworkImage(
              "https://proyectodackybackend.onrender.com/pet/detalle/${widget.idMascota}/imagen",
            ) as ImageProvider
          : const AssetImage('assets/images/Perfil_Perro_Gato.png'),
      onBackgroundImageError: tieneImagen
          ? (exception, stackTrace) {
              print('❌ Error cargando imagen: $exception');
            }
          : null,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
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

            // Contenido
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : mascota == null
                      ? const Center(
                          child: Text(
                            "Mascota no encontrada",
                            style: TextStyle(fontFamily: 'Montserrat'),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              
                              // 🆕 Avatar con imagen dinámica
                              _buildProfileAvatar(),
                              
                              const SizedBox(height: 12),
                              Text(
                                mascota!['NomMascota'] ?? 'Sin nombre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mascota!['Raza'] ?? 'Sin raza',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Información en tarjeta
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsets.all(20),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InfoRow(
                                      label: 'Peso',
                                      value: "${mascota!['Peso']} kg",
                                      icon: Icons.monitor_weight_outlined,
                                    ),
                                    const Divider(height: 20),
                                    InfoRow(
                                      label: 'Altura',
                                      value: "${mascota!['Altura']} cm",
                                      icon: Icons.height,
                                    ),
                                    const Divider(height: 20),
                                    InfoRow(
                                      label: 'Edad',
                                      value: "${mascota!['Edad']} años",
                                      icon: Icons.cake_outlined,
                                    ),
                                    if (mascota!['Descripcion'] != null &&
                                        mascota!['Descripcion'].toString().isNotEmpty) ...[
                                      const Divider(height: 20),
                                      InfoRow(
                                        label: 'Descripción',
                                        value: mascota!['Descripcion'],
                                        icon: Icons.description_outlined,
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Botones editar y borrar
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Botón editar
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PetScreen2(
                                            mascota: mascota,
                                          ),
                                        ),
                                      ).then((_) {
                                        _cargarMascota(); // Refrescar al volver
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF11120D),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/editar.png',
                                            width: 24,
                                            height: 24,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Editar',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 20),
                                  
                                  // Botón eliminar
                                  GestureDetector(
                                    onTap: _eliminarMascota,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/borrar.png',
                                            width: 24,
                                            height: 24,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Eliminar',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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

// 🔹 Fila de información mejorada con icono
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: const Color(0xFF11120D)),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
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
}