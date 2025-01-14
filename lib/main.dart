import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/partido_service.dart';
import 'services/participante_service.dart';
import 'services/amistad_service.dart';
import 'services/estadistica_service.dart';
import 'services/equipo_service.dart';
import 'services/firestore_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/partido_viewmodel.dart';
import 'viewmodels/equipo_viewmodel.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';
import 'views/register_screen.dart';
import 'views/matchmaking_screen.dart';
import 'views/create_match_screen.dart';
import 'views/solicitudes_screen.dart';
import 'views/estadistica_screen.dart';
import 'views/partido_screen.dart';
import 'views/perfil_screen.dart';
import 'firebase_options.dart'; // Generado por FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<PartidoService>(
          create: (_) => PartidoService(),
        ),
        Provider<ParticipanteService>(
          create: (_) => ParticipanteService(),
        ),
        Provider<AmistadService>(
          create: (_) => AmistadService(),
        ),
        Provider<EstadisticaService>(
          create: (_) => EstadisticaService(),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<PartidoViewModel>(
          create: (context) => PartidoViewModel(context.read<PartidoService>()),
        ),
        ChangeNotifierProvider<EquipoViewModel>(
          create: (context) => EquipoViewModel(context.read<EquipoService>()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return MaterialApp(
      title: 'Partido App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: authViewModel.user == null ? LoginScreen() : HomeScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/matchmaking': (context) => MatchmakingScreen(),
        '/crear_partido': (context) => CrearPartidoScreen(),
        '/solicitudes': (context) => SolicitudesScreen(),
        '/estadisticas': (context) => EstadisticaScreen(),
        '/partido': (context) => PartidoScreen(
            partidoId: ModalRoute.of(context)!.settings.arguments as String),
        '/perfil': (context) => PerfilScreen(),
        // Añade otras rutas según sea necesario
      },
    );
  }
}
