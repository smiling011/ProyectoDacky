import 'package:flutter/material.dart';

class UserScreen1 extends StatefulWidget {
  @override
  _UserScreen1State createState() => _UserScreen1State();
}

class _UserScreen1State extends State<UserScreen1> {
  // Aquí va la lógica y la interfaz de usuario de tu pantalla de usuario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla de Usuario'),
      ),
      body: Center(
        child: Text('Contenido de la pantalla de usuario'),
      ),
    );
  }
}
