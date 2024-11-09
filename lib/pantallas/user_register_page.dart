import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelo/my_app_state.dart';

class UserRegisterPage extends StatefulWidget {
  @override
  _UserRegisterPageState createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final _idController = TextEditingController();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  String _rolSeleccionado = 'Estudiante'; // Valor inicial para el rol
  bool _cargando = false;

  // Definimos la lista de roles con el rol más largo como referencia
  final List<String> _roles = ['Estudiante', 'Profesor', 'Administrador'];

  @override
  Widget build(BuildContext context) {
    // Calcular el ancho necesario basado en el rol más largo
    final double dropdownWidth =
        _roles.map((rol) => rol.length).reduce((a, b) => a > b ? a : b) * 10.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Usuario'),
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 400, // Limitar el tamaño de la tarjeta
                  ),
                  child: Column(
                    children: [
                      _buildTextField(_idController, 'ID del Usuario'),
                      SizedBox(height: 16.0),
                      _buildTextField(_nombreController, 'Nombre'),
                      SizedBox(height: 16.0),
                      _buildTextField(_correoController, 'Correo'),
                      SizedBox(height: 16.0),
                      _buildTextField(_contrasenaController, 'Contraseña',
                          isPassword: true),
                      SizedBox(height: 16.0),
                      SizedBox(
                        width:
                            dropdownWidth + 50, // Ajustar el ancho del Dropdown
                        child: DropdownButtonFormField<String>(
                          value: _rolSeleccionado,
                          onChanged: (String? newValue) {
                            setState(() {
                              _rolSeleccionado = newValue!;
                            });
                          },
                          items: _roles.map((rol) {
                            return DropdownMenuItem<String>(
                              value: rol,
                              child: Text(rol),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Rol',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      _cargando
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _registrarUsuario,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Registrar',
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

  void _registrarUsuario() {
    setState(() {
      _cargando = true;
    });

    final myAppState = context.read<MyAppState>();
    final id = _idController.text;
    final nombre = _nombreController.text;
    final correo = _correoController.text;
    final contrasena = _contrasenaController.text;

    if (id.isEmpty || nombre.isEmpty || correo.isEmpty || contrasena.isEmpty) {
      setState(() {
        _cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    final existe = myAppState.usuarios.any((u) => u.email == correo);
    if (existe) {
      setState(() {
        _cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El correo ya está registrado')),
      );
      return;
    }

    myAppState.registrarUsuario(
      id,
      nombre,
      correo,
      contrasena,
      _rolSeleccionado,
    );

    _idController.clear();
    _nombreController.clear();
    _correoController.clear();
    _contrasenaController.clear();

    setState(() {
      _cargando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Usuario registrado correctamente')),
    );
  }
}
