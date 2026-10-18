import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ---------- Colors: red, green, white, black ----------
const kRed = Color(0xFFD62828);
const kGreen = Color(0xFF1B9E4B);
const kBlack = Color(0xFF0A0A0A);
const kWhite = Color(0xFFFFFFFF);

// ---------- Languages (add more by copying a block) ----------
const Map<String, Map<String, String>> kText = {
  'en': {
    'app': 'Mind Save Note', 'login': 'Log in', 'signup': 'Sign up',
    'name': 'Name', 'email': 'Email', 'password': 'Password',
    'haveAcc': 'Already have an account? Log in', 'noAcc': 'No account? Sign up',
    'notes': 'Notes', 'apps': 'Apps', 'settings': 'Settings',
    'newNote': 'New note', 'title': 'Title', 'body': 'Write here...',
    'save': 'Save', 'search': 'Search notes', 'empty': 'No notes yet',
    'language': 'Language', 'dark': 'Dark mode', 'security': 'Security & Privacy',
    'lock': 'App lock (fingerprint / PIN)', 'advanced': 'Advanced settings',
    'clearWeb': 'Clear logins of Facebook, WhatsApp, etc.',
    'clearNotes': 'Delete all notes', 'logout': 'Log out',
    'privacy': 'Your notes are stored only on this phone. Apps open inside Mind Save Note; passwords are never read or saved by this app.',
    'wrong': 'Wrong email or password', 'fill': 'Please fill all fields',
    'exists': 'Account already exists on this phone', 'blocked': 'Blocked: outside website',
    'done': 'Done', 'unlock': 'Unlock', 'locked': 'App is locked',
    'translate': 'Translate', 'trBtn': 'Translate', 'trHint': 'Type text to translate',
    'transFail': 'Translation failed. Check your internet connection.', 'copy': 'Copy', 'copied': 'Copied',
  },
  'bn': {
    'app': 'মাইন্ড সেভ নোট', 'login': 'লগইন', 'signup': 'সাইন আপ',
    'name': 'নাম', 'email': 'ইমেইল', 'password': 'পাসওয়ার্ড',
    'haveAcc': 'অ্যাকাউন্ট আছে? লগইন করুন', 'noAcc': 'অ্যাকাউন্ট নেই? সাইন আপ করুন',
    'notes': 'নোট', 'apps': 'অ্যাপ', 'settings': 'সেটিংস',
    'newNote': 'নতুন নোট', 'title': 'শিরোনাম', 'body': 'এখানে লিখুন...',
    'save': 'সেভ', 'search': 'নোট খুঁজুন', 'empty': 'এখনও কোনো নোট নেই',
    'language': 'ভাষা', 'dark': 'ডার্ক মোড', 'security': 'নিরাপত্তা ও প্রাইভেসি',
    'lock': 'অ্যাপ লক (ফিঙ্গারপ্রিন্ট / পিন)', 'advanced': 'অ্যাডভান্স সেটিংস',
    'clearWeb': 'Facebook, WhatsApp ইত্যাদির লগইন মুছুন',
    'clearNotes': 'সব নোট মুছুন', 'logout': 'লগ আউট',
    'privacy': 'আপনার নোট শুধু এই ফোনে থাকে। অ্যাপগুলো Mind Save Note-এর ভিতরেই খোলে; আপনার পাসওয়ার্ড এই অ্যাপ পড়ে না বা সেভ করে না।',
    'wrong': 'ইমেইল বা পাসওয়ার্ড ভুল', 'fill': 'সব ঘর পূরণ করুন',
    'exists': 'এই ফোনে অ্যাকাউন্ট আগে থেকেই আছে', 'blocked': 'বাইরের ওয়েবসাইট বন্ধ করা হয়েছে',
    'done': 'হয়েছে', 'unlock': 'আনলক', 'locked': 'অ্যাপ লক করা আছে',
    'translate': 'অনুবাদ', 'trBtn': 'অনুবাদ করুন', 'trHint': 'অনুবাদের জন্য লিখুন',
    'transFail': 'অনুবাদ হয়নি। ইন্টারনেট ঠিক আছে কি দেখুন।', 'copy': 'কপি', 'copied': 'কপি হয়েছে',
  },
  'hi': {
    'app': 'माइंड सेव नोट', 'login': 'लॉग इन', 'signup': 'साइन अप',
    'name': 'नाम', 'email': 'ईमेल', 'password': 'पासवर्ड',
    'haveAcc': 'खाता है? लॉग इन करें', 'noAcc': 'खाता नहीं है? साइन अप करें',
    'notes': 'नोट्स', 'apps': 'ऐप्स', 'settings': 'सेटिंग्स',
    'newNote': 'नया नोट', 'title': 'शीर्षक', 'body': 'यहाँ लिखें...',
    'save': 'सेव', 'search': 'नोट खोजें', 'empty': 'अभी कोई नोट नहीं',
    'language': 'भाषा', 'dark': 'डार्क मोड', 'security': 'सुरक्षा और प्राइवेसी',
    'lock': 'ऐप लॉक', 'advanced': 'एडवांस सेटिंग्स',
    'clearWeb': 'Facebook, WhatsApp आदि के लॉगिन मिटाएँ',
    'clearNotes': 'सभी नोट मिटाएँ', 'logout': 'लॉग आउट',
    'privacy': 'आपके नोट सिर्फ इसी फोन में रहते हैं।',
    'wrong': 'ईमेल या पासवर्ड गलत है', 'fill': 'सभी खाने भरें',
    'exists': 'इस फोन पर खाता पहले से है', 'blocked': 'बाहरी वेबसाइट बंद है',
    'done': 'हो गया', 'unlock': 'अनलॉक', 'locked': 'ऐप लॉक है',
  },
  'es': {
    'app': 'Mind Save Note', 'login': 'Iniciar sesión', 'signup': 'Registrarse',
    'name': 'Nombre', 'email': 'Correo', 'password': 'Contraseña',
    'haveAcc': '¿Ya tienes cuenta? Inicia sesión', 'noAcc': '¿Sin cuenta? Regístrate',
    'notes': 'Notas', 'apps': 'Apps', 'settings': 'Ajustes',
    'newNote': 'Nueva nota', 'title': 'Título', 'body': 'Escribe aquí...',
    'save': 'Guardar', 'search': 'Buscar notas', 'empty': 'Aún no hay notas',
    'language': 'Idioma', 'dark': 'Modo oscuro', 'security': 'Seguridad y privacidad',
    'lock': 'Bloqueo de app', 'advanced': 'Ajustes avanzados',
    'clearWeb': 'Borrar sesiones de Facebook, WhatsApp, etc.',
    'clearNotes': 'Borrar todas las notas', 'logout': 'Cerrar sesión',
    'privacy': 'Tus notas se guardan solo en este teléfono.',
    'wrong': 'Correo o contraseña incorrectos', 'fill': 'Completa todos los campos',
    'exists': 'Ya existe una cuenta en este teléfono', 'blocked': 'Sitio externo bloqueado',
    'done': 'Listo', 'unlock': 'Desbloquear', 'locked': 'La app está bloqueada',
  },
};

