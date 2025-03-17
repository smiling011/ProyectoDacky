import 'package:flutter/material.dart';
import 'vacuna_screen3.dart';

class VacunaScreen2 extends StatelessWidget {
  final List<Map<String, String>> mascotas = [
    {'nombre': 'Mascota 1', 'imagen': 'assets/husky.jpg'},
    {'nombre': 'Mascota 2', 'imagen': 'assets/gato.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFBF4),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFBF4),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tarjeta de Vacunas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: mascotas.map((mascota) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VacunaScreen3(),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFD8CFBC),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          mascota['imagen']!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        mascota['nombre']!,
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            backgroundColor: Colors.black,
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Acción para agregar una nueva mascota en el futuro
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[200],
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.location_on), onPressed: () {}),
            IconButton(icon: Icon(Icons.vaccines), onPressed: () {}),
            IconButton(icon: Icon(Icons.pets), onPressed: () {}),
            IconButton(icon: Icon(Icons.person), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
