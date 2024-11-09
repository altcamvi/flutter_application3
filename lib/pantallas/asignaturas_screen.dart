import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelo/my_app_state.dart';
import '../modelo/modelos.dart';

class AsignaturasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final myAppState = context.watch<MyAppState>();
    final esProfesorOAdmin =
        myAppState.esAdministrador || myAppState.esProfesor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Asignaturas'),
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
            if (esProfesorOAdmin)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    _mostrarDialogoAgregarMateria(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                  child: Text(
                    'Añadir Materia',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: myAppState.materias.length,
                itemBuilder: (context, index) {
                  final materia = myAppState.materias[index];

                  return Center(
                    child: Container(
                      width: 450,
                      child: Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            materia.nombre,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Descripción: ${materia.descripcion}',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          trailing: esProfesorOAdmin
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        _mostrarDialogoEditarMateria(
                                            context, materia);
                                      },
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _confirmarEliminarMateria(
                                            context, materia);
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

  void _mostrarDialogoAgregarMateria(BuildContext context) {
    final nombreController = TextEditingController();
    final idController = TextEditingController();
    final descripcionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Añadir Materia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(idController, 'ID de la Materia'),
            SizedBox(height: 10),
            _buildTextField(nombreController, 'Nombre de la Materia'),
            SizedBox(height: 10),
            _buildTextField(descripcionController, 'Descripción de la Materia'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final myAppState = context.read<MyAppState>();
              final idMateria = idController.text;
              final nombreMateria = nombreController.text;
              final descripcionMateria = descripcionController.text;

              bool idDuplicado =
                  myAppState.materias.any((materia) => materia.id == idMateria);
              if (idDuplicado) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('El ID de la materia ya existe.')),
                );
                return;
              }

              final nuevaMateria = Materia(
                id: idMateria,
                nombre: nombreMateria,
                descripcion: descripcionMateria,
                notas: [],
              );

              myAppState.agregarMateria(nuevaMateria);
              Navigator.of(context).pop();
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

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _mostrarDialogoEditarMateria(BuildContext context, Materia materia) {
    final nombreController = TextEditingController(text: materia.nombre);
    final descripcionController =
        TextEditingController(text: materia.descripcion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Materia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nombreController, 'Nombre de la Materia'),
            SizedBox(height: 10),
            _buildTextField(descripcionController, 'Descripción de la Materia'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final myAppState = context.read<MyAppState>();
              final nombreMateria = nombreController.text;
              final descripcionMateria = descripcionController.text;

              final materiaModificada = Materia(
                id: materia.id,
                nombre: nombreMateria,
                descripcion: descripcionMateria,
                notas: materia.notas,
              );

              myAppState.modificarMateria(context, materiaModificada).then((_) {
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

  void _confirmarEliminarMateria(BuildContext context, Materia materia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Materia'),
        content: Text('¿Estás seguro de que quieres eliminar esta materia?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              final myAppState = context.read<MyAppState>();
              myAppState.eliminarMateria(context, materia.id);
              Navigator.of(context).pop();
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
}
