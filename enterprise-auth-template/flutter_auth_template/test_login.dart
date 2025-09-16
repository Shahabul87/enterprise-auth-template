import 'dart:io';
import 'dart:convert';

void main() async {
  // Test credentials
  final email = 'sham251087@gmail.com';
  final password = 'ShaM2510*##&*';

  print('Testing login with Flutter app credentials...\n');

  // Test the API endpoint
  final client = HttpClient();
  try {
    final request = await client.postUrl(
      Uri.parse('http://localhost:8000/api/v1/auth/login'),
    );

    request.headers.set('Content-Type', 'application/json');
    request.headers.set('User-Agent', 'dart/3.9 (dart:io)');

    final body = json.encode({
      'email': email,
      'password': password,
    });

    request.write(body);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    print('Status Code: ${response.statusCode}');
    print('Response: $responseBody');

    if (response.statusCode == 200) {
      print('\n✅ Login successful!');
      final data = json.decode(responseBody);
      print('User: ${data['data']['user']['email']}');
    } else {
      print('\n❌ Login failed');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}