String tr(String lang, String key) => kText[lang]?[key] ?? kText['en']![key] ?? key;

// ---------- In-app services (open INSIDE the app only) ----------
class Service {
  final String name;
  final String url;
  final IconData icon;
  final Color color;
  final List<String> hosts; // only these sites may load inside the app
  final bool desktop;
  const Service(this.name, this.url, this.icon, this.color, this.hosts, {this.desktop = false});
}

const kServices = <Service>[
  Service('Facebook', 'https://m.facebook.com', Icons.facebook, Color(0xFF1877F2),
      ['facebook.com', 'fbcdn.net', 'fb.com', 'facebook.net']),
  Service('WhatsApp', 'https://web.whatsapp.com', Icons.chat, Color(0xFF25D366),
      ['whatsapp.com', 'whatsapp.net'], desktop: true),
  Service('Telegram', 'https://web.telegram.org', Icons.send, Color(0xFF229ED9),
      ['telegram.org', 't.me', 'telegram.me'], desktop: true),
  Service('Microsoft', 'https://login.live.com', Icons.window, Color(0xFF00A4EF),
      ['live.com', 'microsoft.com', 'microsoftonline.com', 'office.com', 'outlook.com', 'msauth.net', 'msftauth.net', 'msn.com']),
  Service('IMO', 'https://imo.im', Icons.videocam, Color(0xFF1AA7EC), ['imo.im']),
];

