import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // To load the .env file contents into dotenv.
  // NOTE: fileName defaults to .env and that's what we want.
  // Also, we need to ensure we don't crash if the file is missing (e.g. in production if using dart-define only)
  // However, flutter_dotenv throws if file not found unless we handle it.
  // For this demo, we assume .env exists or we catch the error.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // If .env is missing, we might be relying on dart-define.
    // flutter_dotenv doesn't automatically read dart-define.
    // We will handle the fallback in the UI.
    debugPrint("Error loading .env: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Environment Variables Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Helper to get env var from either dotenv or dart-define
  String getEnv(String key) {
    // 1. Try dotenv (runtime .env file)
    String? value = dotenv.env[key];
    if (value != null && value.isNotEmpty) {
      return value;
    }
    // 2. Try dart-define (compile-time constant)
    // Note: String.fromEnvironment requires a const string literal for the key if we want it to be truly const.
    // Actually, String.fromEnvironment works with dynamic keys but it won't be a "const" value, just a runtime lookup of the environment.
    // However, for optimization, it's often better to use const.
    // Let's just use the specific keys we know we want.
    if (key == 'API_KEY') {
      return const String.fromEnvironment('API_KEY', defaultValue: 'Not Found');
    }
    if (key == 'CLIENT_ID') {
      return const String.fromEnvironment(
        'CLIENT_ID',
        defaultValue: 'Not Found',
      );
    }
    return 'Not Found';
  }

  @override
  Widget build(BuildContext context) {
    final apiKey =
        dotenv.env['API_KEY'] ??
        const String.fromEnvironment('API_KEY', defaultValue: 'Not set');
    final clientId =
        dotenv.env['CLIENT_ID'] ??
        const String.fromEnvironment('CLIENT_ID', defaultValue: 'Not set');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Environment Variables:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('API_KEY: $apiKey'),
            const SizedBox(height: 10),
            Text('CLIENT_ID: $clientId'),
          ],
        ),
      ),
    );
  }
}
