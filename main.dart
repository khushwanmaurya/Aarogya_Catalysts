import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------- CONFIG ----------------
const String BACKEND_BASE = 'https://unapposite-lashon-unfeelingly.ngrok-free.dev';

// ----------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.orange,
      brightness: Brightness.light,
      textTheme: GoogleFonts.poppinsTextTheme(),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medicine Dispenser (Doctor)',
      theme: baseTheme.copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ),
      home: AuthGate(),
    );
  }
}

// ---------------- Auth Gate ----------------
class AuthGate extends StatefulWidget {
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  User? user;
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((u) {
      setState(() => user = u);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return AuthPage();
    return HomePage();
  }
}

// ---------------- Auth Page ----------------
class AuthPage extends StatefulWidget {
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLogin = true;
  bool loading = false;

  Future<void> onAction() async {
    setState(() => loading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signed up. Ask admin to approve your account.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth error: ${e.message}')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLogin ? 'Doctor Login' : 'Doctor Sign Up',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: loading ? null : onAction,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isLogin ? 'Sign In' : 'Sign Up',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin ? 'Create an account' : 'Already have an account? Sign in',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- Home Page ----------------
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  String deviceId = 'medicine_dispenser_1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: const Icon(Icons.person, color: Colors.deepOrange),
                  ),
                  title: Text(user.email ?? 'doctor', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Device: $deviceId'),
                  trailing: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: () => FirebaseAuth.instance.signOut(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CreateSchedulePage(deviceId: deviceId)),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.list_alt_rounded, color: Colors.orange),
                label: const Text('View Device Events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EventsPage(deviceId: deviceId)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Create Schedule Page ----------------
class CreateSchedulePage extends StatefulWidget {
  final String deviceId;
  const CreateSchedulePage({required this.deviceId});
  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  int slot = 1;
  final patientsCtrl = TextEditingController();
  TimeOfDay selected = const TimeOfDay(hour: 7, minute: 0);
  final messageCtrl = TextEditingController();
  bool sending = false;

  Future<void> pickTime() async {
    final t = await showTimePicker(context: context, initialTime: selected);
    if (t != null) setState(() => selected = t);
  }

  Future<void> sendSchedule() async {
    final patientsCsv = patientsCtrl.text.trim();
    final patients =
    patientsCsv.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (patients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter at least one patient (comma separated).')));
      return;
    }
    setState(() => sending = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final idToken = await user.getIdToken();
      final hh = selected.hour.toString().padLeft(2, '0');
      final mm = selected.minute.toString().padLeft(2, '0');
      final schedule = {
        "schedules": [
          {
            "id": "sch_${DateTime.now().millisecondsSinceEpoch}",
            "device_id": widget.deviceId,
            "slot": slot,
            "patients": patients,
            "time": "$hh:$mm",
            "recurrence": "daily",
            "display_message": messageCtrl.text.trim()
          }
        ]
      };
      final resp = await http.post(Uri.parse('$BACKEND_BASE/api/schedules'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $idToken'},
          body: jsonEncode(schedule));
      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('✅ Schedule sent successfully')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error ${resp.statusCode}: ${resp.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: [
                const Text('Slot: ', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: slot,
                  items: [1, 2, 3, 4, 5]
                      .map((s) => DropdownMenuItem(value: s, child: Text('Slot $s')))
                      .toList(),
                  onChanged: (v) => setState(() => slot = v ?? 1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: patientsCtrl,
              decoration: const InputDecoration(
                  labelText: 'Patients (A,B,C e.g.)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: pickTime,
                  child: const Text('Pick Time'),
                ),
                const SizedBox(width: 12),
                Text(
                  '${selected.format(context)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageCtrl,
              decoration: const InputDecoration(
                labelText: 'Display Message (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sending ? null : sendSchedule,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: sending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send Schedule',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Events Page ----------------
class EventItem {
  final String event;
  final String? patient;
  final int? slot;
  final int? ts;
  EventItem(this.event, {this.patient, this.slot, this.ts});
  factory EventItem.fromJson(Map<String, dynamic> j) {
    return EventItem(j['event'] ?? '',
        patient: j['patient'],
        slot: j['slot'] is int
            ? j['slot']
            : (j['slot'] != null ? int.parse('${j['slot']}') : null),
        ts: j['ts'] is int
            ? j['ts']
            : (j['ts'] != null ? int.parse('${j['ts']}') : null));
  }
}

class EventsPage extends StatefulWidget {
  final String deviceId;
  const EventsPage({required this.deviceId});
  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Future<List<EventItem>> futureEvents;
  @override
  void initState() {
    super.initState();
    futureEvents = fetchEvents();
  }

  Future<List<EventItem>> fetchEvents() async {
    final user = FirebaseAuth.instance.currentUser!;
    final idToken = await user.getIdToken();
    final url = Uri.parse('$BACKEND_BASE/api/events?deviceId=${widget.deviceId}');
    final resp = await http.get(url, headers: {'Authorization': 'Bearer $idToken'});
    if (resp.statusCode == 200) {
      List<dynamic> arr = jsonDecode(resp.body);
      return arr.map((e) => EventItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch events: ${resp.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Events', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<EventItem>>(
        future: futureEvents,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('No events yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final e = list[i];
              final timeStr = e.ts != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss')
                  .format(DateTime.fromMillisecondsSinceEpoch(e.ts! * 1000))
                  : '';
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: Icon(
                    e.event == 'dispensed'
                        ? Icons.check_circle
                        : Icons.warning_amber_rounded,
                    color: e.event == 'dispensed' ? Colors.green : Colors.orange,
                    size: 30,
                  ),
                  title: Text(
                    '${e.event} ${e.patient ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Slot: ${e.slot ?? '-'}   $timeStr'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
