import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:yaml/yaml.dart';

/// Generates local secrets. Run from the repository root; never print passwords.
Future<void> main() async {
  if (!File('toolchain.json').existsSync()) {
    throw StateError('Run this command from the repository root.');
  }
  final credentialsFile = File('.local/credentials.json');
  final passwordsFile = File(
    'example/calendar_example/calendar_example_server/config/passwords.yaml',
  );
  final envFile = File('.local/compose.env');
  if ([credentialsFile, passwordsFile, envFile].every((f) => f.existsSync())) {
    final existing = jsonDecode(
      await credentialsFile.readAsString(),
    ) as Map<String, dynamic>;
    final random = Random.secure();
    final currentPasswords =
        loadYaml(await passwordsFile.readAsString()) as YamlMap;
    final yaml = StringBuffer(
      'shared:\n  serviceSecret: ${jsonEncode(currentPasswords['shared']['serviceSecret'])}\n',
    );
    for (final mode in ['development', 'test']) {
      final values = existing[mode] as Map<String, dynamic>;
      values.putIfAbsent(
        'serverSideSessionKeyHashPepper',
        () => base64UrlEncode(List.generate(48, (_) => random.nextInt(256))),
      );
      yaml.writeln('$mode:');
      for (final entry in values.entries) {
        yaml.writeln('  ${entry.key}: ${jsonEncode(entry.value)}');
      }
    }
    await credentialsFile.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(existing)}\n',
    );
    await passwordsFile.writeAsString(yaml.toString());
    await File('.local/test_defines.json').writeAsString(
      jsonEncode({
        'API_URL': 'http://localhost:18180/',
        'DEMO_EMAIL': 'alice@example.invalid',
        'DEMO_PASSWORD': existing['test']['demoAlicePassword'],
      }),
    );
    stdout.writeln(
      'Existing local credentials retained; missing session configuration initialized.',
    );
    return;
  }
  if (credentialsFile.existsSync() || envFile.existsSync()) {
    throw StateError(
      'Incomplete local setup; restore the missing local file before continuing.',
    );
  }
  final random = Random.secure();
  String secret() =>
      base64UrlEncode(List.generate(48, (_) => random.nextInt(256)));
  final credentials = <String, Map<String, String>>{};
  final yaml = StringBuffer(
    'shared:\n  serviceSecret: ${jsonEncode(secret())}\n',
  );
  final env = StringBuffer();
  for (final mode in ['development', 'test']) {
    final values = {
      for (final key in [
        'database',
        'redis',
        'emailSecretHashPepper',
        'serverSideSessionKeyHashPepper',
        'jwtHmacSha512PrivateKey',
        'jwtRefreshTokenHashPepper',
        'demoAlicePassword',
        'demoBobPassword',
      ])
        key: secret(),
    };
    credentials[mode] = values;
    yaml.writeln('$mode:');
    for (final entry in values.entries) {
      yaml.writeln('  ${entry.key}: ${jsonEncode(entry.value)}');
    }
    final prefix = mode == 'development' ? 'DEV' : 'TEST';
    env.writeln('${prefix}_DATABASE_PASSWORD=${values['database']}');
    env.writeln('${prefix}_REDIS_PASSWORD=${values['redis']}');
  }
  await credentialsFile.parent.create(recursive: true);
  await credentialsFile.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(credentials)}\n',
  );
  await envFile.writeAsString(env.toString());
  await passwordsFile.writeAsString(yaml.toString());
  await File('.local/test_defines.json').writeAsString(
    jsonEncode({
      'API_URL': 'http://localhost:18180/',
      'DEMO_EMAIL': 'alice@example.invalid',
      'DEMO_PASSWORD': credentials['test']!['demoAlicePassword'],
    }),
  );
  stdout.writeln('Created ignored local credentials and Compose environment.');
  stdout.writeln('Demo emails: alice@example.invalid and bob@example.invalid.');
  stdout.writeln('Passwords are in .local/credentials.json; no email is sent.');
}
