import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:flutter/material.dart';

import 'calendar_screen.dart';
import 'live_notifications.dart';

import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final client =
      Client(
          const String.fromEnvironment(
            'API_URL',
            defaultValue: 'http://localhost:18080/',
          ),
        )
        ..connectivityMonitor = FlutterConnectivityMonitor()
        ..authSessionManager = FlutterAuthSessionManager();
  await client.auth.initialize();
  runApp(CalendarExampleApp(client: client));
}

class CalendarExampleApp extends StatelessWidget {
  const CalendarExampleApp({super.key, required this.client});
  final Client client;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Calendar package example',
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    home: _ConnectionScreen(client: client),
  );
}

class _ConnectionScreen extends StatefulWidget {
  const _ConnectionScreen({required this.client});
  final Client client;
  @override
  State<_ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<_ConnectionScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;
  String? _result;

  @override
  void initState() {
    super.initState();
    widget.client.auth.authInfoListenable.addListener(_authChanged);
  }

  void _authChanged() {
    if (mounted) {
      setState(() {
        _result = null;
      });
    }
  }

  @override
  void dispose() {
    widget.client.auth.authInfoListenable.removeListener(_authChanged);
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _perform(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Unable to complete the request. Check sign-in details and server availability.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _signIn() async {
    if (!_form.currentState!.validate()) return;
    await _perform(() async {
      final auth = await widget.client.emailIdp.login(
        email: _email.text.trim(),
        password: _password.text,
      );
      await widget.client.auth.updateSignedInUser(auth);
      _password.clear();
    });
  }

  Future<void> _check() => _perform(() async {
    final id = await widget.client.smoke.whoAmI();
    await widget.client.modules.serverpod_calendar.calendarDiagnostics.check();
    await widget.client.modules.serverpod_notifications.notificationDiagnostics
        .check();
    if (mounted) {
      setState(() {
        _result =
            'Connected: host, calendar and notifications\nSigned in as $id';
      });
    }
  });
  @override
  Widget build(BuildContext context) {
    final signedIn = widget.client.auth.isAuthenticated;
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar package example')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  signedIn ? 'Workspace connection' : 'Sign in',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                if (!signedIn) ...[
                  const Text(
                    'Use a local demo account. Account details are provided by the workspace setup.',
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _form,
                    child: Column(
                      children: [
                        TextFormField(
                          key: const Key('email'),
                          controller: _email,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter your email'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('password'),
                          controller: _password,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter your password'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const Key('sign-in'),
                    onPressed: _busy ? null : _signIn,
                    child: const Text('Sign in'),
                  ),
                ] else ...[
                  FilledButton(
                    key: const Key('open-calendars'),
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (_) =>
                                  CalendarScreen(client: widget.client),
                            ),
                          ),
                    child: const Text('My calendars'),
                  ),
                  FilledButton(
                    key: const Key('check'),
                    onPressed: _busy ? null : _check,
                    child: const Text('Check connection'),
                  ),
                  TextButton(
                    key: const Key('sign-out'),
                    onPressed: _busy
                        ? null
                        : () => _perform(() async {
                            await widget.client.auth.signOutDevice();
                          }),
                    child: const Text('Sign out'),
                  ),
                ],
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: LinearProgressIndicator(),
                  ),
                if (_error != null) Text(_error!, key: const Key('error')),
                if (signedIn) LiveNotifications(client: widget.client),
                if (_result != null)
                  SelectableText(_result!, key: const Key('result')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
