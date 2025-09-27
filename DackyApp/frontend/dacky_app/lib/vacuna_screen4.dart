// Screen que muestra las vacunas de la mascota seleccionada
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'vacuna_screen3.dart';
import 'vacuna_screen5.dart';
import 'gps_screen.dart';
import 'pet_screen1.dart';
import 'user_screen1.dart';

class VacunaScreen4 extends StatefulWidget {
  final int idMascota;
  const VacunaScreen4({super.key, required this.idMascota});

  @override
  State<VacunaScreen4> createState() => _VacunaScreen4State();
}

class _VacunaScreen4State extends State<VacunaScreen4> {
  List<dynamic> vacunas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarVacunas();
  }

  Future<void> _cargarVacunas() async {
    final url = Uri.parse("http://10.1.117.38:5000/vacunas/${widget.idMascota}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => VacunaScreen3(idMascota: widget.idMascota)),
          );
        });
      } else {
        setState(() {
          vacunas = data;
          isLoading = false;
        });
      }
    } else {
      setState(() => isLoading = false);
    }
  }

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
          Image.asset('assets/ampolla.png', width: 40, height: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Vacuna: $nombre", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Fecha: $fecha"),
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
            // 🔹 Encabezado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(onTap: () => Navigator.pop(context),
                    child: Image.asset('assets/atras.png', width: 28, height: 28),
                  ),
                  const Text('Tarjeta de Vacunas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Image.asset('assets/Minilogo dacky.png', width: 50, height: 50),
                ],
              ),
            ),

            // 🔹 Lista de vacunas
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: vacunas.length,
                      itemBuilder: (context, index) {
                        final v = vacunas[index];
                        return _buildVaccineCard(
                          v['NomVacuna'] ?? 'Sin nombre',
                          v['FechaVac'] ?? 'Sin fecha',
                        );
                      },
                    ),
            ),

            const SizedBox(height: 10),

            // 🔹 Botón para agregar nueva vacuna
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VacunaScreen5(idMascota: widget.idMascota)),
                );
              },
              child: Image.asset('assets/agregar.png', width: 55, height: 55),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomNavBar(context)),
    );
  }

  // 🔹 Barra inferior
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
          Image.asset('assets/vacuna_icon.png', width: 30, height: 30), // ya estamos en vacunas
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
