---
trigger: always_on
alwaysApply: true
---
# Dart & Flutter Coding Standards

## General Principles

### Language Standards
- **Language:** English for all code and documentation
- **Type Safety:** Always declare types (parameters and return values)
- **Spacing:** No blank lines within functions
- **Exports:** One export per file

### Avoid
- Using `dynamic` or `any`
- Magic numbers (define constants)
- Abbreviations (except standard: API, URL, ID, i, j, ctx, err)
- Nested function blocks

## Naming Conventions

### File & Directory Names
```dart
// snake_case for files and directories
user_profile_screen.dart
appointment_model.dart
api_config.dart
state_management/
```

### Class Names
```dart
// PascalCase for classes
class UserProfile {}
class AppointmentModel {}
class SecureStorage {}
```

### Variables & Functions
```dart
// camelCase for variables, functions, methods
String userName = 'John';
int appointmentCount = 0;

void scheduleAppointment() {}
Future<User> fetchUserProfile() async {}
```

### Constants
```dart
// UPPERCASE for environment variables and constants
const String API_BASE_URL = 'https://api.example.com';
const int MAX_RETRY_ATTEMPTS = 3;
const Duration REQUEST_TIMEOUT = Duration(seconds: 30);
```

### Boolean Variables
```dart
// Start with verbs
bool isLoading = false;
bool hasError = false;
bool canDelete = true;
bool shouldRefresh = false;
```

### Private Members
```dart
// Leading underscore for private
class MyWidget extends StatefulWidget {
  final String _privateField;
  
  void _privateMethod() {}
}
```

## Function Standards

### Function Naming
```dart
// Start with verb + description
void saveUser(User user) {}
Future<List<Appointment>> fetchAppointments() async {}

// Boolean returns: is/has/can
bool isValidEmail(String email) {}
bool hasPermission(String role) {}
bool canSchedule(DateTime date) {}
```

### Function Size
**Guidelines:**
- Less than 20 instructions per function
- Single purpose per function
- Extract complex logic to utilities
- Use early returns to avoid nesting

**Example:**
```dart
// Good: Early returns, single purpose
Future<bool> validateAndSave(User user) async {
  if (!isValidEmail(user.email)) {
    return false;
  }
  
  if (!hasRequiredFields(user)) {
    return false;
  }
  
  return await saveUser(user);
}

// Avoid: Nested blocks
Future<bool> validateAndSave(User user) async {
  if (isValidEmail(user.email)) {
    if (hasRequiredFields(user)) {
      return await saveUser(user);
    }
  }
  return false;
}
```

### Higher-Order Functions
```dart
// Use map, filter, reduce to avoid nesting
final activeUsers = users.where((u) => u.isActive).toList();
final userNames = users.map((u) => u.name).toList();

// Arrow functions for simple operations (<3 instructions)
final doubled = numbers.map((n) => n * 2).toList();

// Named functions for complex operations
final validated = users.where(_isValidUser).toList();

bool _isValidUser(User user) {
  return user.email.isNotEmpty &&
         user.age >= 18 &&
         user.hasAcceptedTerms;
}
```

### Default Parameters
```dart
// Use defaults instead of null checks
void sendMessage({
  required String text,
  String priority = 'normal',
  bool notify = true,
}) {
  // No need to check for null
}
```

### RO-RO Pattern (Receive Object, Return Object)
```dart
// For multiple parameters, use objects
class CreateAppointmentParams {
  final String userId;
  final String counselorId;
  final DateTime dateTime;
  final String notes;
  
  const CreateAppointmentParams({
    required this.userId,
    required this.counselorId,
    required this.dateTime,
    this.notes = '',
  });
}

Future<AppointmentResult> createAppointment(
  CreateAppointmentParams params,
) async {
  // Implementation
  return AppointmentResult(success: true, id: '123');
}
```

## Data Management

### Immutability
```dart
// Prefer immutable data
class User {
  final String id;
  final String name;
  final String email;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
  });
  
  User copyWith({String? name, String? email}) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
```

### Composite Types
```dart
// Encapsulate data in types, not primitives
// Bad: Primitive obsession
String formatAddress(String street, String city, String zip) {}

// Good: Composite type
class Address {
  final String street;
  final String city;
  final String zipCode;
  
  const Address({
    required this.street,
    required this.city,
    required this.zipCode,
  });
  
  String format() => '$street, $city $zipCode';
}

void processAddress(Address address) {}
```

### Validation in Classes
```dart
// Internal validation
class Email {
  final String value;
  
  Email(this.value) {
    if (!_isValid(value)) {
      throw ArgumentError('Invalid email format');
    }
  }
  
  static bool _isValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

// Usage
try {
  final email = Email('user@example.com');
} catch (e) {
  // Handle invalid email
}
```

