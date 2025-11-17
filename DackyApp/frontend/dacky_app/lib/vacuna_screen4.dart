/// Screen que muestra las vacunas de la mascota seleccionada
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

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
    final url = Uri.parse("http://192.168.0.15:5000/vacunas/${widget.idMascota}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => VacunaScreen3(idMascota: widget.idMascota)),
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

  // 🆕 Función para exportar PDF
  Future<void> _exportarPDF() async {
    try {
      // Mostrar diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD8CFBC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'Generando PDF...',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );

      final url = Uri.parse(
          "http://192.168.0.15:5000/vacunas/${widget.idMascota}/exportar-pdf");
      final response = await http.get(url);

      Navigator.pop(context); // Cerrar diálogo de carga

      if (response.statusCode == 200) {
        // Guardar PDF en el dispositivo
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${dir.path}/vacunas_$timestamp.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Mostrar diálogo de éxito
        _mostrarAlerta('PDF generado exitosamente', exito: true);

        // Abrir PDF
        await Future.delayed(const Duration(seconds: 1));
        await OpenFile.open(filePath);
      } else {
        _mostrarAlerta('Error al generar el PDF');
      }
    } catch (e) {
      Navigator.pop(context); // Cerrar diálogo si está abierto
      _mostrarAlerta('Error: $e');
    }
  }

  void _mostrarAlerta(String mensaje, {bool exito = false}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD8CFBC),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    exito ? "assets/comprobado.png" : "assets/advertencia.png",
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    mensaje,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                      color: Color(0xFF11120D),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset("assets/cruz.png", width: 22, height: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaccineCard(Map<String, dynamic> vacuna) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VacunaScreen5(
              idMascota: widget.idMascota,
              vacuna: vacuna,
            ),
          ),
        );

        if (result == true) {
          _cargarVacunas();
        }
      },
      child: Container(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Vacuna: ${vacuna['NomVacuna'] ?? 'Sin nombre'}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat')),
                  const SizedBox(height: 4),
                  Text("Fecha: ${vacuna['FechaVac'] ?? 'Sin fecha'}",
                      style: const TextStyle(fontFamily: 'Montserrat')),
                ],
              ),
            ),
            // 🆕 Indicador de archivo adjunto
            if (vacuna['tieneArchivo'] == true)
              const Icon(Icons.attach_file, color: Colors.green, size: 20),
          ],
        ),
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
            // 🔹 Encabezado mejorado con botón de exportar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset('assets/atras.png', width: 28, height: 28),
                  ),
                  const Expanded(
                    child: Text(
                      'Tarjeta de Vacunas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  // 🆕 Botón exportar PDF
                  GestureDetector(
                    onTap: vacunas.isEmpty ? null : _exportarPDF,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: vacunas.isEmpty
                            ? Colors.grey[300]
                            : const Color(0xFF11120D),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.picture_as_pdf,
                              color: Colors.white, size: 20),
                          SizedBox(width: 4),
                          Text(
                            'PDF',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Lista de vacunas
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: vacunas.length + 1,
                      itemBuilder: (context, index) {
                        if (index == vacunas.length) {
                          return Center(
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VacunaScreen5(
                                        idMascota: widget.idMascota),
                                  ),
                                );
                                if (result == true) {
                                  _cargarVacunas();
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Image.asset(
                                  'assets/agregar.png',
                                  width: 45,
                                  height: 45,
                                ),
                              ),
                            ),
                          );
                        }

                        return _buildVaccineCard(vacunas[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomNavBar(context)),
    );
  }

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
                    MaterialPageRoute(builder: (_) => const GpsScreen()));
              },
              child: Image.asset('assets/gps_icon.png', width: 30, height: 30)),
          Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PetScreen1()));
              },
              child:
                  Image.asset('assets/huella_icon.png', width: 30, height: 30)),
          InkWell(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => UserScreen1()));
              },
              child:
                  Image.asset('assets/user_icon.png', width: 30, height: 30)),
        ],
      ),
    );
  }
}