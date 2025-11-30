import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'gps_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController repetirController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();
  
  bool _isLoading = false;
  String? _codigoEnviado; // Guardar código para verificar
  bool _mostrarVerificacion = false; // Mostrar pantalla de código

  // 🆕 Validar formato de correo electrónico
  bool _esEmailValido(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    // Lista de dominios temporales/falsos comunes
    final dominiosProhibidos = [
      'tempmail.com',
      'guerrillamail.com',
      'mailinator.com',
      '10minutemail.com',
      'throwaway.email',
      'fakeinbox.com',
      'yopmail.com',
      'maildrop.cc',
    ];

    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    final dominio = email.split('@').last.toLowerCase();
    if (dominiosProhibidos.contains(dominio)) {
      return false;
    }

    return true;
  }

  // 🆕 Validar contraseña segura
  bool _esContrasenaSegura(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  void _mostrarAlerta(String mensaje) {
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
                  Image.asset("assets/advertencia.png", width: 50, height: 50),
                  const SizedBox(height: 15),
                  Text(
                    mensaje,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF11120D),
                      fontFamily: 'Montserrat',
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

  // 🆕 Validaciones mejoradas
  bool _validarCampos() {
    if (correoController.text.trim().isEmpty ||
        nombreController.text.trim().isEmpty ||
        apellidoController.text.trim().isEmpty ||
        contrasenaController.text.isEmpty ||
        repetirController.text.isEmpty) {
      _mostrarAlerta("Todos los campos son obligatorios");
      return false;
    }

    // Validar formato de email
    if (!_esEmailValido(correoController.text.trim())) {
      _mostrarAlerta("Por favor, ingresa un correo electrónico válido y no uses correos temporales");
      return false;
    }

    // Validar contraseña segura
    if (!_esContrasenaSegura(contrasenaController.text)) {
      _mostrarAlerta("La contraseña debe tener al menos:\n• 8 caracteres\n• 1 mayúscula\n• 1 número");
      return false;
    }

    if (contrasenaController.text != repetirController.text) {
      _mostrarAlerta("Las contraseñas no coinciden");
      return false;
    }

    return true;
  }

  // 🆕 Generar código de 6 dígitos
  String _generarCodigo() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // 🆕 Enviar código de verificación por correo
  Future<void> _enviarCodigoVerificacion() async {
    if (!_validarCampos()) return;

    setState(() => _isLoading = true);

    try {
      // Generar código
      _codigoEnviado = _generarCodigo();

      // Enviar código al backend para que lo envíe por correo
      final response = await http.post(
        Uri.parse('https://proyectodackybackend.onrender.com/auth/enviar-codigo'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": correoController.text.trim(),
          "codigo": _codigoEnviado,
          "nombre": nombreController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _mostrarVerificacion = true;
          _isLoading = false;
        });
        _mostrarAlerta("Código de verificación enviado a ${correoController.text.trim()}");
      } else {
        setState(() => _isLoading = false);
        _mostrarAlerta("Error al enviar el código. Intenta de nuevo.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarAlerta("Error de conexión: $e");
    }
  }

  // 🆕 Verificar código y registrar
  Future<void> _verificarYRegistrar() async {
    if (codigoController.text.trim() != _codigoEnviado) {
      _mostrarAlerta("Código incorrecto. Verifica e intenta de nuevo.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://proyectodackybackend.onrender.com/auth/registro'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Nom": nombreController.text.trim(),
          "Apell": apellidoController.text.trim(),
          "Email": correoController.text.trim(),
          "Contrasena": contrasenaController.text.trim(),
          "NumCel": null,
          "NumTelf": null,
          "Direccion": null
        }),
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', data['email']);
        await prefs.setInt('id', data['id']);
        await prefs.setString('token', data['token']);
        await prefs.setString('lastLoginTime', DateTime.now().toIso8601String());

        _mostrarAlerta("✅ ${data['message'] ?? 'Registro exitoso'}");

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GpsScreen()),
          );
        }
      } else {
        _mostrarAlerta(data['message'] ?? 'Error al registrarse');
      }
    } catch (e) {
      _mostrarAlerta("Error de conexión: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🆕 Registrarse con Google
  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        // Registrar en backend
        await _registrarEnBackend(
          email: user.email!,
          nombre: user.displayName?.split(' ').first ?? 'Usuario',
          apellido: user.displayName?.split(' ').last ?? '',
          uid: user.uid,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', user.email!);
        await prefs.setString('uid', user.uid);
        await prefs.setString('nombre', user.displayName ?? '');
        await prefs.setString('token', 'google_auth_${user.uid}');
        await prefs.setString('lastLoginTime', DateTime.now().toIso8601String());

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GpsScreen()),
          );
        }
      }
    } catch (e) {
      print('Error al registrarse con Google: $e');
      _mostrarAlerta('Error al registrarse con Google. Inténtalo de nuevo.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _registrarEnBackend({
    required String email,
    required String nombre,
    required String apellido,
    required String uid,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://proyectodackybackend.onrender.com/auth/registro-google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'nombre': nombre,
          'apellido': apellido,
          'uid': uid,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id', data['id']);
      }
    } catch (e) {
      print('Error al registrar en backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11120D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11120D),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/atras_blanco.png', width: 24, height: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Encabezado con logo y título
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'REGISTRO',
                      style: TextStyle(
                        color: Color(0xFFFFFBF4),
                        fontSize: 24,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/Minilogo dacky.png',
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
              ),

              // Formulario
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF565449),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: _mostrarVerificacion 
                    ? _buildVerificacionForm() 
                    : _buildRegistroForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🆕 Formulario de verificación de código
  Widget _buildVerificacionForm() {
    return Column(
      children: [
        const Icon(Icons.email_outlined, size: 60, color: Color(0xFFFFFBF4)),
        const SizedBox(height: 20),
        const Text(
          'Verifica tu correo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFBF4),
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Ingresa el código de 6 dígitos que enviamos a ${correoController.text.trim()}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFD8CFBC),
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 30),
        
        // Campo código
        TextField(
          controller: codigoController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            letterSpacing: 10,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: const TextStyle(color: Color(0xFFD8CFBC)),
            filled: true,
            fillColor: const Color(0xFFFFFBF4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        
        // Botón verificar
        ElevatedButton(
          onPressed: _isLoading ? null : _verificarYRegistrar,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF11120D),
            foregroundColor: const Color(0xFFFFFBF4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFFBF4),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Verificar y Registrarse',
                    style: TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
                  ),
          ),
        ),
        const SizedBox(height: 15),
        
        // Botón reenviar código
        TextButton(
          onPressed: () {
            setState(() {
              _mostrarVerificacion = false;
              codigoController.clear();
            });
          },
          child: const Text(
            '¿No recibiste el código? Volver',
            style: TextStyle(
              color: Color(0xFFD8CFBC),
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
    );
  }

  // Formulario principal de registro
  Widget _buildRegistroForm() {
    return Column(
      children: [
        _buildTextField('Correo', false, correoController),
        const SizedBox(height: 15),
        _buildTextField('Nombre', false, nombreController),
        const SizedBox(height: 15),
        _buildTextField('Apellido', false, apellidoController),
        const SizedBox(height: 15),
        _buildTextField('Contraseña', true, contrasenaController),
        const SizedBox(height: 15),
        _buildTextField('Repita Contraseña', true, repetirController),
        const SizedBox(height: 20),

        // Botón registrarse tradicional
        ElevatedButton(
          onPressed: _isLoading ? null : _enviarCodigoVerificacion,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF11120D),
            foregroundColor: const Color(0xFFFFFBF4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFFBF4),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Registrarse',
                    style: TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
                  ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Divisor
        Row(
          children: const [
            Expanded(child: Divider(color: Color(0xFFD8CFBC), thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'O',
                style: TextStyle(
                  color: Color(0xFFFFFBF4),
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            Expanded(child: Divider(color: Color(0xFFD8CFBC), thickness: 1)),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 🆕 Botón de Google
        GestureDetector(
          onTap: _isLoading ? null : _signUpWithGoogle,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/google.png', width: 24, height: 24),
                const SizedBox(width: 12),
                const Text(
                  'Continuar con Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF11120D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String hintText, bool isPassword, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: hintText == 'Correo' ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
            color: Color(0xFFD8CFBC), fontFamily: 'Montserrat'),
        filled: true,
        fillColor: const Color(0xFFFFFBF4), // Dacky-4
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
