import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelo/my_app_state.dart';
import '../modelo/modelos.dart';

class NotasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final myAppState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Notas'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            if (myAppState.esAdministrador || myAppState.esProfesor)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _mostrarDialogoAgregarNota(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  child: Text(
                    'Añadir Nota',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: myAppState.notas.length,
                itemBuilder: (context, index) {
                  final nota = myAppState.notas[index];
                  final estudiante = myAppState.usuarios.firstWhere(
                    (u) => u.id == nota.idEstudiante,
                    orElse: () => Usuario(
                      id: '',
                      nombre: 'Desconocido',
                      email: '',
                      contrasena: '',
                      tipo: '',
                    ),
                  );
                  final materia = myAppState.materias.firstWhere(
                    (m) => m.id == nota.idMateria,
                    orElse: () => Materia(
                      id: '',
                      nombre: 'Desconocido',
                      descripcion: '',
                      notas: [],
                    ),
                  );

                  return Center(
                    child: Container(
                      width: 450, // Limitar el ancho de las tarjetas
                      child: Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            'Estudiante: ${estudiante.nombre}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Materia: ${materia.nombre}\nNota: ${nota.valor.toString()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          trailing: myAppState.esAdministrador ||
                                  myAppState.esProfesor
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        _mostrarDialogoEditarNota(
                                            context, nota);
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _confirmarEliminarNota(context, nota);
                                      },
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarNota(BuildContext context) {
    final idEstudianteController = TextEditingController();
    final idMateriaController = TextEditingController();
    final valorNotaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Añadir Nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(idEstudianteController, 'ID del Estudiante'),
            SizedBox(height: 10),
            _buildTextField(idMateriaController, 'ID de la Materia'),
            SizedBox(height: 10),
            _buildTextField(
              valorNotaController,
              'Valor de la Nota',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final idEstudiante = idEstudianteController.text;
              final idMateria = idMateriaController.text;
              final valorNota =
                  double.tryParse(valorNotaController.text) ?? 0.0;

              final myAppState = context.read<MyAppState>();
              myAppState
                  .agregarNota(context, idEstudiante, idMateria, valorNota)
                  .then((_) {
                Navigator.of(context).pop();
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              });
            },
            child: Text('Guardar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditarNota(BuildContext context, Nota nota) {
    final valorNotaController =
        TextEditingController(text: nota.valor.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              valorNotaController,
              'Nuevo Valor de la Nota',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final nuevoValor =
                  double.tryParse(valorNotaController.text) ?? 0.0;

              final myAppState = context.read<MyAppState>();
              myAppState.actualizarNota(nota, nuevoValor).then((_) {
                Navigator.of(context).pop();
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              });
            },
            child: Text('Guardar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarNota(BuildContext context, Nota nota) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Nota'),
        content: Text('¿Estás seguro de que quieres eliminar esta nota?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              final myAppState = context.read<MyAppState>();
              myAppState.eliminarNota(context, nota).then((_) {
                Navigator.of(context).pop();
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              });
            },
            child: Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      keyboardType: keyboardType,
    );
  }
}
