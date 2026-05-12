# Google Sign-In — Setup manual

Autenticación con Google para Outventura (Flutter + NestJS).  
Package ID Android: `com.outventura.outventura`

---

## Flujo completo

```
Flutter → google_sign_in → idToken → POST /auth/google → NestJS verifica → devuelve JWT propio
```

---

## Parte 1 — Firebase Console (manual)

> Si ya hiciste el setup de FCM, reutiliza el mismo proyecto Firebase.

1. Ve a https://console.firebase.google.com → tu proyecto
2. En el menú lateral: **Build → Authentication**
3. Haz clic en **"Comenzar"** si no está activo
4. En la pestaña **"Sign-in method"**, habilita **Google**
5. Pon un nombre de proyecto público (ej. `Outventura`) y un email de soporte
6. Guarda

### SHA-1 para Android (obligatorio)

Ejecuta este comando en el proyecto:

```bash
cd android
./gradlew signingReport
```

Copia el valor `SHA1` del variant `debug` y añádelo en Firebase Console:  
**Configuración del proyecto → Tu app Android → Añadir huella digital**

---

## Parte 2 — Flutter

### 2.1 Dependencias en `pubspec.yaml`

```yaml
dependencies:
  google_sign_in: ^6.2.2
```

```bash
flutter pub get
```

### 2.2 Android — `android/app/build.gradle.kts`

Asegúrate de tener el plugin de Google Services (ver `firebase_fcm_setup.md`):

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // necesario
}
```

### 2.3 Servicio de Google Sign-In

Crea el archivo `lib/features/auth/data/services/google_auth_service.dart`:

```dart
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // Abre el popup de Google y devuelve el idToken.
  // Devuelve null si el usuario cancela.
  static Future<String?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;
      final auth = await account.authentication;
      return auth.idToken;
    } catch (_) {
      return null;
    }
  }

  static Future<void> signOut() => _googleSignIn.signOut();
}
```

### 2.4 Llamada al backend

Cuando el backend esté listo, en `lib/features/auth/data/services/auth_service.dart` añade:

```dart
// POST /auth/google con el idToken obtenido de Google
Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
  final response = await dio.post('/auth/google', data: {'idToken': idToken});
  return response.data; // { token, user }
}
```

### 2.5 Botón en `login_page.dart`

Añade el botón debajo del botón de login normal:

```dart
OutlinedButton.icon(
  icon: Image.asset('assets/icons/google.png', height: 20),
  label: Text(s.continueWithGoogle),
  style: OutlinedButton.styleFrom(
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    side: BorderSide(color: colorScheme.outline),
    foregroundColor: colorScheme.onSurface,
    backgroundColor: colorScheme.surface,
  ),
  onPressed: () async {
    final idToken = await GoogleAuthService.signIn();
    if (idToken == null) return;
    // TODO: llamar al backend con idToken cuando esté listo
    // final result = await AuthService().loginWithGoogle(idToken);
  },
),
```

> Necesitarás el icono de Google en `assets/icons/google.png` y declararlo en `pubspec.yaml`.  
> También añade la clave `continueWithGoogle` en los archivos ARB.

---

## Parte 3 — NestJS (cuando el backend esté listo)

### 3.1 Dependencias

```bash
npm install google-auth-library @nestjs/passport passport passport-jwt
```

### 3.2 Endpoint `POST /auth/google`

```typescript
// auth/auth.controller.ts
@Post('google')
async loginWithGoogle(@Body('idToken') idToken: string) {
  return this.authService.loginWithGoogle(idToken);
}
```

### 3.3 Verificación del token

```typescript
// auth/auth.service.ts
import { OAuth2Client } from 'google-auth-library';

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

async loginWithGoogle(idToken: string) {
  const ticket = await client.verifyIdToken({
    idToken,
    audience: process.env.GOOGLE_CLIENT_ID,
  });
  const payload = ticket.getPayload();
  
  // Buscar o crear el usuario
  let user = await this.usersService.findByEmail(payload.email);
  if (!user) {
    user = await this.usersService.create({
      email: payload.email,
      nombre: payload.name,
      avatar: payload.picture,
      // sin contraseña, es login social
    });
  }
  
  // Devolver el mismo JWT que usas para login normal
  return this.generateToken(user);
}
```

### 3.4 Variable de entorno necesaria

En `.env`:
```
GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com
```

El Client ID lo encuentras en Firebase Console → Configuración del proyecto → Tu app Web o Android.

---

## Notas

- El `google-services.json` comparte configuración entre FCM y Google Sign-In, no necesitas dos archivos.
- En iOS también necesitarás el `GoogleService-Info.plist` y configurar el URL scheme inverso en `Runner/Info.plist`.
- Los usuarios creados via Google no tienen contraseña; en el formulario de edición conviene ocultar el campo de contraseña para ellos (añadir campo `authProvider: 'google' | 'local'` al usuario).
