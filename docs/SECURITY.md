# Security Guide - NCC Finance Mobile

## Table of Contents
1. [Overview](#overview)
2. [Authentication & Authorization](#authentication--authorization)
3. [Data Encryption](#data-encryption)
4. [Secure Storage](#secure-storage)
5. [Firebase Security](#firebase-security)
6. [Network Security](#network-security)
7. [Input Validation](#input-validation)
8. [Security Best Practices](#security-best-practices)
9. [Vulnerability Management](#vulnerability-management)
10. [Compliance & Standards](#compliance--standards)

## Overview

Security is a critical aspect of any financial application. NCC Finance Mobile implements multiple layers of security to protect user data, ensure secure authentication, and maintain data integrity.

### Security Layers
1. **Authentication Layer**: Firebase Authentication with secure session management
2. **Authorization Layer**: Firestore Security Rules for data access control
3. **Data Layer**: Encryption for sensitive data
4. **Transport Layer**: HTTPS/TLS for all network communications
5. **Application Layer**: Input validation and secure coding practices

## Authentication & Authorization

### Firebase Authentication

The app uses Firebase Authentication for secure user management:

```dart
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;
  
  @override
  Future<void> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific error codes
      if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw InvalidCredentialsException();
      }
    }
  }
}
```

### Authentication Features

#### 1. Secure Login
- ✅ Email/password authentication
- ✅ Credential validation before Firebase call
- ✅ Rate limiting via Firebase
- ✅ Session management via Firebase Auth tokens

#### 2. Password Security
- ✅ Minimum password requirements enforced by Firebase
- ✅ Weak password detection
- ✅ Secure password reset via email
- ✅ No password storage in app (handled by Firebase)

#### 3. Session Management
```dart
// Firebase Auth automatically handles:
// - Session tokens with expiration
// - Automatic token refresh
// - Secure session storage
// - Session persistence across app restarts

// Auth state monitoring
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      // User is authenticated
      return AuthenticatedApp();
    }
    // User is not authenticated
    return LoginScreen();
  },
)
```

#### 4. Automatic Logout
Firebase Auth automatically logs out users when:
- Token expires (configurable)
- User changes password
- Session is revoked
- Security violations detected

### Authorization with Firestore Rules

Firestore Security Rules provide server-side authorization:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User document: Only authenticated user can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Balances sub-collection
      match /balances/{balanceId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Transactions sub-collection
      match /transactions/{transactionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Investments sub-collection
      match /investments/{investmentId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Key Authorization Principles

1. **Authenticated Access Only**: No unauthenticated user can read or write data
2. **User Isolation**: Users can only access their own data
3. **Server-Side Enforcement**: Rules enforced by Firebase, not client code
4. **Defense in Depth**: Client validation + server validation

## Data Encryption

### Encryption Requirements

Financial applications must encrypt sensitive data:

#### Sensitive Data Categories
1. **Authentication Credentials**: Email, password (handled by Firebase)
2. **Personal Information**: User name, profile data
3. **Financial Data**: Balances, transaction amounts
4. **Documents**: Receipts, attachments

### Encryption Implementation Strategy

#### 1. Data at Rest

**Firebase Encryption (Automatic)**
- All Firestore data encrypted at rest by default
- Firebase Storage files encrypted automatically
- AES-256 encryption standard
- Google-managed encryption keys

**Local Storage Encryption (Recommended Addition)**
```dart
// For local caching of sensitive data, use flutter_secure_storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Store sensitive data
  Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  // Retrieve sensitive data
  Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }
  
  // Delete sensitive data
  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }
}
```

**Platform-Specific Security**
- **iOS**: Data stored in iOS Keychain (hardware-backed encryption)
- **Android**: Data stored in EncryptedSharedPreferences (AES-256)

#### 2. Data in Transit

All network communications use HTTPS/TLS:
- Firebase SDK enforces HTTPS
- Certificate pinning (optional enhancement)
- TLS 1.2+ protocol
- Perfect Forward Secrecy (PFS)

### Field-Level Encryption (Advanced)

For extremely sensitive data, implement field-level encryption:

```dart
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;
  
  Future<void> initialize() async {
    // Generate or retrieve encryption key
    String? keyString = await _storage.read(key: 'encryption_key');
    
    if (keyString == null) {
      // Generate new key on first launch
      final key = encrypt.Key.fromSecureRandom(32);
      keyString = key.base64;
      await _storage.write(key: 'encryption_key', value: keyString);
    }
    
    final key = encrypt.Key.fromBase64(keyString);
    _iv = encrypt.IV.fromLength(16);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }
  
  String encryptData(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }
  
  String decryptData(String encryptedText) {
    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
}
```

**When to Use Field-Level Encryption:**
- Credit card numbers (if stored)
- Bank account numbers
- Social security numbers
- Tax identification numbers

**Note**: Current implementation relies on Firebase's built-in encryption. Field-level encryption should be added for PCI-DSS compliance if storing payment card data.

## Secure Storage

### Storage Security Comparison

| Storage Type | Security Level | Use Case |
|--------------|---------------|----------|
| SharedPreferences | ❌ Low | Non-sensitive settings only |
| flutter_secure_storage | ✅ High | Auth tokens, user credentials |
| Firestore | ✅ High | User data with access rules |
| Firebase Storage | ✅ High | Files with access rules |
| Local SQLite | ⚠️ Medium | Cached data (requires encryption) |

### Secure Storage Best Practices

#### 1. Never Store Sensitive Data Unencrypted
```dart
// ❌ BAD: Storing password in SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.setString('password', userPassword); // NEVER DO THIS!

// ✅ GOOD: Let Firebase handle authentication
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password, // Sent securely, not stored
);
```

#### 2. Use Secure Storage for Tokens
```dart
// ✅ GOOD: Store refresh tokens securely
final storage = FlutterSecureStorage();
await storage.write(key: 'refresh_token', value: token);
```

#### 3. Clear Sensitive Data on Logout
```dart
Future<void> logout() async {
  // Clear Firebase session
  await FirebaseAuth.instance.signOut();
  
  // Clear any locally stored sensitive data
  final storage = FlutterSecureStorage();
  await storage.deleteAll();
  
  // Clear cached data
  await clearCache();
}
```

## Firebase Security

### Security Rules Implementation

Current Firestore security rules ensure:

1. **Authentication Required**: All operations require valid auth token
2. **User Isolation**: Users can only access their own documents
3. **No Cross-User Access**: User A cannot read/write User B's data
4. **Atomic Operations**: Rules validate data consistency

### Example: Transaction Creation Security

```javascript
// Firestore rule
match /users/{userId}/transactions/{transactionId} {
  allow create: if request.auth.uid == userId
    && request.resource.data.amount is number
    && request.resource.data.category is string
    && request.resource.data.date is timestamp
    && request.resource.data.balanceId is string;
}
```

Corresponding Dart code:
```dart
Future<void> createTransaction(FinancialTransaction transaction) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('User not authenticated');
  
  // Security: User ID from auth token (not client input)
  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid) // ✅ Server verifies this matches auth token
      .collection('transactions')
      .doc();
  
  await docRef.set({
    'amount': transaction.amount,
    'category': transaction.category,
    'date': Timestamp.fromDate(transaction.date),
    'balanceId': transaction.balanceId,
    'description': transaction.description,
  });
}
```

### Firebase Storage Security

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile images
    match /users/{userId}/profile/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024  // Max 5MB
        && request.resource.contentType.matches('image/.*');
    }
    
    // Transaction attachments
    match /users/{userId}/transactions/{transactionId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId
        && request.resource.size < 10 * 1024 * 1024;  // Max 10MB
    }
  }
}
```

## Network Security

### HTTPS/TLS Configuration

Firebase automatically enforces HTTPS for all communications:
- Authentication requests
- Firestore queries
- Storage uploads/downloads

### Certificate Pinning (Future Enhancement)

For high-security requirements, implement certificate pinning:

```dart
import 'dart:io';
import 'package:flutter/services.dart';

class SecureHttpClient {
  static Future<HttpClient> createSecureClient() async {
    final context = SecurityContext.defaultContext;
    
    // Load certificate
    final cert = await rootBundle.load('assets/certificates/firebase.crt');
    context.setTrustedCertificatesBytes(cert.buffer.asUint8List());
    
    return HttpClient(context: context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Validate certificate
        return false; // Reject if doesn't match pinned cert
      };
  }
}
```

### API Security Checklist

- ✅ All requests use HTTPS
- ✅ No API keys hardcoded in source
- ✅ Firebase keys restricted by platform/bundle ID
- ✅ Rate limiting via Firebase
- ⚠️ Certificate pinning (not implemented yet)
- ⚠️ Request signing (not implemented yet)

## Input Validation

### Validation Layers

Security requires multiple validation layers:

1. **Client-Side Validation**: Immediate user feedback
2. **Business Logic Validation**: Notifier layer checks
3. **Server-Side Validation**: Firestore Security Rules

### Current Validation Implementation

```dart
class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }
}
```

### Advanced Validation Requirements

#### 1. Email Validation
```dart
// Enhanced email validation
static String? validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return 'Email é obrigatório';
  }
  if (!_emailRegex.hasMatch(email)) {
    return 'Email inválido';
  }
  if (email.length > 254) {
    return 'Email muito longo';
  }
  return null; // Valid
}
```

#### 2. Password Validation
```dart
static String? validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return 'Senha é obrigatória';
  }
  if (password.length < 8) {
    return 'Senha deve ter pelo menos 8 caracteres';
  }
  if (!password.contains(RegExp(r'[A-Z]'))) {
    return 'Senha deve conter pelo menos uma letra maiúscula';
  }
  if (!password.contains(RegExp(r'[a-z]'))) {
    return 'Senha deve conter pelo menos uma letra minúscula';
  }
  if (!password.contains(RegExp(r'[0-9]'))) {
    return 'Senha deve conter pelo menos um número';
  }
  if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    return 'Senha deve conter pelo menos um caractere especial';
  }
  return null; // Valid
}
```

#### 3. Transaction Amount Validation
```dart
static String? validateAmount(String? amount) {
  if (amount == null || amount.isEmpty) {
    return 'Valor é obrigatório';
  }
  
  final numericValue = double.tryParse(amount);
  if (numericValue == null) {
    return 'Valor inválido';
  }
  
  if (numericValue <= 0) {
    return 'Valor deve ser maior que zero';
  }
  
  if (numericValue > 999999999.99) {
    return 'Valor muito alto';
  }
  
  // Check decimal places (max 2 for currency)
  final parts = amount.split('.');
  if (parts.length > 1 && parts[1].length > 2) {
    return 'Valor pode ter no máximo 2 casas decimais';
  }
  
  return null; // Valid
}
```

#### 4. Category Validation
```dart
static String? validateCategory(String? category) {
  if (category == null || category.isEmpty) {
    return 'Categoria é obrigatória';
  }
  
  final validCategories = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Saúde',
    'Educação',
    'Lazer',
    'Outros',
  ];
  
  if (!validCategories.contains(category)) {
    return 'Categoria inválida';
  }
  
  return null; // Valid
}
```

#### 5. SQL Injection Prevention
```dart
// Firebase NoSQL is naturally resistant to SQL injection
// But always validate and sanitize user input

static String sanitizeInput(String input) {
  // Remove potentially dangerous characters
  return input
      .replaceAll(RegExp(r'[<>\'\"%;()&+]'), '')
      .trim();
}
```

## Security Best Practices

### 1. Authentication Best Practices

✅ **Do:**
- Use Firebase Authentication
- Implement password strength requirements
- Enable multi-factor authentication (future)
- Use secure password reset flows
- Implement account lockout after failed attempts
- Log authentication events

❌ **Don't:**
- Store passwords locally
- Send passwords in URLs
- Share credentials between environments
- Use weak encryption algorithms
- Skip input validation

### 2. Data Handling Best Practices

✅ **Do:**
- Encrypt sensitive data at rest
- Use HTTPS for all communications
- Validate all user inputs
- Sanitize data before display
- Use prepared statements (N/A for Firestore)
- Implement proper error handling

❌ **Don't:**
- Log sensitive information
- Store sensitive data in SharedPreferences
- Trust client-side validation alone
- Expose internal error details to users
- Hard-code credentials

### 3. Code Security Best Practices

✅ **Do:**
- Keep dependencies updated
- Use official packages only
- Review package source code
- Implement proper error handling
- Use code obfuscation for release builds
- Enable ProGuard/R8 for Android

❌ **Don't:**
- Use deprecated APIs
- Ignore security warnings
- Copy code without understanding it
- Skip security reviews
- Hard-code secrets in source

### 4. Mobile-Specific Security

#### iOS Security
```dart
// iOS Keychain access
IOSOptions _getIOSOptions() => const IOSOptions(
  accessibility: KeychainAccessibility.first_unlock_this_device,
);
```

#### Android Security
```dart
// Android EncryptedSharedPreferences
AndroidOptions _getAndroidOptions() => const AndroidOptions(
  encryptedSharedPreferences: true,
);
```

## Vulnerability Management

### Dependency Scanning

Regularly check for vulnerable dependencies:

```bash
# Check for outdated packages
flutter pub outdated

# Update packages
flutter pub upgrade

# Analyze dependencies
flutter pub deps
```

### Common Vulnerabilities to Avoid

#### 1. Insecure Data Storage
❌ **Vulnerable:**
```dart
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('api_token', token); // Plain text!
```

✅ **Secure:**
```dart
final storage = FlutterSecureStorage();
await storage.write(key: 'api_token', value: token); // Encrypted
```

#### 2. Insufficient Transport Layer Protection
❌ **Vulnerable:**
```dart
final response = await http.get(Uri.parse('http://api.example.com')); // HTTP!
```

✅ **Secure:**
```dart
final response = await http.get(Uri.parse('https://api.example.com')); // HTTPS
```

#### 3. Hardcoded Secrets
❌ **Vulnerable:**
```dart
const String API_KEY = "sk_live_abc123..."; // Hard-coded!
```

✅ **Secure:**
```dart
// Store in environment variables or secure storage
final apiKey = dotenv.env['API_KEY'];
```

#### 4. Improper Error Handling
❌ **Vulnerable:**
```dart
catch (e) {
  print('Error: $e'); // Exposes sensitive info in logs
  showDialog(message: e.toString()); // Shows to user
}
```

✅ **Secure:**
```dart
catch (e) {
  logger.error('Transaction failed', error: e); // Log for developers
  showDialog(message: 'Ocorreu um erro. Tente novamente.'); // Generic message
}
```

### Security Audit Checklist

- [ ] All API calls use HTTPS
- [ ] No sensitive data in logs
- [ ] No hardcoded credentials
- [ ] Input validation implemented
- [ ] Authentication required for all operations
- [ ] Authorization rules enforced
- [ ] Sensitive data encrypted
- [ ] Dependencies up to date
- [ ] Security rules tested
- [ ] Error messages don't leak info

## Compliance & Standards

### Relevant Standards

1. **OWASP Mobile Top 10**
   - M1: Improper Platform Usage ✅
   - M2: Insecure Data Storage ✅
   - M3: Insecure Communication ✅
   - M4: Insecure Authentication ✅
   - M5: Insufficient Cryptography ⚠️ (Basic implementation)
   - M6: Insecure Authorization ✅
   - M7: Client Code Quality ✅
   - M8: Code Tampering ⚠️ (Not implemented)
   - M9: Reverse Engineering ⚠️ (Not implemented)
   - M10: Extraneous Functionality ✅

2. **LGPD (Brazilian GDPR)**
   - User consent for data collection ⚠️ (To be implemented)
   - Right to data deletion ⚠️ (To be implemented)
   - Data minimization ✅
   - Purpose limitation ✅

3. **PCI-DSS** (If handling card data)
   - Not applicable (no card storage in current implementation)

### Security Roadmap

#### Phase 1: Current Implementation ✅
- Firebase Authentication
- Firestore Security Rules
- HTTPS/TLS encryption
- Basic input validation

#### Phase 2: Enhanced Security (Recommended)
- [ ] Implement flutter_secure_storage
- [ ] Add advanced field validation
- [ ] Implement field-level encryption for sensitive data
- [ ] Add biometric authentication
- [ ] Implement certificate pinning
- [ ] Add security logging and monitoring

#### Phase 3: Compliance & Advanced Features
- [ ] LGPD compliance features
- [ ] Multi-factor authentication
- [ ] Fraud detection
- [ ] Security audit logging
- [ ] Penetration testing
- [ ] Security training for developers

## Conclusion

Security is an ongoing process, not a one-time implementation. The current architecture provides a solid security foundation with Firebase Authentication and Security Rules. However, for a production financial application, additional security measures should be implemented, particularly:

1. **Secure local storage** for caching sensitive data
2. **Field-level encryption** for highly sensitive information
3. **Advanced input validation** for all user inputs
4. **Biometric authentication** for enhanced security
5. **Security monitoring** and audit logging

Regular security audits and staying updated with security best practices are essential for maintaining a secure financial application.
