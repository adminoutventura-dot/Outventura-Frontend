# Firebase Cloud Messaging — Setup manual

Configuración de notificaciones push para Outventura (Android).  
Package ID: `com.outventura.outventura`

---

## 1. Crear proyecto en Firebase Console

1. Ve a https://console.firebase.google.com
2. Crea un proyecto nuevo, por ejemplo `outventura`
3. En el panel del proyecto, activa **Cloud Messaging** (Build → Cloud Messaging)

---

## 2. Registrar la app Android

1. En Firebase Console, haz clic en **"Añadir app" → Android**
2. Package name: `com.outventura.outventura`
3. Apodo: `Outventura` (opcional)
4. Descarga el archivo `google-services.json`
5. Cópialo en: `android/app/google-services.json`

---

## 3. Modificar los Gradle

### `android/build.gradle.kts`
Añade el plugin de Google Services en el bloque de plugins a nivel raíz:

```kotlin
// Al final del archivo, añade:
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}
```

### `android/app/build.gradle.kts`
Añade el plugin en el bloque `plugins`:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // <-- añadir esta línea
}
```

---

## 4. Añadir dependencias Flutter

En `pubspec.yaml`, dentro de `dependencies`:

```yaml
firebase_core: ^3.13.1
firebase_messaging: ^15.2.5
flutter_local_notifications: ^18.0.1
```

Luego ejecuta:
```bash
flutter pub get
```

---

## 5. Código Flutter

### `lib/core/services/notification_service.dart` (crear)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Handler de mensajes en background (debe ser top-level).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Pedir permiso
    await _fcm.requestPermission();

    // Registrar handler de background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Canal Android para primer plano
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings),
    );

    // Mostrar notificación cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'outventura_channel',
            'Outventura',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    });
  }

  // Devuelve el token del dispositivo para enviarlo al backend.
  static Future<String?> getToken() => _fcm.getToken();
}
```

### `lib/main.dart` — Inicializar Firebase

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:outventura/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();          // <-- añadir
  await NotificationService.init();        // <-- añadir
  await initializeDateFormatting();
  runApp(const ProviderScope(child: MainApp()));
}
```

---

## 6. Probar sin backend

Desde la consola de Firebase → **Cloud Messaging → Enviar primer mensaje**:
1. Título y texto libres
2. Target: **app** (selecciona tu app Android)
3. Enviar — llegará como notificación al dispositivo

---

## 7. Cuando el backend esté listo

El flujo completo será:

1. Al hacer login, Flutter llama a `NotificationService.getToken()` y envía el token al endpoint `PUT /users/:id/fcm-token` del backend.
2. El backend guarda el token en la BD (campo `fcmToken` en el usuario).
3. Cuando se asigna una solicitud a un experto, NestJS llama a FCM con el token guardado.

### Dependencias NestJS necesarias:
```bash
npm install firebase-admin
```

### Ejemplo de llamada en NestJS:
```typescript
import * as admin from 'firebase-admin';

await admin.messaging().send({
  token: expert.fcmToken,
  notification: {
    title: 'Nueva solicitud asignada',
    body: `Se te ha asignado la solicitud #${solicitud.id}`,
  },
});
```

---

## Notas

- El `google-services.json` **no** debe subirse a git (añadir a `.gitignore`).
- La clave privada del backend (`serviceAccountKey.json`) tampoco se sube a git.
- FCM es gratuito sin límite de mensajes.
