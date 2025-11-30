import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

import 'gps_screen.dart';
import 'vacuna_screen1.dart';
import 'pet_screen1.dart';
import 'user_screen1.dart';

class UserScreen2 extends StatefulWidget {
  @override
  _UserScreen2State createState() => _UserScreen2State();
}

class _UserScreen2State extends State<UserScreen2> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  int? idUsuario;
  bool _loading = false;

  // 🆕 Variables para manejo de imagen
  File? imagenSeleccionada;
  String? nombreImagen;
  bool tieneImagenExistente = false;
  bool imagenEliminada = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("id");
    if (id == null) return;

    setState(() {
      idUsuario = id;
    });

    final url =
        Uri.parse("https://proyectodackybackend.onrender.com/perfil/$id");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        nombreController.text = data["NomDueño"] ?? "";
        apellidosController.text = data["Apell"] ?? "";
        correoController.text = data["Email"] ?? "";
        celularController.text = data["NumCel"] ?? "";
        telefonoController.text = data["NumTelf"] ?? "";
        direccionController.text = data["Direccion"] ?? "";

        // 🆕 Cargar información de imagen existente
        tieneImagenExistente = data['tieneImagen'] == true;
      });
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

  // 🆕 Seleccionar imagen
  Future<void> _seleccionarImagen() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        imagenSeleccionada = File(result.files.single.path!);
        nombreImagen = result.files.single.name;
        imagenEliminada = false;
      });
    }
  }

  // 🆕 Eliminar imagen existente
  Future<void> _eliminarImagenExistente() async {
    if (idUsuario == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFD8CFBC),
        title:
            const Text('Confirmar', style: TextStyle(fontFamily: 'Montserrat')),
        content: const Text(
          '¿Deseas eliminar tu foto de perfil?',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(fontFamily: 'Montserrat')),
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

    try {
      final url = Uri.parse(
          "https://proyectodackybackend.onrender.com/perfil/$idUsuario/imagen");

      final response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          tieneImagenExistente = false;
          imagenEliminada = true;
        });
        _mostrarAlerta("Imagen eliminada correctamente.", exito: true);
      } else {
        _mostrarAlerta("Error al eliminar la imagen.");
      }
    } catch (e) {
      _mostrarAlerta("Error: $e");
    }
  }

  Future<void> _guardarPerfil() async {
    if (idUsuario == null) return;

    setState(() => _loading = true);

    try {
      final url = Uri.parse(
          "https://proyectodackybackend.onrender.com/perfil/$idUsuario");

      var request = http.MultipartRequest('PUT', url);
      request.fields['NomDueño'] = nombreController.text;
      request.fields['Apell'] = apellidosController.text;
      request.fields['Email'] = correoController.text;
      request.fields['NumCel'] = celularController.text;
      request.fields['NumTelf'] = telefonoController.text;
      request.fields['Direccion'] = direccionController.text;

      if (imagenSeleccionada != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'imagen',
          imagenSeleccionada!.path,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      setState(() => _loading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _mostrarAlerta(data["message"] ?? "Perfil actualizado", exito: true);

        // Esperar un momento y volver
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        _mostrarAlerta("Error al actualizar perfil");
      }
    } catch (e) {
      setState(() => _loading = false);
      _mostrarAlerta("Error: $e");
    }
  }

  // 🆕 Widget para mostrar la imagen de perfil
  Widget _buildProfileImage() {
    final imagenProvider = _obtenerImagenPerfil();

    return GestureDetector(
      onTap: _seleccionarImagen,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF11120D),
                width: 3,
              ),
            ),
            child: imagenProvider != null
                ? CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey[300],
                    child: ClipOval(
                      child: imagenSeleccionada != null
                          ? Image.file(
                              imagenSeleccionada!,
                              fit: BoxFit.cover,
                              width: 130,
                              height: 130,
                            )
                          : Image.network(
                              "https://proyectodackybackend.onrender.com/perfil/$idUsuario/imagen?t=${DateTime.now().millisecondsSinceEpoch}",
                              fit: BoxFit.cover,
                              width: 130,
                              height: 130,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                    '❌ Error cargando imagen en edición: $error');
                                return Image.asset(
                                  'assets/perfil_user.png',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                    ),
                  )
                : CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: const AssetImage('assets/perfil_user.png'),
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF11120D),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child:
                  const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _obtenerImagenPerfil() {
    // Si se seleccionó una nueva imagen localmente
    if (imagenSeleccionada != null) {
      return FileImage(imagenSeleccionada!);
    }
    // Si hay imagen existente en el servidor y no se eliminó
    else if (tieneImagenExistente && !imagenEliminada && idUsuario != null) {
      // 🔹 IMPORTANTE: Agregar key única para forzar recarga
      return NetworkImage(
        "https://proyectodackybackend.onrender.com/perfil/$idUsuario/imagen?t=${DateTime.now().millisecondsSinceEpoch}",
      );
    }
    // Imagen por defecto
    else {
      return null; // Esto hará que se muestre el ícono de persona
    }
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
                    child:
                        Image.asset('assets/atras.png', width: 28, height: 28),
                  ),
                  const Text('Editar Perfil',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat')),
                  Image.asset('assets/menu.png', width: 28, height: 28),
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
                    color: const Color(0xFFD8CFBC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // 🆕 Imagen de perfil
                      _buildProfileImage(),
                      const SizedBox(height: 8),
                      Text(
                        'Toca para cambiar foto',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),

                      // 🆕 Botón para eliminar imagen
                      if ((tieneImagenExistente ||
                              imagenSeleccionada != null) &&
                          !imagenEliminada)
                        TextButton.icon(
                          onPressed:
                              tieneImagenExistente && imagenSeleccionada == null
                                  ? _eliminarImagenExistente
                                  : () {
                                      setState(() {
                                        imagenSeleccionada = null;
                                        nombreImagen = null;
                                      });
                                    },
                          icon: const Icon(Icons.delete,
                              size: 18, color: Colors.red),
                          label: const Text(
                            'Eliminar foto',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      _buildTextField('Nombre', nombreController),
                      _buildTextField('Apellidos', apellidosController),
                      _buildTextField('Correo', correoController),
                      _buildTextField('Celular', celularController),
                      _buildTextField('Teléfono', telefonoController),
                      _buildTextField('Dirección', direccionController),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF11120D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                        ),
                        onPressed: _loading ? null : _guardarPerfil,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Guardar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontSize: 16)),
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
          Text(label, style: const TextStyle(fontFamily: 'Montserrat')),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFBF4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ],
      ),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GpsScreen()),
              );
            },
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VacunaScreen1()),
              );
            },
            child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PetScreen1()),
              );
            },
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserScreen1()),
              );
            },
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}