const _desktopUA =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36';

// ---------- Entry ----------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MindApp(prefs));
}

class MindApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MindApp(this.prefs, {super.key});
  @override
  State<MindApp> createState() => _MindAppState();
}

class _MindAppState extends State<MindApp> {
  late String lang = widget.prefs.getString('lang') ?? 'en';
  late bool dark = widget.prefs.getBool('dark') ?? false;
  late bool logged = widget.prefs.getBool('logged') ?? false;

  void setLang(String l) { widget.prefs.setString('lang', l); setState(() => lang = l); }
  void setDark(bool d) { widget.prefs.setBool('dark', d); setState(() => dark = d); }
  void setLogged(bool v) { widget.prefs.setBool('logged', v); setState(() => logged = v); }

  ThemeData _theme(bool isDark) {
    final scheme = ColorScheme.fromSeed(
      seedColor: kRed,
      primary: kRed,
      secondary: kGreen,
      brightness: isDark ? Brightness.dark : Brightness.light,
      surface: isDark ? kBlack : kWhite,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? kBlack : kWhite,
      appBarTheme: const AppBarTheme(backgroundColor: kRed, foregroundColor: kWhite),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: kGreen, foregroundColor: kWhite),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: tr(lang, 'app'),
      theme: _theme(false),
      darkTheme: _theme(true),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: logged
          ? LockGate(prefs: widget.prefs, lang: lang, child: Home(app: this))
          : AuthPage(app: this),
    );
  }
}

// ---------- Login / Sign up (stored on this phone, password is hashed) ----------
String _hash(String email, String pass) =>
    sha256.convert(utf8.encode('${email.trim().toLowerCase()}::$pass::msn-v1')).toString();

class AuthPage extends StatefulWidget {
  final _MindAppState app;
  const AuthPage({super.key, required this.app});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool signup = false;
  final name = TextEditingController(), email = TextEditingController(), pass = TextEditingController();
  String get lang => widget.app.lang;

  void _msg(String k) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(lang, k))));

  void _submit() {
    final p = widget.app.widget.prefs;
    if (email.text.trim().isEmpty || pass.text.isEmpty || (signup && name.text.trim().isEmpty)) {
      return _msg('fill');
    }
    final h = _hash(email.text, pass.text);
    if (signup) {
      if (p.getString('u_hash') != null && p.getString('u_email') == email.text.trim().toLowerCase()) {
        return _msg('exists');
      }
      p.setString('u_name', name.text.trim());
      p.setString('u_email', email.text.trim().toLowerCase());
      p.setString('u_hash', h);
      widget.app.setLogged(true);
    } else {
      if (p.getString('u_hash') == h) {
        widget.app.setLogged(true);
      } else {
        _msg('wrong');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.edit_note_rounded, size: 96, color: kRed),
                Text(tr(lang, 'app'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kGreen)),
                const SizedBox(height: 24),
                if (signup) ...[
                  TextField(controller: name, decoration: InputDecoration(labelText: tr(lang, 'name'))),
                  const SizedBox(height: 12),
                ],
                TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: tr(lang, 'email'))),
                const SizedBox(height: 12),
                TextField(
                    controller: pass,
                    obscureText: true,
                    decoration: InputDecoration(labelText: tr(lang, 'password'))),
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: kRed, padding: const EdgeInsets.all(14)),
                  onPressed: _submit,
                  child: Text(tr(lang, signup ? 'signup' : 'login')),
                ),
                TextButton(
                  onPressed: () => setState(() => signup = !signup),
                  child: Text(tr(lang, signup ? 'haveAcc' : 'noAcc'), style: const TextStyle(color: kGreen)),
                ),
                const SizedBox(height: 8),
                Center(
                  child: DropdownButton<String>(
                    value: lang,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
                      DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                      DropdownMenuItem(value: 'es', child: Text('Español')),
                    ],
                    onChanged: (v) => widget.app.setLang(v!),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- App lock (fingerprint / face / phone PIN) ----------
class LockGate extends StatefulWidget {
  final SharedPreferences prefs;
  final String lang;
  final Widget child;
  const LockGate({super.key, required this.prefs, required this.lang, required this.child});
  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> {
  late bool unlocked = !(widget.prefs.getBool('applock') ?? false);

  @override
  void initState() {
    super.initState();
    if (!unlocked) _auth();
  }

  Future<void> _auth() async {
    try {
      final ok = await LocalAuthentication()
          .authenticate(localizedReason: tr(widget.lang, 'locked'));
      if (ok && mounted) setState(() => unlocked = true);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (unlocked) return widget.child;
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.lock, size: 72, color: kRed),
          const SizedBox(height: 12),
          Text(tr(widget.lang, 'locked')),
          const SizedBox(height: 12),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kGreen),
              onPressed: _auth,
              child: Text(tr(widget.lang, 'unlock'))),
        ]),
      ),
    );
  }
}

