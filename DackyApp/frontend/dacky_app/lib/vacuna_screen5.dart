import 'package:flutter/material.dart';
import 'vacuna_screen1.dart';
import 'gps_screen.dart';
import 'pet_screen1.dart';
import 'user_screen1.dart';

class VacunaScreen5 extends StatefulWidget {
  @override
  _VacunaScreen5State createState() => _VacunaScreen5State();
}

class _VacunaScreen5State extends State<VacunaScreen5> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController fechaAplicacionController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController fechaVencimientoController = TextEditingController();
  final TextEditingController notaController = TextEditingController();

  List<bool> dosisSeleccionadas = List.generate(5, (_) => false);

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
                    child: Image.asset('assets/atras.png', width: 28, height: 28),
                  ),
                  const Text(
                    'Vacuna',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      _buildInputField('Nombre', nombreController),
                      _buildDateField('Fecha de aplicacion', fechaAplicacionController),
                      _buildInputField('Edad', edadController),
                      _buildDateField('Fecha de Vencimiento', fechaVencimientoController),
                      const SizedBox(height: 16),
                      const Text('Numero de dosis'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                dosisSeleccionadas[index] = !dosisSeleccionadas[index];
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
                      const Text('Nota'),
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
                          onPressed: () {
                            // Acción de guardar
                          },
                          child: const Text('Guardar', style: TextStyle(color: Colors.white)),
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

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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
        Text(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFEF9F2),
            suffixIcon: Padding(
              padding: EdgeInsets.all(10),
              child: Image.asset(
                'assets/mi_calendario.png', // Asegúrate que esta imagen exista en tu carpeta assets
                width: 20,
                height: 20,
              ),
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

  // Barra de navegación inferior
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
                  MaterialPageRoute(builder: (context) => GpsScreen()));
            },
            child: Image.asset('assets/gps_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VacunaScreen1()));
            },
            child: Image.asset('assets/vacuna_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PetScreen1()));
            },
            child: Image.asset('assets/huella_icon.png', width: 30, height: 30),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserScreen1()));
            },
            child: Image.asset('assets/user_icon.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}
