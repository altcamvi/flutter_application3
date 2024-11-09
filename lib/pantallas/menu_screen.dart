import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../servicios/autenticacion.dart';
import 'asignaturas_screen.dart';
import 'average_screen.dart';
import 'notas_screen.dart';
import 'usuarios_screen.dart';
import 'user_register_page.dart';
import '../modelo/my_app_state.dart';

class MenuScreen extends StatelessWidget {
  final AutenticacionService _authService = AutenticacionService();

  @override
  Widget build(BuildContext context) {
    final myAppState = context.watch<MyAppState>();
    final usuarioActual = myAppState.usuarioActual;
    final esProfesorOAdmin =
        myAppState.esAdministrador || myAppState.esProfesor;
    final esEstudiante = usuarioActual?['rol'] == 'estudiante';

    return Scaffold(
      appBar: AppBar(
        title: Text('Menú Principal'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.cerrarSesion();
              Navigator.pushReplacementNamed(context, '/');
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bienvenido ${usuarioActual?['nombre']}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 20),
                // Distinción por rol usando las propiedades de MyAppState
                if (myAppState.esAdministrador) ...[
                  _mostrarOpcionesAdministrador(context),
                ] else if (esProfesorOAdmin) ...[
                  _mostrarOpcionesProfesor(context),
                ] else if (esEstudiante) ...[
                  _mostrarOpcionesEstudiante(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Funciones para cada rol
  Widget _mostrarOpcionesAdministrador(BuildContext context) {
    return _crearOpciones(
      context,
      [
        _crearOpcion(context, 'Gestionar Asignaturas', Icons.book, () {
          _gestionarAsignaturas(context);
        }),
        _crearOpcion(context, 'Gestionar Notas', Icons.grade, () {
          _gestionarNotas(context);
        }),
        _crearOpcion(context, 'Registrar Usuario', Icons.person_add, () {
          _registrarUsuario(context);
        }),
        _crearOpcion(context, 'Gestionar Usuarios', Icons.group, () {
          _gestionarUsuarios(context);
        }),
      ],
    );
  }

  Widget _mostrarOpcionesProfesor(BuildContext context) {
    return _crearOpciones(
      context,
      [
        _crearOpcion(context, 'Gestionar Asignaturas', Icons.book, () {
          _gestionarAsignaturas(context);
        }),
        _crearOpcion(context, 'Gestionar Notas', Icons.grade, () {
          _gestionarNotas(context);
        }),
      ],
    );
  }

  Widget _mostrarOpcionesEstudiante(BuildContext context) {
    return _crearOpciones(
      context,
      [
        _crearOpcion(context, 'Ver Asignaturas', Icons.book_outlined, () {
          _gestionarAsignaturas(context);
        }),
        _crearOpcion(context, 'Calcular Promedio', Icons.calculate, () {
          _calcularPromedio(context);
        }),
      ],
    );
  }

  // Método para crear opciones de manera centralizada y limitando el ancho
  Widget _crearOpciones(BuildContext context, List<Widget> opciones) {
    return Container(
      width: 300, // Limita el ancho del menú
      child: Column(
        children: opciones,
      ),
    );
  }

  // Método para crear opciones con Card y estilo
  Widget _crearOpcion(
      BuildContext context, String titulo, IconData icono, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icono, color: Colors.blueAccent),
          title: Text(
            titulo,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  // Métodos para navegar a cada pantalla
  void _gestionarAsignaturas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsignaturasScreen(),
      ),
    );
  }

  void _gestionarNotas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotasScreen(),
      ),
    );
  }

  void _gestionarUsuarios(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsuariosScreen(),
      ),
    );
  }

  void _registrarUsuario(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserRegisterPage(),
      ),
    );
  }

  void _calcularPromedio(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AverageScreen(),
      ),
    );
  }
}
