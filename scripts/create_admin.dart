// Run with: dart scripts/create_admin.dart <email> <password>
// Example:   dart scripts/create_admin.dart admin@example.com Admin@123
//
// Creates a Firebase Auth account and sets role:'admin', status:'approved'
// in Firestore users/{uid}.

import 'dart:convert';
import 'dart:io';

const _projectId = 'tr-athletic-development';

// Web API key (safe for client-side use)
const _apiKey = 'AIzaSyCWalLh6l7BdLvgTrWolC3hYiQHI5pnKBo';

Future<void> main(List<String> args) async {
  final email = args.isNotEmpty ? args[0] : '';
  final password = args.length > 1 ? args[1] : '';

  if (email.isEmpty || password.isEmpty) {
    print('Usage: dart scripts/create_admin.dart <email> <password>');
    print('Example: dart scripts/create_admin.dart admin@tr.com Admin@1234');
    exit(1);
  }

  print('Creating admin user: $email ...\n');

  // ── Step 1: Sign up via Firebase Auth REST API ──────────────────────────────
  final authResponse = await _post(
    'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey',
    {'email': email, 'password': password, 'returnSecureToken': true},
  );

  if (authResponse.containsKey('error')) {
    final code = authResponse['error']['message'];
    stderr.writeln('Auth error: $code');
    if (code == 'EMAIL_EXISTS') {
      stderr.writeln(
          'Tip: User already exists. Upgrade them via Firestore Console instead.');
    }
    exit(1);
  }

  final uid = authResponse['localId'] as String;
  final idToken = authResponse['idToken'] as String;
  print('Firebase Auth account created.  UID: $uid');

  // ── Step 2: Write Firestore document ────────────────────────────────────────
  final now = DateTime.now().toUtc().toIso8601String();
  final docBody = {
    'fields': {
      'uid': {'stringValue': uid},
      'email': {'stringValue': email},
      'fullName': {'stringValue': 'Admin'},
      'phoneNumber': {'stringValue': ''},
      'role': {'stringValue': 'admin'},
      'status': {'stringValue': 'approved'},
      'createdAt': {'timestampValue': now},
    }
  };

  final fsResponse = await _patch(
    'https://firestore.googleapis.com/v1/projects/$_projectId'
    '/databases/(default)/documents/users/$uid',
    docBody,
    bearerToken: idToken,
  );

  if (fsResponse.containsKey('error')) {
    stderr.writeln('Firestore error: ${fsResponse['error']}');
    exit(1);
  }

  print('Firestore document written  (role: admin, status: approved)\n');
  print('─────────────────────────────────────────');
  print('Admin login credentials:');
  print('  Email   : $email');
  print('  Password: $password');
  print('─────────────────────────────────────────');
}

// ── HTTP helpers ──────────────────────────────────────────────────────────────

Future<Map<String, dynamic>> _post(
    String url, Map<String, dynamic> body) async {
  final client = HttpClient();
  try {
    final req = await client.postUrl(Uri.parse(url));
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
    final res = await req.close();
    final raw = await res.transform(utf8.decoder).join();
    return jsonDecode(raw) as Map<String, dynamic>;
  } finally {
    client.close();
  }
}

Future<Map<String, dynamic>> _patch(
  String url,
  Map<String, dynamic> body, {
  String? bearerToken,
}) async {
  final client = HttpClient();
  try {
    final req = await client.patchUrl(Uri.parse(url));
    req.headers.contentType = ContentType.json;
    if (bearerToken != null) {
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearerToken');
    }
    req.write(jsonEncode(body));
    final res = await req.close();
    final raw = await res.transform(utf8.decoder).join();
    return jsonDecode(raw) as Map<String, dynamic>;
  } finally {
    client.close();
  }
}
