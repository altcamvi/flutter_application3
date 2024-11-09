import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelo/my_app_state.dart';
import '../pantallas/menu_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _esContrasenaVisible = false;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    // Cargar usuarios desde la base de datos JSON
    context.read<MyAppState>().cargarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
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
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400, // Limitar el ancho del formulario
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CASGRADES',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 32.0),
                    _buildTextField(_correoController, 'Correo', false),
                    SizedBox(height: 16.0),
                    _buildTextField(
                      _contrasenaController,
                      'Contraseña',
                      !_esContrasenaVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _esContrasenaVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _esContrasenaVisible = !_esContrasenaVisible;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    _cargando
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              _iniciarSesion(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, bool obscureText,
      {Widget? suffixIcon}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  void _iniciarSesion(BuildContext context) async {
    final correo = _correoController.text;
    final contrasena = _contrasenaController.text;

    setState(() {
      _cargando = true;
    });

    final myAppState = context.read<MyAppState>();
    final usuario = myAppState.verificarCredenciales(correo, contrasena);

    if (usuario != null) {
      myAppState.usuarioActual = {
        'nombre': usuario.nombre,
        'rol': usuario.tipo,
        'id': usuario.id,
      };
      _navegarAlMenu(context);
    } else {
      setState(() {
        _cargando = false;
      });
      _mostrarError(context);
    }
  }

  void _navegarAlMenu(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MenuScreen(),
      ),
    );
  }

  void _mostrarError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Correo o contraseña incorrectos.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
