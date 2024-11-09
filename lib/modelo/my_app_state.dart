import 'package:flutter/material.dart';
import '../servicios/database_service.dart';
import '../modelo/modelos.dart'; // Importa tus modelos

class MyAppState extends ChangeNotifier {
  Map<String, dynamic>? usuarioActual;
  List<Materia> materias = [];
  List<Nota> notas = [];
  List<Usuario> usuarios = [];

  MyAppState() {
    // Cargar los datos al inicializar
    cargarDatosIniciales();
  }

  // Cargar todos los datos al iniciar la aplicación
  Future<void> cargarDatosIniciales() async {
    await cargarUsuarios();
    await cargarMaterias();
    await cargarNotas(); // Método para cargar notas
  }

  // Método para cargar usuarios desde la base de datos JSON
  Future<void> cargarUsuarios() async {
    final datos = await BaseDeDatos.leerBaseDeDatos();
    final listaUsuarios = datos['usuarios'] as List;
    usuarios = listaUsuarios.map((data) => Usuario.fromJson(data)).toList();
    notifyListeners();
  }

  // Método para cargar materias desde la base de datos JSON
  Future<void> cargarMaterias() async {
    final datos = await BaseDeDatos.leerBaseDeDatos();
    final listaMaterias = datos['materias'] as List;
    materias = listaMaterias.map((data) => Materia.fromJson(data)).toList();
    notifyListeners();
  }

  // Método para cargar notas desde la base de datos JSON
  Future<void> cargarNotas() async {
    final datos = await BaseDeDatos.leerBaseDeDatos();
    final listaNotas = datos['notas'] as List;
    notas = listaNotas.map((data) => Nota.fromJson(data)).toList();
    notifyListeners();
  }

  // Método para verificar si el usuario actual es administrador
  bool get esAdministrador {
    return usuarioActual != null && usuarioActual!['rol'] == 'administrador';
  }

  // Método para verificar si el usuario actual es profesor
  bool get esProfesor {
    return usuarioActual != null && usuarioActual!['rol'] == 'profesor';
  }

  // Método para registrar un usuario
  void registrarUsuario(
    String id,
    String nombre,
    String correo,
    String contrasena,
    String rol,
  ) async {
    final nuevoUsuario = Usuario(
      id: id,
      nombre: nombre,
      email: correo,
      contrasena: contrasena,
      tipo: rol,
    );
    await BaseDeDatos.agregarUsuario(nuevoUsuario);
    usuarios.add(nuevoUsuario);
    notifyListeners();
  }

  // Método para verificar el inicio de sesión
  Usuario? verificarCredenciales(String correo, String contrasena) {
    for (var usuario in usuarios) {
      if (usuario.email == correo && usuario.contrasena == contrasena) {
        return usuario;
      }
    }
    return null;
  }

  // Método para añadir una materia
  Future<void> agregarMateria(Materia nuevaMateria) async {
    await BaseDeDatos.agregarMateria(nuevaMateria);
    materias.add(nuevaMateria);
    notifyListeners();
  }

