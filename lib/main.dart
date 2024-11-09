import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pantallas/login_screen.dart';
import 'pantallas/menu_screen.dart';
import 'pantallas/asignaturas_screen.dart';
import 'pantallas/notas_screen.dart';
import 'pantallas/average_screen.dart';
import 'pantallas/usuarios_screen.dart';
import 'pantallas/user_register_page.dart';
import 'modelo/my_app_state.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'CASGRADES',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/menu': (context) => MenuScreen(),
          '/asignaturas': (context) => AsignaturasScreen(),
          '/notas': (context) => NotasScreen(),
          '/average': (context) => AverageScreen(),
          '/usuarios': (context) => UsuariosScreen(),
          '/register-student': (context) => UserRegisterPage(),
        },
      ),
    );
  }
}
