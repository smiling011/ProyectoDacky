import 'package:flutter/material.dart';

class PetScreen1 extends StatefulWidget {
  @override
  _PetScreen1State createState() => _PetScreen1State();
}

class _PetScreen1State extends State<PetScreen1> {
  // Aquí va la lógica y la interfaz de usuario de tu pantalla de mascotas
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla de Mascotas'),
      ),
      body: Center(
        child: Text('Contenido de la pantalla de mascotas'),
      ),
    );
  }
}
