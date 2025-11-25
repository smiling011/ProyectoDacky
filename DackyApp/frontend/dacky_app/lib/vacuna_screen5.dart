import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

import 'vacuna_screen1.dart';
import 'gps_screen.dart';
import 'pet_screen1.dart';
import 'user_screen1.dart';

class VacunaScreen5 extends StatefulWidget {
  final int idMascota;
  final Map<String, dynamic>? vacuna;

  const VacunaScreen5({
    super.key,
    required this.idMascota,
    this.vacuna,
  });

  @override
  _VacunaScreen5State createState() => _VacunaScreen5State();
}

class _VacunaScreen5State extends State<VacunaScreen5> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController fechaAplicacionController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController fechaVencimientoController = TextEditingController();
  final TextEditingController notaController = TextEditingController();

  File? archivoSeleccionado;
  String? nombreArchivo;
  
  // Variables para archivo existente
  bool tieneArchivoExistente = false;
  String? nombreArchivoExistente;
  String? tipoArchivoExistente;
  bool archivoEliminado = false;

  List<bool> dosisSeleccionadas = List.generate(5, (_) => false);

  @override
  void initState() {
    super.initState();
    if (widget.vacuna != null) {
      final vacuna = widget.vacuna!;
      nombreController.text = vacuna['NomVacuna'] ?? '';
      fechaAplicacionController.text = vacuna['FechaVac'] ?? '';
      edadController.text = vacuna['Edad']?.toString() ?? '';
      fechaVencimientoController.text = vacuna['FechaVenVac'] ?? '';
      notaController.text = vacuna['Nota'] ?? '';
      
      // Cargar información del archivo existente
      tieneArchivoExistente = vacuna['tieneArchivo'] == true;
      nombreArchivoExistente = vacuna['nombreArchivo'];
      tipoArchivoExistente = vacuna['tipoArchivo'];
      
      if (vacuna['NumDosis'] != null && vacuna['NumDosis'] > 0) {
        for (int i = 0; i < vacuna['NumDosis']; i++) {
          dosisSeleccionadas[i] = true;
        }
      }
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

  bool _validarCampos() {
    if (nombreController.text.trim().isEmpty ||
        fechaAplicacionController.text.trim().isEmpty ||
        edadController.text.trim().isEmpty) {
      _mostrarAlerta("Todos los campos obligatorios deben completarse.");
      return false;
    }

    final edad = int.tryParse(edadController.text) ?? -1;
    if (edad <= 0) {
      _mostrarAlerta("La edad debe ser mayor a 0.");
      return false;
    }

    final numDosis = dosisSeleccionadas.lastIndexWhere((e) => e) + 1;
    if (numDosis == 0) {
      _mostrarAlerta("Debes seleccionar al menos una dosis.");
      return false;
    }

    return true;
  }

  Future<void> _seleccionarArchivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        archivoSeleccionado = File(result.files.single.path!);
        nombreArchivo = result.files.single.name;
        archivoEliminado = false;
      });
    }
  }

  // Descargar y abrir archivo existente
  Future<void> _descargarYAbrirArchivo() async {
    if (widget.vacuna == null) return;

    try {
      _mostrarAlerta("Descargando archivo...", exito: true);

      final url = Uri.parse(
        "https://proyectodackybackend.onrender.com/vacunas/detalle/${widget.vacuna!['IdVacunasMascota']}/archivo"
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        // Guardar en directorio de descargas
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/$nombreArchivoExistente';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        Navigator.pop(context); // Cerrar diálogo de descarga

        // Abrir con aplicación externa
        final result = await OpenFile.open(filePath);
        
        if (result.type != ResultType.done) {
          _mostrarAlerta("No se pudo abrir el archivo. Guardado en: $filePath");
        }
      } else {
        Navigator.pop(context);
        _mostrarAlerta("Error al descargar el archivo.");
      }
    } catch (e) {
      Navigator.pop(context);
      _mostrarAlerta("Error: $e");
    }
  }

  // Eliminar archivo existente
  Future<void> _eliminarArchivoExistente() async {
    if (widget.vacuna == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFD8CFBC),
        title: const Text('Confirmar', style: TextStyle(fontFamily: 'Montserrat')),
        content: const Text(
          '¿Deseas eliminar este archivo?',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(fontFamily: 'Montserrat')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(fontFamily: 'Montserrat', color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final url = Uri.parse(
        "https://proyectodackybackend.onrender.com/vacunas/detalle/${widget.vacuna!['IdVacunasMascota']}/archivo"
      );
      
      final response = await http.delete(url);
      
      if (response.statusCode == 200) {
        setState(() {
          tieneArchivoExistente = false;
          nombreArchivoExistente = null;
          archivoEliminado = true;
        });
        _mostrarAlerta("Archivo eliminado correctamente.", exito: true);
      } else {
        _mostrarAlerta("Error al eliminar el archivo.");
      }
    } catch (e) {
      _mostrarAlerta("Error: $e");
    }
  }

  Future<void> _guardarVacuna() async {
    if (!_validarCampos()) return;

    final int numDosis = dosisSeleccionadas.lastIndexWhere((e) => e) + 1;

    var uri = widget.vacuna == null
        ? Uri.parse("https://proyectodackybackend.onrender.com/vacunas/${widget.idMascota}")
        : Uri.parse("https://proyectodackybackend.onrender.com/vacunas/detalle/${widget.vacuna!['IdVacunasMascota']}");

    var request = http.MultipartRequest(
      widget.vacuna == null ? 'POST' : 'PUT',
      uri,
    );

    request.fields['NomVacuna'] = nombreController.text.trim();
    request.fields['FechaVac'] = fechaAplicacionController.text.trim();
    request.fields['Edad'] = (int.tryParse(edadController.text) ?? 0).toString();
    request.fields['FechaVenVac'] = fechaVencimientoController.text.trim();
    request.fields['NumDosis'] = numDosis.toString();
    request.fields['Nota'] = notaController.text.trim();

    if (archivoSeleccionado != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        archivoSeleccionado!.path,
      ));
    }

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      _mostrarAlerta(
        widget.vacuna == null
            ? "Vacuna registrada con éxito."
            : "Vacuna actualizada correctamente.",
        exito: true,
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context, true);
      });
    } else {
      _mostrarAlerta("Error al guardar la vacuna.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset('assets/atras.png', width: 28, height: 28),
                  ),
                  Text(
                    widget.vacuna == null ? 'Nueva Vacuna' : 'Editar Vacuna',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                  ),
                  Image.asset('assets/Minilogo dacky.png', width: 50, height: 50),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField('Nombre *', nombreController),
                      _buildDateField('Fecha de aplicación *', fechaAplicacionController),
                      _buildInputField('Edad *', edadController, number: true),
                      _buildDateField('Fecha de Vencimiento', fechaVencimientoController),

                      const SizedBox(height: 16),
                      const Text('Número de dosis *', style: TextStyle(fontFamily: 'Montserrat')),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                for (int i = 0; i < dosisSeleccionadas.length; i++) {
                                  dosisSeleccionadas[i] = i <= index;
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Image.asset(
                                dosisSeleccionadas[index]
                                    ? 'assets/comprobado.png'
                                    : 'assets/circulo.png',
                                width: 36,
                                height: 36,
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 16),

                      // SECCIÓN DE ARCHIVOS SIMPLIFICADA
                      const Text('Archivo adjunto (opcional)', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      // Mostrar archivo existente
                      if (widget.vacuna != null && tieneArchivoExistente && !archivoEliminado) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF9F2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    tipoArchivoExistente == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                                    color: const Color(0xFF11120D),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      nombreArchivoExistente ?? 'Archivo adjunto',
                                      style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildFileActionButton(
                                    icon: Icons.download,
                                    label: 'Descargar',
                                    onTap: _descargarYAbrirArchivo,
                                  ),
                                  _buildFileActionButton(
                                    icon: Icons.edit,
                                    label: 'Reemplazar',
                                    onTap: _seleccionarArchivo,
                                  ),
                                  _buildFileActionButton(
                                    icon: Icons.delete,
                                    label: 'Eliminar',
                                    onTap: _eliminarArchivoExistente,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Mostrar nuevo archivo seleccionado
                      if (archivoSeleccionado != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file, color: Colors.green, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  nombreArchivo ?? 'Archivo seleccionado',
                                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => setState(() {
                                  archivoSeleccionado = null;
                                  nombreArchivo = null;
                                }),
                              ),
                            ],
                          ),
                        ),
                      ] else if (!tieneArchivoExistente || archivoEliminado) ...[
                        GestureDetector(
                          onTap: _seleccionarArchivo,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF9F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/importar.png', width: 30, height: 30),
                                const SizedBox(width: 10),
                                const Text(
                                  'Seleccionar archivo',
                                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                      const Text('Nota', style: TextStyle(fontFamily: 'Montserrat')),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notaController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFFEF9F2),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF11120D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          ),
                          onPressed: _guardarVacuna,
                          child: const Text('Guardar', style: TextStyle(color: Colors.white, fontFamily: 'Montserrat')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFileActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color ?? const Color(0xFF11120D), size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: color ?? const Color(0xFF11120D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool number = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Montserrat')),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFEF9F2),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Montserrat')),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFEF9F2),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset('assets/calendario.png', width: 20, height: 20),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              locale: const Locale("es", "ES"),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    textTheme: const TextTheme(
                      bodyMedium: TextStyle(fontFamily: "Montserrat"),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(() {
                controller.text = "${pickedDate.toLocal()}".split(' ')[0];
              });
            }
          },
        ),
        const SizedBox(height: 16),
      ],
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