// ---------- Home with 3 tabs ----------
class Home extends StatefulWidget {
  final _MindAppState app;
  const Home({super.key, required this.app});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  String get lang => widget.app.lang;

  @override
  Widget build(BuildContext context) {
    final pages = [
      NotesPage(prefs: widget.app.widget.prefs, lang: lang),
      AppsPage(lang: lang),
      TranslatorPage(lang: lang),
      SettingsPage(app: widget.app),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(tr(lang, 'app'))),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        indicatorColor: kGreen.withOpacity(0.3),
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.note_alt_outlined), label: tr(lang, 'notes')),
          NavigationDestination(icon: const Icon(Icons.apps), label: tr(lang, 'apps')),
          NavigationDestination(icon: const Icon(Icons.translate), label: tr(lang, 'translate')),
          NavigationDestination(icon: const Icon(Icons.settings), label: tr(lang, 'settings')),
        ],
      ),
    );
  }
}

// ---------- Notes (works fully offline) ----------
class NotesPage extends StatefulWidget {
  final SharedPreferences prefs;
  final String lang;
  const NotesPage({super.key, required this.prefs, required this.lang});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, dynamic>> notes = [];
  String q = '';

  @override
  void initState() {
    super.initState();
    final raw = widget.prefs.getString('notes');
    if (raw != null) notes = List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  void _persist() => widget.prefs.setString('notes', jsonEncode(notes));

  Future<void> _edit([int? index]) async {
    final res = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => EditorPage(lang: widget.lang, note: index == null ? null : notes[index])),
    );
    if (res == null) return;
    setState(() {
      if (res['delete'] == true) {
        if (index != null) notes.removeAt(index);
      } else if (index == null) {
        notes.insert(0, res);
      } else {
        notes[index] = res;
      }
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final shown = [
      for (var i = 0; i < notes.length; i++)
        if (q.isEmpty ||
            '${notes[i]['t']} ${notes[i]['b']}'.toLowerCase().contains(q.toLowerCase()))
          i
    ];
    return Scaffold(
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (v) => setState(() => q = v),
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: tr(widget.lang, 'search')),
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? Center(child: Text(tr(widget.lang, 'empty')))
              : ListView.builder(
                  itemCount: shown.length,
                  itemBuilder: (_, k) {
                    final i = shown[k];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.sticky_note_2, color: kGreen),
                        title: Text(notes[i]['t'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(notes[i]['b'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () => _edit(i),
                      ),
                    );
                  }),
        ),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: () => _edit(), child: const Icon(Icons.add)),
    );
  }
}

class EditorPage extends StatefulWidget {
  final String lang;
  final Map<String, dynamic>? note;
  const EditorPage({super.key, required this.lang, this.note});
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final t = TextEditingController(text: widget.note?['t'] ?? '');
  late final b = TextEditingController(text: widget.note?['b'] ?? '');

  void _save() {
    if (t.text.trim().isEmpty && b.text.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }
    Navigator.pop(context, {'t': t.text.trim(), 'b': b.text, 'ts': DateTime.now().toIso8601String()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(widget.lang, 'newNote')),
        actions: [
          if (widget.note != null)
            IconButton(icon: const Icon(Icons.delete), onPressed: () => Navigator.pop(context, {'delete': true})),
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(controller: t, decoration: InputDecoration(labelText: tr(widget.lang, 'title'))),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: b,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(hintText: tr(widget.lang, 'body')),
            ),
          ),
        ]),
      ),
    );
  }
}

// ---------- Apps grid (each opens inside the app) ----------
class AppsPage extends StatelessWidget {
  final String lang;
  const AppsPage({super.key, required this.lang});
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        for (final s in kServices)
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WebPage(s
