// Formulario para registrar o editar el perfil de la mascota
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'gps_screen.dart';
import 'vacuna_screen1.dart';
import 'pet_screen1.dart';
import 'pet_screen3.dart';
import 'user_screen1.dart';

class PetScreen2 extends StatefulWidget {
  final Map<String, dynamic>? mascota;

  const PetScreen2({super.key, this.mascota});

  @override
  State<PetScreen2> createState() => _PetScreen2State();
}

class _PetScreen2State extends State<PetScreen2> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController razaController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  // final TextEditingController generoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.mascota != null) {
      nombreController.text = widget.mascota!['NomMascota'] ?? '';
      razaController.text = widget.mascota!['Raza'] ?? '';
      pesoController.text = (widget.mascota!['Peso'] ?? '').toString();
      alturaController.text = (widget.mascota!['Altura'] ?? '').toString();
      edadController.text = (widget.mascota!['Edad'] ?? '').toString();
      // generoController.text = widget.mascota!['Genero'] ?? '';
      descripcionController.text = widget.mascota!['Descripcion'] ?? '';
    }
  }

  // apra Mostrar alerta 
  void _mostrarAlerta(String mensaje, {bool exito = false}) { // validacion de si esta bien o mal
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

  //  Validaciones en los campo de texto
  bool _validarCampos() {
    if (nombreController.text.trim().isEmpty ||
        razaController.text.trim().isEmpty ||
        edadController.text.trim().isEmpty) {
      _mostrarAlerta("Todos los campos obligatorios deben llenarse.");
      return false;
    }

    final edad = int.tryParse(edadController.text) ?? -1;
    final peso = int.tryParse(pesoController.text) ?? -1;
    final altura = int.tryParse(alturaController.text) ?? -1;

    if (edad <= 0 || peso <= 0 || altura < 0) {
      _mostrarAlerta("Edad y peso deben ser mayores a 0.\nAltura no puede ser negativa.");
      return false;
    }

    return true;
  }

  Future<void> _guardarMascota() async {
    if (!_validarCampos()) return;

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final idUsuario = prefs.getInt('id');

    if (idUsuario == null) {
      _mostrarAlerta("No se encontró el usuario.");
      setState(() => _loading = false);
      return;
    }

    http.Response response;

    if (widget.mascota == null) {
      // POST → Crear mascota
      final url = Uri.parse("http://172.30.128.1:5000/pet/$idUsuario");
      response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "NomMascota": nombreController.text.trim(),
          "Raza": razaController.text.trim(),
          "Peso": int.tryParse(pesoController.text) ?? 0,
          "Altura": int.tryParse(alturaController.text) ?? 0,
          "Edad": int.tryParse(edadController.text) ?? 0,
          // "Genero": generoController.text.trim(),
          "Descripcion": descripcionController.text.trim(),
        }),
      );
    } else {
      // PUT → Editar mascota
      final idMascota = widget.mascota!['IdMascota'];
      final url = Uri.parse("http://172.30.128.1:5000/pet/detalle/$idMascota");
      response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "NomMascota": nombreController.text.trim(),
          "Raza": razaController.text.trim(),
          "Peso": int.tryParse(pesoController.text) ?? 0,
          "Altura": int.tryParse(alturaController.text) ?? 0,
          "Edad": int.tryParse(edadController.text) ?? 0,
          // "Genero": generoController.text.trim(),
          "Descripcion": descripcionController.text.trim(),
        }),
      );
    }

    setState(() => _loading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _mostrarAlerta(
        widget.mascota == null
            ? "Mascota registrada con éxito."
            : "Perfil de mascota actualizado.",
        exito: true,
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PetScreen3()),
        );
      });
    } else {
      final data = json.decode(response.body);
      _mostrarAlerta("Error: ${data['mensaje'] ?? 'No se pudo guardar'}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.mascota != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 80, bottom: 90),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8CFBC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 55,
                            backgroundImage: AssetImage('assets/images/Perfil_Perro_Gato.png'),
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(label: 'Nombre *', controller: nombreController),
                          _buildTextField(label: 'Raza *', controller: razaController),
                          _buildTextField(
                              label: 'Peso (kg) *',
                              controller: pesoController,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Altura (cm)',
                              controller: alturaController,
                              keyboardType: TextInputType.number),
                          _buildTextField(
                              label: 'Edad (años) *',
                              controller: edadController,
                              keyboardType: TextInputType.number),
                          // _buildTextField(label: 'Género *', controller: generoController),
                          _buildDescriptionField(label: 'Descripción', controller: descripcionController),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loading ? null : _guardarMascota,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(isEditing ? 'Actualizar' : 'Guardar',
                                    style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Encabezado fijo
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                color: const Color(0xFFFFFBF4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset('assets/atras.png', width: 28, height: 28),
                    ),
                    Text(isEditing ? 'Editar Mascota' : 'Nueva Mascota',
                        style: const TextStyle(fontSize: 18, fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
                    Image.asset('assets/Minilogo dacky.png', width: 50, height: 50),
                  ],
                ),
              ),
            ),

            // Barra inferior fija
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavBar(context),
            ),
          ],
        ),
      ),
    );
  }

  // Campos comunes
  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Montserrat')),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFBF4),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField(
      {required String label, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Montserrat')),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFBF4),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GpsScreen())),
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VacunaScreen1())),
            child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PetScreen1())),
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserScreen1())),
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}
