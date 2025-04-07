import 'package:flutter/material.dart';
import 'vacuna_screen5.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class VacunaScreen3 extends StatelessWidget {
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
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.pets, color: Colors.black),
          ),
        ],
      ),
      body: Center(
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VacunaScreen5()),
            );
          },
          backgroundColor: Colors.black,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFEAEAEA),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.location_on), label: ''),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.vaccines), label: ''),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.pets), label: ''),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: ''),
        ],
      ),
    );
  }
}
