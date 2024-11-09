import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../modelo/modelos.dart';
import 'database_service.dart'; // Importar el servicio de base de datos

class AutenticacionService {
  static const String _keyUsuarioActual = 'usuarioActual';

  Future<void> registrarUsuario(Usuario usuario) async {
    // Registrar un nuevo usuario en la base de datos JSON
    await BaseDeDatos.agregarUsuario(usuario);
  }

  Future<Map<String, dynamic>?> iniciarSesion(
      String email, String password) async {
    final datos = await BaseDeDatos.leerBaseDeDatos();
    final usuarios = datos['usuarios'] as List;

    for (var usuario in usuarios) {
      if (usuario['email'] == email && usuario['contrasena'] == password) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyUsuarioActual, jsonEncode(usuario));
        return usuario;
      }
    }

    return null;
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsuarioActual);
  }

  Future<Map<String, dynamic>?> obtenerUsuarioActual() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUsuarioActual);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }
}