## Class Standards

### SOLID Principles
```dart
// Single Responsibility
class UserRepository {
  Future<User> getUser(String id) async {}
  Future<void> saveUser(User user) async {}
}

// Open/Closed - extend via composition
abstract class Validator {
  bool validate(String value);
}

class EmailValidator implements Validator {
  @override
  bool validate(String value) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
  }
}

// Dependency Inversion - depend on abstractions
abstract class StorageService {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class SecureStorageImpl implements StorageService {
  // Implementation
}
```

### Class Size
**Limits:**
- Less than 200 instructions
- Less than 10 public methods
- Less than 10 properties

**When exceeding limits:**
- Extract related methods to new class
- Use composition
- Create helper classes
- Split responsibilities

### Composition Over Inheritance
```dart
// Prefer composition
class UserService {
  final ApiClient _api;
  final CacheManager _cache;
  
  UserService(this._api, this._cache);
  
  Future<User> getUser(String id) async {
    final cached = await _cache.get(id);
    if (cached != null) return cached;
    
    final user = await _api.fetchUser(id);
    await _cache.set(id, user);
    return user;
  }
}

// Avoid deep inheritance chains
```

## Exception Handling

### When to Use Exceptions
```dart
// Use for unexpected errors
Future<User> fetchUser(String id) async {
  try {
    return await api.getUser(id);
  } catch (e) {
    // Only catch to:
    // 1. Fix expected problem
    if (e is NetworkException) {
      return await fetchUserFromCache(id);
    }
    
    // 2. Add context
    throw UserFetchException('Failed to fetch user $id', e);
    
    // 3. Otherwise, let global handler catch
  }
}
```

### Error Types
```dart
// Define custom exceptions
class AppException implements Exception {
  final String message;
  final dynamic originalError;
  
  const AppException(this.message, [this.originalError]);
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([dynamic error]) 
    : super('Network error occurred', error);
}

class ValidationException extends AppException {
  const ValidationException(String message) : super(message);
}
```

## Testing Standards

### Test Structure (Arrange-Act-Assert)
```dart
test('should return user when ID exists', () async {
  // Arrange
  final mockApi = MockApiClient();
  final inputId = 'user123';
  final expectedUser = User(id: inputId, name: 'John');
  
  when(() => mockApi.getUser(inputId))
    .thenAnswer((_) async => expectedUser);
  
  final service = UserService(mockApi);
  
  // Act
  final actualUser = await service.getUser(inputId);
  
  // Assert
  expect(actualUser, equals(expectedUser));
  verify(() => mockApi.getUser(inputId)).called(1);
});
```

### Test Naming Convention
```dart
// Descriptive test names
group('UserService', () {
  group('getUser', () {
    test('should return cached user when available', () {});
    test('should fetch from API when cache is empty', () {});
    test('should throw exception when user not found', () {});
  });
});
```

### Test Variables
```dart
// Clear naming
final inputEmail = 'test@example.com';
final mockRepository = MockUserRepository();
final actualResult = await service.validateEmail(inputEmail);
final expectedResult = true;
```

### Widget Testing
```dart
testWidgets('should display error message when validation fails', 
  (tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen()),
    );
    
    // Act
    await tester.enterText(
      find.byType(TextField),
      'invalid-email',
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    
    // Assert
    expect(find.text('Invalid email format'), findsOneWidget);
  },
);
```

## Flutter-Specific Standards

### Widget Best Practices
```dart
// Use const constructors
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Text('Hello');
  }
}

// Extract complex widgets
class ComplexScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }
  
  AppBar _buildAppBar() => AppBar(title: const Text('Title'));
  Widget _buildBody() => _BodyWidget();
  Widget _buildFAB() => FloatingActionButton(onPressed: () {});
}
```

### State Management
```dart
// Keep state local when possible
class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;
  
  void _increment() {
    setState(() => _count++);
  }
  
  @override
  Widget build(BuildContext context) {
    return Text('$_count');
  }
}
```

### Performance Optimization
```dart
// Const constructors reduce rebuilds
const Divider();
const SizedBox(height: 16);

// Extract static widgets
class StaticHeader extends StatelessWidget {
  const StaticHeader({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Text('Static Content');
  }
}

// Use keys for lists
ListView.builder(
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index].id),
      title: Text(items[index].name),
    );
  },
);
```

## Code Organization

### File Structure
```dart
// Imports order:
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. External packages
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// 4. Internal imports
import 'package:counselign/models/user.dart';
import 'package:counselign/services/api_service.dart';

// Constants at top
const int MAX_RETRIES = 3;

// Main class
class MyService {}
```

### Single Responsibility Files
- One main class/widget per file
- Related helper classes in same file acceptable
- Extract if file exceeds 300 lines
- Keep related code together
