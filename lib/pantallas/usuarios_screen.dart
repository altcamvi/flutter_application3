import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelo/my_app_state.dart';
import '../modelo/modelos.dart';
import 'user_register_page.dart';

class UsuariosScreen extends StatefulWidget {
  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  @override
  Widget build(BuildContext context) {
    final myAppState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Usuarios'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserRegisterPage(),
                ),
              );
            },
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600, // Limitar el ancho de la lista de usuarios
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: myAppState.usuarios.isEmpty
                  ? Center(
                      child: Text(
                        'No hay usuarios registrados',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: myAppState.usuarios.length,
                      itemBuilder: (context, index) {
                        final usuario = myAppState.usuarios[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Card(
                            color: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                usuario.nombre,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Correo: ${usuario.email}'),
                                  Text('ID: ${usuario.id}'),
                                  Text('Rol: ${usuario.tipo}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      _mostrarDialogoEditarUsuario(
                                          context, usuario, myAppState);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _confirmarEliminarUsuario(
                                          context, usuario, myAppState);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoEditarUsuario(
      BuildContext context, Usuario usuario, MyAppState myAppState) {
    final nombreController = TextEditingController(text: usuario.nombre);
    final emailController = TextEditingController(text: usuario.email);
    final contrasenaController =
        TextEditingController(text: usuario.contrasena);
    String rolSeleccionado = usuario.tipo;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nombreController, 'Nombre'),
            SizedBox(height: 10),
            _buildTextField(emailController, 'Correo'),
            SizedBox(height: 10),
            _buildTextField(contrasenaController, 'Contraseña',
                isPassword: true),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: rolSeleccionado,
              onChanged: (String? nuevoRol) {
                setState(() {
                  rolSeleccionado = nuevoRol!;
                });
              },
              items: ['administrador', 'profesor', 'estudiante']
                  .map((rol) => DropdownMenuItem(
                        value: rol,
                        child: Text(rol),
                      ))
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Rol',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final nuevoUsuario = Usuario(
                id: usuario.id,
                nombre: nombreController.text,
                email: emailController.text,
                contrasena: contrasenaController.text,
                tipo: rolSeleccionado,
              );

              myAppState.modificarUsuario(nuevoUsuario);

              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
            child: Text('Guardar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarUsuario(
      BuildContext context, Usuario usuario, MyAppState myAppState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Usuario'),
        content: Text('¿Estás seguro de que quieres eliminar este usuario?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              myAppState.eliminarUsuario(usuario.id).then((_) {
                Navigator.of(context).pop();
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Eliminar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      obscureText: isPassword,
    );
  }
}
