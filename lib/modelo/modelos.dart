// modelos.dart

class Usuario {
  String id;
  String nombre;
  String tipo; // 'administrador', 'profesor' o 'estudiante'
  String email;
  String contrasena;

  Usuario(
      {required this.id,
      required this.nombre,
      required this.tipo,
      required this.email,
      required this.contrasena});

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'email': email,
        'contrasena': contrasena,
      };

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      email: json['email'],
      contrasena: json['contrasena'],
    );
  }
}

class Materia {
  final String id;
  final String nombre;
  final String descripcion;
  final List<Nota> notas;

  Materia({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.notas = const [], // Proporcionar una lista vacía por defecto
  });

  // Conversión desde JSON
  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id']?.toString() ?? '0',
      nombre: json['nombre']?.toString() ?? 'Sin nombre',
      descripcion: json['descripcion']?.toString() ?? 'Sin descripción',
      notas: (json['notas'] as List?)?.map((nota) {
            if (nota is Map<String, dynamic>) {
              return Nota.fromJson(nota);
            } else {
              print("Advertencia: Datos de nota inválidos encontrados: $nota");
              return Nota(idEstudiante: '', idMateria: '', valor: 0.0);
            }
          }).toList() ??
          [], // Asignar una lista vacía si no hay notas
    );
  }

  // Conversión a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'notas': notas.map((nota) => nota.toJson()).toList(),
      };
}

class Nota {
  String idEstudiante;
  String idMateria;
  double valor;

  Nota(
      {required this.idEstudiante,
      required this.idMateria,
      required this.valor});

  Map<String, dynamic> toJson() => {
        'idEstudiante': idEstudiante,
        'idMateria': idMateria,
        'valor': valor,
      };

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      idEstudiante: json['idEstudiante'] ?? '',
      idMateria: json['idMateria'] ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
