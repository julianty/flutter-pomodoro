import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_pomodoro/timer_picker.dart';
import 'firebase_options.dart';
import './auth.dart';
import 'category_picker.dart';

final Set<Category> defaultCategories = {
  Category(label: 'Dev', icon: Icons.code),
  Category(label: 'Hobby', icon: Icons.sports_esports),
  Category(label: 'Recreation', icon: Icons.self_improvement),
  Category(label: 'Meetings', icon: Icons.groups),
};
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red.shade800,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'Flutter Pomodoro'),
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
  Category? _selectedCategory;
  int _selectedDuration = 30;

  void changeSelectedCategory(Category cat) {
    setState(() {
      _selectedCategory = _selectedCategory == cat ? null : cat;
    });
  }

  void changeTimerDuration(int dur) {
    setState(() {
      _selectedDuration = dur;
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.title),
        actions: <Widget>[UserManagement()],
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width > 480
                    ? 480
                    : double.infinity,
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  24.0,
                ), // Adjust the value as needed
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 24,
                  children: [
                    UserGreeting(user: user),
                    CategoryPicker(
                      categories: defaultCategories,
                      selectedCategory: _selectedCategory,
                      onChanged: changeSelectedCategory,
                    ),
                    TimerPicker(
                      selectedDuration: _selectedDuration,
                      selectedCategoryLabel: _selectedCategory?.label,
                      onChanged: changeTimerDuration,
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                        ),
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_right,
                                color: colorScheme.onPrimary,
                                size: 32,
                              ),
                              Text(
                                'Start session',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: colorScheme.onPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserGreeting extends StatelessWidget {
  final User? user;
  const UserGreeting({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Center(
        child: Column(
          children: [Text('Hello, ${user!.displayName ?? "User"}')],
        ),
      );
    } else {
      return Center(child: Text('Hello!, sign in to get started.'));
    }
  }
}

class UserManagement extends StatelessWidget {
  const UserManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(user.displayName ?? "User"),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.account_circle)),
            ],
          );
        } else {
          return TextButton(
            onPressed: signInWithGoogle,
            child: Text("Sign in with Google"),
          );
        }
      },
    );
  }
}
