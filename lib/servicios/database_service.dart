import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../modelo/modelos.dart'; // Importa los modelos de datos

class BaseDeDatos {
  // Ruta para obtener el archivo JSON dentro del proyecto
  static Future<String> _getFilePath() async {
    final directory = Directory.current.path;
    final filePath = path.join(directory, 'assets', 'datos_locales.json');
    print("Ruta del archivo JSON en el proyecto: $filePath");
    return filePath;
  }

  // Lee la base de datos del archivo JSON
  static Future<Map<String, dynamic>> leerBaseDeDatos() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);

      if (!await file.exists()) {
        print("El archivo JSON no existe. Creando archivo vacío...");
        await guardarBaseDeDatos({'usuarios': [], 'materias': []});
        return {'usuarios': [], 'materias': []};
      }

      String contenido = await file.readAsString();
      return jsonDecode(contenido);
    } catch (e) {
      print("Error al leer la base de datos: $e");
      return {'usuarios': [], 'materias': []};
    }
  }

  // Guarda los datos en el archivo JSON
  static Future<void> guardarBaseDeDatos(Map<String, dynamic> datos) async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);

      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      await file.writeAsString(jsonEncode(datos), flush: true);
      print("Datos guardados correctamente en el proyecto.");
    } catch (e) {
      print("Error al guardar los datos en el proyecto: $e");
    }
  }

  // Función para inicializar datos predeterminados en la base de datos
  static Future<void> inicializarBaseDeDatos() async {
    try {
      final datos = await leerBaseDeDatos();
      if (datos.isEmpty || (datos['usuarios'] as List).isEmpty) {
        print("Inicializando datos predeterminados...");

        // Agregando usuarios predeterminados
        datos['usuarios'] = [
          {
            'id': '1',
            'nombre': 'Administrador',
            'tipo': 'administrador',
            'email': 'admin@admin.com',
            'contrasena': 'admin123',
          },
          {
            'id': '2',
            'nombre': 'Profesor Prueba',
            'tipo': 'profesor',
            'email': 'profesor.prueba@casgrades.com',
            'contrasena': 'profesor123',
          },
          {
            'id': '3',
            'nombre': 'Estudiante Prueba',
            'tipo': 'estudiante',
            'email': 'estudiante.prueba@casgrades.com',
            'contrasena': 'estudiante123',
          }
        ];

        // Agregando materias predeterminadas
        datos['materias'] = [
          {
            'id': '1',
            'nombre': 'Matemáticas',
            'descripcion': 'Curso básico de matemáticas',
            'notas': [
              {'idEstudiante': '3', 'calificacion': 3.0},
              {'idEstudiante': '3', 'calificacion': 4.0},
            ]
          },
          {
            'id': '2',
            'nombre': 'Ciencias',
            'descripcion': 'Curso básico de ciencias',
            'notas': [
              {'idEstudiante': '3', 'calificacion': 4.5}
            ]
          }
        ];

        await guardarBaseDeDatos(datos);
        print("Datos predeterminados inicializados.");
      } else {
        print("Datos ya existentes.");
      }
    } catch (e) {
      print("Error al inicializar la base de datos: $e");
    }
  }

  // Funciones CRUD para Usuarios
  static Future<void> agregarUsuario(Usuario usuario) async {
    final datos = await leerBaseDeDatos();
    final usuarios = datos['usuarios'] as List? ?? [];
    usuarios.add(usuario.toJson());
    datos['usuarios'] = usuarios;
    await guardarBaseDeDatos(datos);
  }

  static Future<void> eliminarUsuario(String id) async {
    final datos = await leerBaseDeDatos();
    final usuarios = datos['usuarios'] as List? ?? [];
    datos['usuarios'] = usuarios.where((user) => user['id'] != id).toList();
    await guardarBaseDeDatos(datos);
  }

  static Future<void> modificarUsuario(Usuario usuario) async {
    final datos = await leerBaseDeDatos();
    final usuarios = datos['usuarios'] as List? ?? [];
    final index = usuarios.indexWhere((user) => user['id'] == usuario.id);
    if (index != -1) {
      usuarios[index] = usuario.toJson();
      datos['usuarios'] = usuarios;
      await guardarBaseDeDatos(datos);
    }
  }

  // Funciones CRUD para Materias
  static Future<void> agregarMateria(Materia materia) async {
    final datos = await leerBaseDeDatos();
    final materias = datos['materias'] as List? ?? [];
    materias.add(materia.toJson());
    datos['materias'] = materias;
    await guardarBaseDeDatos(datos);
  }

  static Future<void> eliminarMateria(String id) async {
    final datos = await leerBaseDeDatos();
    final materias = datos['materias'] as List? ?? [];
    datos['materias'] =
        materias.where((materia) => materia['id'] != id).toList();
    await guardarBaseDeDatos(datos);
  }

  static Future<void> modificarMateria(Materia materia) async {
    final datos = await leerBaseDeDatos();
    final materias = datos['materias'] as List? ?? [];
    final index = materias.indexWhere((m) => m['id'] == materia.id);
    if (index != -1) {
      materias[index] = materia.toJson();
      datos['materias'] = materias;
      await guardarBaseDeDatos(datos);
    }
  }

  // Funciones para Notas
  static Future<void> agregarNota(String idMateria, Nota nota) async {
    final datos = await leerBaseDeDatos();
    final materias = datos['materias'] as List? ?? [];

    final index = materias.indexWhere((materia) => materia['id'] == idMateria);
    if (index != -1) {
      final materia = Materia.fromJson(materias[index]);
      materia.notas.add(nota);

      // Guardar la lista actualizada de notas en la materia
      materias[index] = materia.toJson();
      datos['materias'] = materias;
      await guardarBaseDeDatos(datos);
      print("Nota agregada correctamente.");
    } else {
      print("Error: Materia no encontrada para agregar la nota.");
    }
  }

  // Método para eliminar una nota específica en la base de datos
  static Future<void> eliminarNota(
      String idMateria, String idEstudiante) async {
    final datos = await leerBaseDeDatos();
    final materias = datos['materias'] as List;

    // Buscar la materia correspondiente
    final indexMateria = materias.indexWhere((m) => m['id'] == idMateria);
    if (indexMateria != -1) {
      final materia = materias[indexMateria];
      final notas = materia['notas'] as List;

      // Eliminar la nota correspondiente
      materia['notas'] =
          notas.where((n) => n['idEstudiante'] != idEstudiante).toList();
      await guardarBaseDeDatos(datos);
    } else {
      print("Error: Materia no encontrada para eliminar la nota.");
    }
  }

  // Función para actualizar una nota existente de un estudiante en una materia específica
  static Future<void> actualizarNota(
      String idMateria, String idEstudiante, double nuevaCalificacion) async {
    final datos = await leerBaseDeDatos();
    final materias = datos['materias'] as List? ?? [];

    // Buscar la materia por ID
    final index = materias.indexWhere((materia) => materia['id'] == idMateria);
    if (index != -1) {
      final materia = Materia.fromJson(materias[index]);

      // Buscar la nota del estudiante y actualizar su calificación
      final notaIndex =
          materia.notas.indexWhere((nota) => nota.idEstudiante == idEstudiante);
      if (notaIndex != -1) {
        // Actualizar el valor de la nota
        materia.notas[notaIndex].valor = nuevaCalificacion;

        // Guardar los cambios en la lista de materias
        materias[index] = materia.toJson();
        datos['materias'] = materias;

        // Guardar los datos actualizados en el archivo JSON
        await guardarBaseDeDatos(datos);
        print("Nota actualizada correctamente.");
      } else {
        print(
            "Nota no encontrada para el estudiante $idEstudiante en la materia $idMateria");
      }
    } else {
      print("Materia no encontrada.");
    }
  }
}
