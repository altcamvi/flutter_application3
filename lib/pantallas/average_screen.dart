import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelo/my_app_state.dart';

class AverageScreen extends StatefulWidget {
  @override
  _AverageScreenState createState() => _AverageScreenState();
}

class _AverageScreenState extends State<AverageScreen> {
  String? asignaturaSeleccionada;
  List<TextEditingController> notasControllers = [];
  bool incluirNotasExistentes = true;
  bool modoIndependiente = false;

  @override
  void dispose() {
    for (var controller in notasControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double calcularPromedio(
      String idMateria, MyAppState myAppState, List<double> notasManuales) {
    final notasMateria = incluirNotasExistentes
        ? myAppState.notas.where((nota) => nota.idMateria == idMateria).toList()
        : [];

    final valoresNotasGuardadas = notasMateria.map((n) => n.valor).toList();
    final todasLasNotas = [...valoresNotasGuardadas, ...notasManuales];

    if (todasLasNotas.isEmpty) return 0.0;

    final suma = todasLasNotas.reduce((a, b) => a + b);
    return suma / todasLasNotas.length;
  }

  double calcularPromedioIndependiente(List<double> notasManuales) {
    if (notasManuales.isEmpty) return 0.0;
    final suma = notasManuales.reduce((a, b) => a + b);
    return suma / notasManuales.length;
  }

  void _agregarNuevaNota() {
    setState(() {
      notasControllers.add(TextEditingController());
    });
  }

  void _eliminarNota(int index) {
    setState(() {
      notasControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final myAppState = context.watch<MyAppState>();
    final asignaturas =
        myAppState.materias.map((materia) => materia.nombre).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Calcular Promedio'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(modoIndependiente ? Icons.school : Icons.edit),
            onPressed: () {
              setState(() {
                modoIndependiente = !modoIndependiente;
              });
            },
            tooltip:
                modoIndependiente ? 'Modo Asignatura' : 'Modo Independiente',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: modoIndependiente
                ? _construirModoIndependiente()
                : _construirModoAsignatura(asignaturas, myAppState),
          ),
        ),
      ),
    );
  }

  Widget _construirModoAsignatura(
      List<String> asignaturas, MyAppState myAppState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDropdown(asignaturas),
        SizedBox(height: 20),
        if (asignaturaSeleccionada != null)
          Expanded(
            child: _buildListViewNotas(myAppState),
          ),
        SizedBox(height: 20),
        _buildCalcularButton('Calcular Promedio'),
      ],
    );
  }

  Widget _construirModoIndependiente() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: notasControllers.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Center(
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: _buildTextField(
                        notasControllers[index],
                        'Nota',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarNota(index),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _agregarNuevaNota,
          child: Text('Añadir Otra Nota'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
          ),
        ),
        SizedBox(height: 20),
        _buildCalcularButton('Calcular Promedio Independiente'),
      ],
    );
  }

  Widget _buildDropdown(List<String> asignaturas) {
    return DropdownButton<String>(
      value: asignaturaSeleccionada,
      hint: Text('Selecciona una Asignatura'),
      onChanged: (nuevaAsignatura) {
        setState(() {
          asignaturaSeleccionada = nuevaAsignatura;
        });
      },
      items: asignaturas.map<DropdownMenuItem<String>>((String asignatura) {
        return DropdownMenuItem<String>(
          value: asignatura,
          child: Text(asignatura),
        );
      }).toList(),
    );
  }

  Widget _buildListViewNotas(MyAppState myAppState) {
    final notasMateria = myAppState.notas
        .where((nota) =>
            nota.idMateria ==
            myAppState.materias
                .firstWhere(
                    (materia) => materia.nombre == asignaturaSeleccionada)
                .id)
        .toList();

    return notasMateria.isEmpty
        ? Center(
            child: Text(
              'No hay notas registradas para esta asignatura.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          )
        : ListView.builder(
            itemCount: notasMateria.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final nota = notasMateria[index];
              return Center(
                child: Container(
                  width: 200,
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        'Nota: ${nota.valor.toString()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildCalcularButton(String texto) {
    return ElevatedButton(
      onPressed: () {
        if (modoIndependiente) {
          List<double> notasManuales = [];
          for (var controller in notasControllers) {
            final nota = double.tryParse(controller.text.trim()) ?? 0.0;
            notasManuales.add(nota);
          }

          final promedioIndependiente =
              calcularPromedioIndependiente(notasManuales);

          _mostrarResultado(
              context, 'Promedio Independiente', promedioIndependiente);
        } else {
          if (asignaturaSeleccionada != null) {
            final myAppState = context.read<MyAppState>();
            final materiaSeleccionada = myAppState.materias.firstWhere(
                (materia) => materia.nombre == asignaturaSeleccionada);
            final promedio =
                calcularPromedio(materiaSeleccionada.id, myAppState, []);

            _mostrarResultado(
                context, 'Promedio de ${asignaturaSeleccionada!}', promedio);
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  void _mostrarResultado(BuildContext context, String titulo, double promedio) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text('El promedio es: $promedio'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