  // Método para añadir una nota en MyAppState con verificación de ID y rol de estudiante
  Future<void> agregarNota(BuildContext context, String idEstudiante,
      String idMateria, double valorNota) async {
    try {
      // Verificar si el usuario actual tiene permisos (administrador o profesor)
      if (esAdministrador || esProfesor) {
        // Verificar si el ID del estudiante existe y si el rol es "estudiante"
        final usuarioExiste = usuarios.any(
          (u) => u.id == idEstudiante && u.tipo.toLowerCase() == 'estudiante',
        );

        if (!usuarioExiste) {
          throw Exception(
              'Error: El ID proporcionado no pertenece a un estudiante o el estudiante no existe.');
        }

        // Verificar si la materia existe
        final materia = materias.firstWhere(
          (m) => m.id == idMateria,
          orElse: () =>
              throw Exception('Error: La materia especificada no existe.'),
        );

        // Crear la nueva nota
        final nuevaNota = Nota(
          idEstudiante: idEstudiante,
          idMateria: idMateria,
          valor: valorNota,
        );

        // Agregar la nota a la lista de notas de la materia correspondiente
        materia.notas.add(nuevaNota);

        // Guardar la nota en la base de datos
        await BaseDeDatos.agregarNota(idMateria, nuevaNota);

        // Agregar la nota a la lista local y notificar cambios
        notas.add(nuevaNota);
        notifyListeners();

        print(
            "Nota agregada correctamente para el estudiante con ID: $idEstudiante en la materia con ID: $idMateria");
      } else {
        throw Exception('Error: No tienes permisos para agregar notas.');
      }
    } catch (e) {
      // Mostrar el mensaje de error en la pantalla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // Método para modificar un usuario existente en MyAppState
  Future<void> modificarUsuario(Usuario usuario) async {
    await BaseDeDatos.modificarUsuario(usuario);
    final index = usuarios.indexWhere((u) => u.id == usuario.id);
    if (index != -1) {
      usuarios[index] = usuario;
      notifyListeners();
    }
  }

  // Método para actualizar una nota específica
  Future<void> actualizarNota(Nota nota, double nuevoValor) async {
    final index = notas.indexWhere((n) =>
        n.idEstudiante == nota.idEstudiante && n.idMateria == nota.idMateria);
    if (index != -1) {
      notas[index] = Nota(
        idEstudiante: nota.idEstudiante,
        idMateria: nota.idMateria,
        valor: nuevoValor,
      );
      await BaseDeDatos.actualizarNota(
          nota.idMateria, nota.idEstudiante, nuevoValor);
      notifyListeners();
    }
  }

  // Método para modificar una materia (solo administradores)
  Future<void> modificarMateria(
      BuildContext context, Materia materiaModificada) async {
    if (esAdministrador) {
      final index = materias.indexWhere((m) => m.id == materiaModificada.id);
      if (index != -1) {
        materias[index] = materiaModificada;

        // Guardar los cambios en la base de datos
        await BaseDeDatos.modificarMateria(materiaModificada);
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Materia modificada correctamente.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Materia no encontrada.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error: No tienes permisos para modificar materias.')),
      );
    }
  }

  // Método para eliminar una materia (solo administradores)
  Future<void> eliminarMateria(BuildContext context, String idMateria) async {
    if (esAdministrador) {
      final index = materias.indexWhere((m) => m.id == idMateria);
      if (index != -1) {
        materias.removeAt(index);

        // Eliminar la materia en la base de datos
        await BaseDeDatos.eliminarMateria(idMateria);
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Materia eliminada correctamente.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Materia no encontrada.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: No tienes permisos para eliminar materias.')),
      );
    }
  }

  // Método para eliminar un usuario existente en MyAppState
  Future<void> eliminarUsuario(String idUsuario) async {
    final index = usuarios.indexWhere((u) => u.id == idUsuario);
    if (index != -1) {
      usuarios.removeAt(index);
      // También eliminar de la base de datos
      await BaseDeDatos.eliminarUsuario(idUsuario);
      notifyListeners();
    }
  }

  // Método para eliminar una nota específica
  Future<void> eliminarNota(BuildContext context, Nota nota) async {
    try {
      // Verificar si el usuario actual tiene permisos (administrador o profesor)
      if (esAdministrador || esProfesor) {
        final index = notas.indexWhere(
          (n) =>
              n.idEstudiante == nota.idEstudiante &&
              n.idMateria == nota.idMateria,
        );

        if (index != -1) {
          // Eliminar la nota de la lista local
          notas.removeAt(index);

          // Eliminar la nota en la base de datos
          await BaseDeDatos.eliminarNota(nota.idMateria, nota.idEstudiante);
          notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nota eliminada correctamente.')),
          );
        } else {
          throw Exception('Error: Nota no encontrada.');
        }
      } else {
        throw Exception('Error: No tienes permisos para eliminar notas.');
      }
    } catch (e) {
      // Mostrar el mensaje de error en la pantalla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // Obtener notas de un estudiante específico
  List<Nota> obtenerNotasPorEstudiante(String idEstudiante) {
    return notas.where((nota) => nota.idEstudiante == idEstudiante).toList();
  }

  // Calcular promedio a partir del ID del estudiante
  double calcularPromedioPorEstudiante(String idEstudiante) {
    final notasEstudiante = obtenerNotasPorEstudiante(idEstudiante);
    if (notasEstudiante.isEmpty) return 0;

    double suma = 0;
    for (var nota in notasEstudiante) {
      suma += nota.valor;
    }
    return suma / notasEstudiante.length;
  }
}
